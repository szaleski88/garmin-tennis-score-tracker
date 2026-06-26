using Toybox.WatchUi;

class MatchStatsView extends WatchUi.Menu2 {
    function initialize(engine) {
        var state = engine.getState();

        Menu2.initialize({:title=>"Match Stats"});

        addItem(new MenuItem("Duration", MatchMetrics.formatDuration(MatchMetrics.elapsedSeconds(state)), "duration", {}));
        addItem(new MenuItem("Total Points", scoreText(state.playerTotalPoints, state.opponentTotalPoints), "points", {}));
        addItem(new MenuItem("Total Games", scoreText(state.playerTotalGames, state.opponentTotalGames), "games", {}));
        addItem(new MenuItem("BP Won", ratioText(state.playerBreakPointsWon, state.playerBreakPointChances), "bpWon", {}));
        addItem(new MenuItem("BP Lost", ratioText(state.opponentBreakPointsWon, state.opponentBreakPointChances), "bpLost", {}));
        addItem(new MenuItem("Max Lead", leadText(state), "maxLead", {}));
        addItem(new MenuItem("Point Streak", leaderText(state.longestPlayerPointStreak, state.longestOpponentPointStreak), "pointStreak", {}));
        addItem(new MenuItem("Game Streak", leaderText(state.longestPlayerGameStreak, state.longestOpponentGameStreak), "gameStreak", {}));
        addItem(new MenuItem("Svc Pts Me", ratioText(state.playerServicePointsWon, state.playerServicePointsPlayed), "svcMe", {}));
        addItem(new MenuItem("Svc Pts OP", ratioText(state.opponentServicePointsWon, state.opponentServicePointsPlayed), "svcOp", {}));

        var calories = MatchMetrics.calorieDelta(state);

        if (calories != null) {
            addItem(new MenuItem("Calories", calories + "kcal", "calories", {}));
        }
    }

    function scoreText(playerValue, opponentValue) {
        return playerValue + "-" + opponentValue;
    }

    function ratioText(won, played) {
        if (played == 0) {
            return "0/0";
        }

        return won + "/" + played + " " + percentageText(won, played);
    }

    function percentageText(won, played) {
        if (played == 0) {
            return "0%";
        }

        return ((won * 100) / played) + "%";
    }

    function leadText(state) {
        if (state.maxPlayerPointLead == 0 && state.maxOpponentPointLead == 0) {
            return "Even";
        }

        if (state.maxPlayerPointLead == state.maxOpponentPointLead) {
            return "Both +" + state.maxPlayerPointLead;
        }

        if (state.maxPlayerPointLead > state.maxOpponentPointLead) {
            return "Me +" + state.maxPlayerPointLead;
        }

        return "OP +" + state.maxOpponentPointLead;
    }

    function leaderText(playerValue, opponentValue) {
        if (playerValue == 0 && opponentValue == 0) {
            return "None";
        }

        if (playerValue == opponentValue) {
            return "Both " + playerValue;
        }

        if (playerValue > opponentValue) {
            return "Me " + playerValue;
        }

        return "OP " + opponentValue;
    }
}
