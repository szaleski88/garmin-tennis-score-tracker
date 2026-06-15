class ScoreFormatter {
    static function summary(state, settings) {
        if (settings.matchFormat == MatchFormat.STB_MATCH) {
            return "STB Match";
        }

        if (settings.matchFormat == MatchFormat.TB_MATCH) {
            return "TB Match";
        }

        if (state.stage == StageType.SUPER_TIE_BREAK) {
            return "S:" + state.playerSets + "-" + state.opponentSets + " | STB";
        }

        return "S:" + state.playerSets + "-" + state.opponentSets +
            " | G:" + state.playerGames + "-" + state.opponentGames;
    }

    static function playerPoint(state, settings) {
        return pointText(state.playerPoints, state.opponentPoints, state, settings, true);
    }

    static function opponentPoint(state, settings) {
        return pointText(state.opponentPoints, state.playerPoints, state, settings, false);
    }

    static function pointText(points, otherPoints, state, settings, isPlayer) {
        if (state.matchFinished) {
            if ((isPlayer && state.matchWinner == 1) || (!isPlayer && state.matchWinner == 2)) {
                return "WIN";
            }
            return "END";
        }

        if (state.stage == StageType.TIE_BREAK || state.stage == StageType.SUPER_TIE_BREAK) {
            return points.toString();
        }

        if (settings.goldenPoint) {
            return basicPoint(points);
        }

        if (points >= 4 && points == otherPoints + 1) {
            return "AD";
        }

        if (otherPoints >= 4 && otherPoints == points + 1) {
            return "40";
        }

        if (points >= 3 && otherPoints >= 3) {
            return "40";
        }

        return basicPoint(points);
    }

    static function basicPoint(points) {
        if (points == 0) {
            return "0";
        } else if (points == 1) {
            return "15";
        } else if (points == 2) {
            return "30";
        } else if (points == 3) {
            return "40";
        }

        return points + "p";
    }

    static function stageLabel(state, settings) {
        if (state.matchFinished || state.stage == StageType.MATCH_FINISHED) {
            return "MATCH";
        }

        if (state.stage == StageType.SUPER_TIE_BREAK) {
            return "STB";
        }

        if (state.stage == StageType.TIE_BREAK) {
            return "TB";
        }

        if (settings.goldenPoint || state.stage == StageType.GOLDEN_GAME) {
            return "NO-AD";
        }

        return "GAME";
    }

    static function detail(state, settings) {
        if (state.matchFinished) {
            if (state.matchWinner == 1) {
                return "Me";
            }
            return "Opponent";
        }

        if ((settings.goldenPoint || state.stage == StageType.GOLDEN_GAME) &&
            state.playerPoints == 3 && state.opponentPoints == 3) {
            return "GOLDEN POINT";
        }

        if (state.playerServing) {
            return "Me serving";
        }

        return "Opponent serving";
    }

    static function formatLabel(settings) {
        if (settings.matchFormat == MatchFormat.BEST_OF_5) {
            return "Best Of 5";
        } else if (settings.matchFormat == MatchFormat.STB_MATCH) {
            return "STB Match";
        } else if (settings.matchFormat == MatchFormat.TB_MATCH) {
            return "TB Match";
        }

        return "Best Of 3";
    }

    static function finalSetLabel(settings) {
        if (settings.finalSetMode == FinalSetMode.FULL_SET) {
            return "Full Set";
        } else if (settings.finalSetMode == FinalSetMode.TB) {
            return "TB";
        }

        return "STB";
    }
}
