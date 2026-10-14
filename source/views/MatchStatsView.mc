using Toybox.Graphics;
using Toybox.WatchUi;

class MatchStatsView extends WatchUi.View {
    static const COLOR_ORANGE = 0xFF7A1A;
    static const COLOR_MUTED = 0xB8B8B8;
    static const COLOR_LINE = 0x282828;
    static const COLOR_CLOSE = 0x222222;
    static const ROW_TOP = 118;
    static const ROW_HEIGHT = 46;
    static const ROWS_PER_PAGE = 5;

    var _engine;
    var _finalStats;
    var _page;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
        _finalStats = engine.getState().matchFinished;
        _page = 0;
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var centerX = width / 2;
        var state = _engine.getState();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawHeader(dc, width, centerX);
        drawRows(dc, width, state);

        if (_finalStats) {
            drawPageDots(dc, centerX);
        }
    }

    function drawHeader(dc, width, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(
            dc,
            centerX,
            72,
            Graphics.FONT_MEDIUM,
            _finalStats ? "Final stats" : "Current stats",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var closeX = width - 90;
        var closeY = 72;
        dc.setColor(COLOR_CLOSE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(closeX, closeY, 18);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(closeX - 5, closeY - 5, closeX + 5, closeY + 5);
        dc.drawLine(closeX + 5, closeY - 5, closeX - 5, closeY + 5);
        dc.setPenWidth(1);

        dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 276, 105, Graphics.FONT_XTINY, "Me", Graphics.TEXT_JUSTIFY_CENTER);
        drawCenteredText(dc, 330, 105, Graphics.FONT_XTINY, "OP", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawRows(dc, width, state) {
        var firstRow = _finalStats && _page == 1 ? 5 : 0;
        var rowCount = _finalStats && _page == 1 ? 4 : ROWS_PER_PAGE;

        for (var i = 0; i < rowCount; i++) {
            var metricIndex = firstRow + i;

            if (!_finalStats && i > 0) {
                metricIndex++;
            }

            var values = metric(metricIndex, state);
            drawRow(dc, width, i, values[0], values[1], values[2]);
        }
    }

    function drawRow(dc, width, rowIndex, label, playerValue, opponentValue) {
        var y = ROW_TOP + (rowIndex * ROW_HEIGHT);

        dc.setColor(COLOR_LINE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(62, y, width - 62, y);

        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 72, y + (ROW_HEIGHT / 2), Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 276, y + (ROW_HEIGHT / 2), valueFont(playerValue), playerValue, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 330, y + (ROW_HEIGHT / 2), valueFont(opponentValue), opponentValue, Graphics.TEXT_JUSTIFY_CENTER);

        if (rowIndex == ROWS_PER_PAGE - 1 || (_finalStats && _page == 1 && rowIndex == 3)) {
            dc.setColor(COLOR_LINE, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(62, y + ROW_HEIGHT, width - 62, y + ROW_HEIGHT);
        }
    }

    function metric(index, state) {
        if (index == 0) {
            return ["Points won", state.playerTotalPoints.toString(), state.opponentTotalPoints.toString()];
        }
        if (index == 1) {
            return ["Games won", state.playerTotalGames.toString(), state.opponentTotalGames.toString()];
        }
        if (index == 2) {
            return [
                "Service points",
                percentageText(state.playerServicePointsWon, state.playerServicePointsPlayed),
                percentageText(state.opponentServicePointsWon, state.opponentServicePointsPlayed)
            ];
        }
        if (index == 3) {
            return [
                "Break points",
                ratioText(state.playerBreakPointsWon, state.playerBreakPointChances),
                ratioText(state.opponentBreakPointsWon, state.opponentBreakPointChances)
            ];
        }
        if (index == 4) {
            return [
                "Best point streak",
                state.longestPlayerPointStreak.toString(),
                state.longestOpponentPointStreak.toString()
            ];
        }
        if (index == 5) {
            return [
                "Best game streak",
                state.longestPlayerGameStreak.toString(),
                state.longestOpponentGameStreak.toString()
            ];
        }
        if (index == 6) {
            return [
                "Max point lead",
                state.maxPlayerPointLead.toString(),
                state.maxOpponentPointLead.toString()
            ];
        }
        if (index == 7) {
            return [
                "Duration",
                MatchMetrics.formatDuration(MatchMetrics.elapsedSeconds(state)),
                "-"
            ];
        }

        var calories = MatchMetrics.calorieDelta(state);
        return ["Calories", calories == null ? "-" : calories.toString(), "-"];
    }

    function percentageText(won, played) {
        if (played == 0) {
            return "0%";
        }

        return ((won * 100) / played) + "%";
    }

    function ratioText(won, chances) {
        return won + "/" + chances;
    }

    function valueFont(value) {
        if (value.length() > 5) {
            return Graphics.FONT_XTINY;
        }

        return Graphics.FONT_SMALL;
    }

    function drawCenteredText(dc, x, centerY, font, text, justification) {
        dc.drawText(
            x,
            centerY - (dc.getFontHeight(font) / 2),
            font,
            text,
            justification
        );
    }

    function drawPageDots(dc, centerX) {
        var firstColor = _page == 0 ? COLOR_ORANGE : 0x555555;
        var secondColor = _page == 1 ? COLOR_ORANGE : 0x555555;

        dc.setColor(firstColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX - 7, 371, 3);
        dc.setColor(secondColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX + 7, 371, 3);
    }

    function nextPage() {
        if (!_finalStats || _page == 1) {
            return false;
        }

        _page = 1;
        WatchUi.requestUpdate();
        return true;
    }

    function previousPage() {
        if (!_finalStats || _page == 0) {
            return false;
        }

        _page = 0;
        WatchUi.requestUpdate();
        return true;
    }
}
