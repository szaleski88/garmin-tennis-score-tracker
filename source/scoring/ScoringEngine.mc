using Toybox.Attention;

class ScoringEngine {
    static const MAX_HISTORY = 300;

    var _settings;
    var _state;
    var _history;

    function initialize(settings, playerServesFirst) {
        _settings = settings.clone();
        _state = new MatchState();
        _history = [];

        _state.playerServing = playerServesFirst;
        _state.tieBreakStarterPlayerServing = playerServesFirst;
        _state.startedAt = MatchMetrics.nowSeconds();
        _state.calorieBaseline = MatchMetrics.currentCalories();

        if (_settings.matchFormat == MatchFormat.STB_MATCH) {
            _state.stage = StageType.SUPER_TIE_BREAK;
        } else if (_settings.matchFormat == MatchFormat.TB_MATCH) {
            _state.stage = StageType.TIE_BREAK;
        } else if (_settings.goldenPoint) {
            _state.stage = StageType.GOLDEN_GAME;
        } else {
            _state.stage = StageType.GAME;
        }
    }

    static function resume(snapshot) {
        var engine = new ScoringEngine(snapshot.settings, snapshot.state.playerServing);
        engine.restore(snapshot.state, snapshot.history);
        return engine;
    }

    function restore(state, history) {
        _state = state.clone();
        ensureMetrics();
        _history = [];

        if (history != null) {
            for (var i = 0; i < history.size(); i++) {
                _history.add(history[i].clone());
            }
        }
    }

    function getSettings() {
        return _settings;
    }

    function getState() {
        return _state;
    }

    function historyToStorage() {
        var data = [];

        for (var i = 0; i < _history.size(); i++) {
            data.add(_history[i].toArray());
        }

        return data;
    }

    function scorePlayer() {
        return score(true);
    }

    function scoreOpponent() {
        return score(false);
    }

    function score(playerWonPoint) {
        if (_state.matchFinished) {
            return MatchResult.NONE;
        }

        pushSnapshot();

        if (playerWonPoint) {
            _state.playerPoints++;
        } else {
            _state.opponentPoints++;
        }

        var result = evaluatePoint(playerWonPoint);
        PersistenceManager.saveMatch(self);
        vibrateFor(result);
        return result;
    }

    function undo() {
        if (_history.size() == 0) {
            return false;
        }

        _state = _history.remove(_history.size() - 1);
        ensureMetrics();
        PersistenceManager.saveMatch(self);
        return true;
    }

    function ensureMetrics() {
        if (_state.startedAt == null) {
            _state.startedAt = MatchMetrics.nowSeconds();
        }

        if (_state.calorieBaseline == null) {
            _state.calorieBaseline = MatchMetrics.currentCalories();
        }

        if (_state.matchFinished) {
            if (_state.finishedAt == null) {
                _state.finishedAt = MatchMetrics.nowSeconds();
            }

            if (_state.calorieFinished == null) {
                _state.calorieFinished = MatchMetrics.currentCalories();
            }
        } else {
            _state.finishedAt = null;
            _state.calorieFinished = null;
        }
    }

    function pushSnapshot() {
        if (_history.size() >= MAX_HISTORY) {
            _history.remove(0);
        }

        _history.add(_state.clone());
    }

    function evaluatePoint(playerWonPoint) {
        if (!stageHasWinner(playerWonPoint)) {
            if (_state.stage == StageType.TIE_BREAK || _state.stage == StageType.SUPER_TIE_BREAK) {
                _state.playerServing = tieBreakServerForNextPoint();
            }
            return MatchResult.POINT;
        }

        if (_settings.matchFormat == MatchFormat.STB_MATCH ||
            _settings.matchFormat == MatchFormat.TB_MATCH) {
            finishMatch(playerWonPoint);
            return MatchResult.MATCH;
        }

        if (_state.stage == StageType.SUPER_TIE_BREAK) {
            awardSet(playerWonPoint);
            finishMatch(playerWonPoint);
            return MatchResult.MATCH;
        }

        awardGame(playerWonPoint);

        if (setFinished()) {
            awardSet(playerWonPoint);

            if (matchFinished()) {
                finishMatch(playerWonPoint);
                return MatchResult.MATCH;
            }

            startNextSet();
            return MatchResult.SET;
        }

        startNextGame();
        return MatchResult.GAME;
    }

    function stageHasWinner(playerWonPoint) {
        var winnerPoints = playerWonPoint ? _state.playerPoints : _state.opponentPoints;
        var loserPoints = playerWonPoint ? _state.opponentPoints : _state.playerPoints;

        if (_state.stage == StageType.GOLDEN_GAME) {
            return winnerPoints >= 4;
        }

        if (_state.stage == StageType.GAME) {
            return winnerPoints >= 4 && winnerPoints >= loserPoints + 2;
        }

        if (_state.stage == StageType.TIE_BREAK) {
            return winnerPoints >= 7 && winnerPoints >= loserPoints + 2;
        }

        if (_state.stage == StageType.SUPER_TIE_BREAK) {
            return winnerPoints >= 10 && winnerPoints >= loserPoints + 2;
        }

        return false;
    }

    function awardGame(playerWonPoint) {
        if (playerWonPoint) {
            _state.playerGames++;
        } else {
            _state.opponentGames++;
        }

        _state.playerPoints = 0;
        _state.opponentPoints = 0;

        if (_state.stage == StageType.TIE_BREAK) {
            _state.playerServing = !_state.tieBreakStarterPlayerServing;
        } else {
            _state.playerServing = !_state.playerServing;
        }
    }

    function awardSet(playerWonPoint) {
        if (playerWonPoint) {
            _state.playerSets++;
        } else {
            _state.opponentSets++;
        }

        _state.playerGames = 0;
        _state.opponentGames = 0;
        _state.playerPoints = 0;
        _state.opponentPoints = 0;
    }

    function setFinished() {
        if (isFinalSet() && _settings.finalSetMode == FinalSetMode.FULL_SET) {
            return setFinishedByTwo(_state.playerGames, _state.opponentGames) ||
                setFinishedByTwo(_state.opponentGames, _state.playerGames);
        }

        return setFinishedByRule(_state.playerGames, _state.opponentGames) ||
            setFinishedByRule(_state.opponentGames, _state.playerGames);
    }

    function setFinishedByRule(games, otherGames) {
        if (games >= _settings.gamesInSet && games > _settings.tieBreakAt) {
            return true;
        }

        return games == _settings.gamesInSet && games >= otherGames + 2;
    }

    function setFinishedByTwo(games, otherGames) {
        return games >= _settings.gamesInSet && games >= otherGames + 2;
    }

    function matchFinished() {
        return _state.playerSets >= _settings.setsToWin() ||
            _state.opponentSets >= _settings.setsToWin();
    }

    function finishMatch(playerWonPoint) {
        _state.matchFinished = true;
        _state.stage = StageType.MATCH_FINISHED;
        _state.matchWinner = playerWonPoint ? 1 : 2;
        _state.finishedAt = MatchMetrics.nowSeconds();
        _state.calorieFinished = MatchMetrics.currentCalories();
    }

    function startNextSet() {
        if (isFinalSet() && _settings.finalSetMode == FinalSetMode.STB) {
            _state.stage = StageType.SUPER_TIE_BREAK;
            _state.tieBreakStarterPlayerServing = _state.playerServing;
            return;
        }

        startNextGame();
    }

    function startNextGame() {
        if (shouldStartTieBreak()) {
            _state.stage = StageType.TIE_BREAK;
            _state.tieBreakStarterPlayerServing = _state.playerServing;
        } else if (_settings.goldenPoint) {
            _state.stage = StageType.GOLDEN_GAME;
        } else {
            _state.stage = StageType.GAME;
        }
    }

    function shouldStartTieBreak() {
        if (isFinalSet() && _settings.finalSetMode == FinalSetMode.FULL_SET) {
            return false;
        }

        return _state.playerGames == _settings.tieBreakAt &&
            _state.opponentGames == _settings.tieBreakAt;
    }

    function isFinalSet() {
        return (_state.playerSets + _state.opponentSets) == (_settings.bestOfSets - 1);
    }

    function tieBreakServerForNextPoint() {
        var played = _state.playerPoints + _state.opponentPoints;
        var slot = played % 4;

        if (slot == 0 || slot == 3) {
            return _state.tieBreakStarterPlayerServing;
        }

        return !_state.tieBreakStarterPlayerServing;
    }

    function vibrateFor(result) {
        if (!(Attention has :vibrate)) {
            return;
        }

        if (result == MatchResult.POINT) {
            Attention.vibrate([new Attention.VibeProfile(35, 80)]);
        } else if (result == MatchResult.GAME) {
            Attention.vibrate([
                new Attention.VibeProfile(55, 70),
                new Attention.VibeProfile(0, 45),
                new Attention.VibeProfile(55, 70),
                new Attention.VibeProfile(0, 45),
                new Attention.VibeProfile(55, 70)
            ]);
        } else if (result == MatchResult.SET) {
            Attention.vibrate([new Attention.VibeProfile(75, 350)]);
        } else if (result == MatchResult.MATCH) {
            Attention.vibrate([
                new Attention.VibeProfile(100, 180),
                new Attention.VibeProfile(0, 80),
                new Attention.VibeProfile(100, 180),
                new Attention.VibeProfile(0, 80),
                new Attention.VibeProfile(100, 300)
            ]);
        }
    }
}
