using Toybox.Attention;

class ScoringEngine {
    static const MAX_HISTORY = 5;

    var _settings;
    var _state;
    var _history;
    var _redoHistory;
    var _sideSwapTriggered;

    function initialize(settings, playerServesFirst) {
        _settings = settings.clone();
        _state = new MatchState();
        _history = [];
        _redoHistory = [];
        _sideSwapTriggered = false;

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
        engine.restore(snapshot.state, snapshot.history, snapshot.redoHistory);
        return engine;
    }

    function restore(state, history, redoHistory) {
        _state = state.clone();
        ensureMetrics();
        _history = [];
        _redoHistory = [];
        _sideSwapTriggered = false;

        if (needsFinalSetDecision() &&
            _state.playerGames == 0 && _state.opponentGames == 0 &&
            _state.playerPoints == 0 && _state.opponentPoints == 0) {
            _state.stage = StageType.FINAL_SET_DECISION;
        }

        if (history != null) {
            for (var i = 0; i < history.size(); i++) {
                _history.add(history[i].clone());
            }
            trimStack(_history);
        }

        if (redoHistory != null) {
            for (var j = 0; j < redoHistory.size(); j++) {
                _redoHistory.add(redoHistory[j].clone());
            }
            trimStack(_redoHistory);
        }
    }

    function getSettings() {
        return _settings;
    }

    function getState() {
        return _state;
    }

    function sideSwapTriggered() {
        return _sideSwapTriggered;
    }

    function isAwaitingFinalSetDecision() {
        return _state.stage == StageType.FINAL_SET_DECISION;
    }

    function historyToStorage() {
        return stateStackToStorage(_history);
    }

    function redoHistoryToStorage() {
        return stateStackToStorage(_redoHistory);
    }

    function scorePlayer() {
        return score(true);
    }

    function scoreOpponent() {
        return score(false);
    }

    function score(playerWonPoint) {
        _sideSwapTriggered = false;

        if (_state.matchFinished) {
            return MatchResult.NONE;
        }

        if (isAwaitingFinalSetDecision()) {
            return selectFinalSetMode(playerWonPoint ? FinalSetMode.TB : FinalSetMode.STB);
        }

        pushSnapshot();
        clearRedoHistory();

        var breakPointForPlayer = isBreakPointFor(true);
        var breakPointForOpponent = isBreakPointFor(false);
        var playerServedPoint = _state.playerServing;

        if (playerWonPoint) {
            _state.playerPoints++;
            _state.playerTotalPoints++;
        } else {
            _state.opponentPoints++;
            _state.opponentTotalPoints++;
        }

        recordServicePoint(playerWonPoint, playerServedPoint);
        recordBreakPoint(playerWonPoint, breakPointForPlayer, breakPointForOpponent);
        recordPointStreak(playerWonPoint);
        recordPointLead();

        var result = evaluatePoint(playerWonPoint);
        PersistenceManager.saveMatch(self);
        vibrateFor(_sideSwapTriggered ? MatchResult.SIDE_SWAP : result);
        return result;
    }

    function selectFinalSetMode(mode) {
        pushSnapshot();
        clearRedoHistory();
        _state.selectedFinalSetMode = mode;

        if (mode == FinalSetMode.STB) {
            _state.stage = StageType.SUPER_TIE_BREAK;
            _state.tieBreakStarterPlayerServing = _state.playerServing;
        } else {
            startNextGame();
        }

        PersistenceManager.saveMatch(self);
        vibrateFor(MatchResult.POINT);
        return MatchResult.POINT;
    }

    function undo() {
        if (_history.size() == 0) {
            return false;
        }

        var lastSideSwapPointCount = _state.lastSideSwapPointCount;
        pushRedoSnapshot();
        var previousState = _history[_history.size() - 1];
        _history.remove(previousState);
        _state = previousState;
        preserveSideSwapWatermark(lastSideSwapPointCount);
        _sideSwapTriggered = false;
        ensureMetrics();
        PersistenceManager.saveMatch(self);
        return true;
    }

    function redo() {
        if (_redoHistory.size() == 0) {
            return false;
        }

        var lastSideSwapPointCount = _state.lastSideSwapPointCount;
        pushSnapshot();
        var nextState = _redoHistory[_redoHistory.size() - 1];
        _redoHistory.remove(nextState);
        _state = nextState;
        preserveSideSwapWatermark(lastSideSwapPointCount);
        _sideSwapTriggered = false;
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
        _history.add(_state.clone());
        trimStack(_history);
    }

    function pushRedoSnapshot() {
        _redoHistory.add(_state.clone());
        trimStack(_redoHistory);
    }

    function clearRedoHistory() {
        _redoHistory = [];
    }

    function preserveSideSwapWatermark(pointCount) {
        if (pointCount > _state.lastSideSwapPointCount) {
            _state.lastSideSwapPointCount = pointCount;
        }
    }

    function isBreakPointFor(player) {
        if (_state.stage != StageType.GAME && _state.stage != StageType.GOLDEN_GAME) {
            return false;
        }

        if (player && _state.playerServing) {
            return false;
        }

        if (!player && !_state.playerServing) {
            return false;
        }

        return pointWouldWinCurrentGame(player);
    }

    function pointWouldWinCurrentGame(playerWonPoint) {
        var winnerPoints = playerWonPoint ? _state.playerPoints + 1 : _state.opponentPoints + 1;
        var loserPoints = playerWonPoint ? _state.opponentPoints : _state.playerPoints;

        if (_state.stage == StageType.GOLDEN_GAME) {
            return winnerPoints >= 4;
        }

        if (_state.stage == StageType.GAME) {
            return winnerPoints >= 4 && winnerPoints >= loserPoints + 2;
        }

        return false;
    }

    function recordBreakPoint(playerWonPoint, breakPointForPlayer, breakPointForOpponent) {
        if (breakPointForPlayer) {
            _state.playerBreakPointChances++;

            if (playerWonPoint) {
                _state.playerBreakPointsWon++;
            }
        }

        if (breakPointForOpponent) {
            _state.opponentBreakPointChances++;

            if (!playerWonPoint) {
                _state.opponentBreakPointsWon++;
            }
        }
    }

    function recordServicePoint(playerWonPoint, playerServedPoint) {
        if (playerServedPoint) {
            _state.playerServicePointsPlayed++;

            if (playerWonPoint) {
                _state.playerServicePointsWon++;
            }

            return;
        }

        _state.opponentServicePointsPlayed++;

        if (!playerWonPoint) {
            _state.opponentServicePointsWon++;
        }
    }

    function recordPointStreak(playerWonPoint) {
        var winner = playerWonPoint ? 1 : 2;

        if (_state.currentPointStreakWinner == winner) {
            _state.currentPointStreak++;
        } else {
            _state.currentPointStreakWinner = winner;
            _state.currentPointStreak = 1;
        }

        if (winner == 1 && _state.currentPointStreak > _state.longestPlayerPointStreak) {
            _state.longestPlayerPointStreak = _state.currentPointStreak;
        } else if (winner == 2 && _state.currentPointStreak > _state.longestOpponentPointStreak) {
            _state.longestOpponentPointStreak = _state.currentPointStreak;
        }
    }

    function recordPointLead() {
        var lead = _state.playerTotalPoints - _state.opponentTotalPoints;

        if (lead > _state.maxPlayerPointLead) {
            _state.maxPlayerPointLead = lead;
        } else if ((lead * -1) > _state.maxOpponentPointLead) {
            _state.maxOpponentPointLead = lead * -1;
        }
    }

    function recordGameStreak(playerWonGame) {
        var winner = playerWonGame ? 1 : 2;

        if (_state.currentGameStreakWinner == winner) {
            _state.currentGameStreak++;
        } else {
            _state.currentGameStreakWinner = winner;
            _state.currentGameStreak = 1;
        }

        if (winner == 1 && _state.currentGameStreak > _state.longestPlayerGameStreak) {
            _state.longestPlayerGameStreak = _state.currentGameStreak;
        } else if (winner == 2 && _state.currentGameStreak > _state.longestOpponentGameStreak) {
            _state.longestOpponentGameStreak = _state.currentGameStreak;
        }
    }

    function stateStackToStorage(stack) {
        var data = [];

        for (var i = 0; i < stack.size(); i++) {
            data.add(stack[i].toArray());
        }

        return data;
    }

    function trimStack(stack) {
        while (stack.size() > MAX_HISTORY) {
            stack.remove(stack[0]);
        }
    }

    function evaluatePoint(playerWonPoint) {
        if (!stageHasWinner(playerWonPoint)) {
            if (isTieBreakStage()) {
                _state.playerServing = tieBreakServerForNextPoint();

                if (tieBreakSideSwapDue() && markSideSwap()) {
                    return MatchResult.SIDE_SWAP;
                }
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
        if (((_state.playerGames + _state.opponentGames) % 2) == 1) {
            markSideSwap();
        }

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
            _state.playerTotalGames++;
        } else {
            _state.opponentGames++;
            _state.opponentTotalGames++;
        }

        recordGameStreak(playerWonPoint);

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
        if (isFinalSet() && effectiveFinalSetMode() == FinalSetMode.FULL_SET) {
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
        if (needsFinalSetDecision()) {
            _state.stage = StageType.FINAL_SET_DECISION;
            return;
        }

        if (isFinalSet() && effectiveFinalSetMode() == FinalSetMode.STB) {
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
        if (isFinalSet() && effectiveFinalSetMode() == FinalSetMode.FULL_SET) {
            return false;
        }

        return _state.playerGames == _settings.tieBreakAt &&
            _state.opponentGames == _settings.tieBreakAt;
    }

    function isFinalSet() {
        return (_state.playerSets + _state.opponentSets) == (_settings.bestOfSets - 1);
    }

    function needsFinalSetDecision() {
        return _settings.matchFormat == MatchFormat.BEST_OF_3 &&
            _settings.finalSetMode == FinalSetMode.DECIDE &&
            isFinalSet() && _state.selectedFinalSetMode == null;
    }

    function effectiveFinalSetMode() {
        if (_settings.finalSetMode == FinalSetMode.DECIDE) {
            if (_state.selectedFinalSetMode != null) {
                return _state.selectedFinalSetMode;
            }

            return FinalSetMode.TB;
        }

        return _settings.finalSetMode;
    }

    function tieBreakServerForNextPoint() {
        var played = _state.playerPoints + _state.opponentPoints;
        var slot = played % 4;

        if (slot == 0 || slot == 3) {
            return _state.tieBreakStarterPlayerServing;
        }

        return !_state.tieBreakStarterPlayerServing;
    }

    function isTieBreakStage() {
        return _state.stage == StageType.TIE_BREAK ||
            _state.stage == StageType.SUPER_TIE_BREAK;
    }

    function tieBreakSideSwapDue() {
        if (!isTieBreakStage()) {
            return false;
        }

        var played = _state.playerPoints + _state.opponentPoints;
        return played > 0 && (played % 6) == 0;
    }

    function markSideSwap() {
        var pointCount = _state.playerTotalPoints + _state.opponentTotalPoints;

        if (pointCount <= _state.lastSideSwapPointCount) {
            return false;
        }

        _state.lastSideSwapPointCount = pointCount;
        _sideSwapTriggered = true;
        return true;
    }

    function vibrateFor(result) {
        if (!(Attention has :vibrate)) {
            return;
        }

        if (result == MatchResult.POINT) {
            Attention.vibrate([new Attention.VibeProfile(35, 80)]);
        } else if (result == MatchResult.SIDE_SWAP) {
            Attention.vibrate([
                new Attention.VibeProfile(90, 220),
                new Attention.VibeProfile(0, 90),
                new Attention.VibeProfile(90, 220),
                new Attention.VibeProfile(0, 90),
                new Attention.VibeProfile(90, 260)
            ]);
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
