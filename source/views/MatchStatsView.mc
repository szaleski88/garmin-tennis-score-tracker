using Toybox.Graphics;
using Toybox.WatchUi;

class MatchStatsView extends WatchUi.View {
    static const COLOR_ORANGE = 0xFF7A1A;
    static const COLOR_MUTED = 0xB8B8B8;
    static const COLOR_LINE = 0x282828;
    static const COLOR_CLOSE = 0x222222;
    static const ROW_TOP = 118;
    static const ROW_HEIGHT = 52;

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
        drawHeader(dc, width);

        if (state.playerTotalPoints == 0 && state.opponentTotalPoints == 0) {
            drawEmptyState(dc, centerX);
            return;
        }

        drawRows(dc, width, state);
        if (pageCount() > 1) {
            drawPageDots(dc, centerX);
        }
    }

    function drawHeader(dc, width) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawText(dc, 190, 76, Graphics.FONT_SMALL, _finalStats ? "Final stats" : "Current stats", Graphics.TEXT_JUSTIFY_CENTER);

        var closeX = width - 86;
        var closeY = 68;
        dc.setColor(COLOR_CLOSE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(closeX, closeY, 20);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(closeX - 6, closeY - 6, closeX + 6, closeY + 6);
        dc.drawLine(closeX + 6, closeY - 6, closeX - 6, closeY + 6);
        dc.setPenWidth(1);

        dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
        drawText(dc, 270, 102, Graphics.FONT_XTINY, "Me", Graphics.TEXT_JUSTIFY_CENTER);
        drawText(dc, 342, 102, Graphics.FONT_XTINY, "OP", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawEmptyState(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawText(dc, centerX, 190, Graphics.FONT_SMALL, "No points yet", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        drawText(dc, centerX, 242, Graphics.FONT_XTINY, "Score a point to see stats", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawRows(dc, width, state) {
        var indices = metricIndices();

        for (var i = 0; i < indices.size(); i++) {
            var values = metric(indices[i], state);
            drawRow(dc, width, i, values[0], values[1], values[2]);
        }

        var bottom = ROW_TOP + (indices.size() * ROW_HEIGHT);
        dc.setColor(COLOR_LINE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(60, bottom, width - 60, bottom);
    }

    function metricIndices() {
        if (!_finalStats) {
            return _page == 0 ? [0, 2, 3] : [4, 5];
        }
        if (_page == 0) {
            return [0, 1, 2, 3];
        }
        if (_page == 1) {
            return [4, 5, 6];
        }
        return [7, 8];
    }

    function drawRow(dc, width, rowIndex, label, playerValue, opponentValue) {
        var y = ROW_TOP + (rowIndex * ROW_HEIGHT);

        dc.setColor(COLOR_LINE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(60, y, width - 60, y);
        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        drawText(dc, 66, y + (ROW_HEIGHT / 2), Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        drawText(dc, 270, y + (ROW_HEIGHT / 2), Graphics.FONT_XTINY, playerValue, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawText(dc, 342, y + (ROW_HEIGHT / 2), Graphics.FONT_XTINY, opponentValue, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function metric(index, state) {
        if (index == 0) {
            return ["Points won", state.playerTotalPoints.toString(), state.opponentTotalPoints.toString()];
        }
        if (index == 1) {
            return ["Games won", state.playerTotalGames.toString(), state.opponentTotalGames.toString()];
        }
        if (index == 2) {
            return ["Service points", percentageText(state.playerServicePointsWon, state.playerServicePointsPlayed), percentageText(state.opponentServicePointsWon, state.opponentServicePointsPlayed)];
        }
        if (index == 3) {
            return ["Break points", ratioText(state.playerBreakPointsWon, state.playerBreakPointChances), ratioText(state.opponentBreakPointsWon, state.opponentBreakPointChances)];
        }
        if (index == 4) {
            return ["Best point streak", state.longestPlayerPointStreak.toString(), state.longestOpponentPointStreak.toString()];
        }
        if (index == 5) {
            return ["Best game streak", state.longestPlayerGameStreak.toString(), state.longestOpponentGameStreak.toString()];
        }
        if (index == 6) {
            return ["Max point lead", state.maxPlayerPointLead.toString(), state.maxOpponentPointLead.toString()];
        }
        if (index == 7) {
            return ["Duration", MatchMetrics.formatDuration(MatchMetrics.elapsedSeconds(state)), "-"];
        }

        var calories = MatchMetrics.calorieDelta(state);
        return ["Calories", calories == null ? "-" : calories.toString(), "-"];
    }

    function percentageText(won, played) {
        return played == 0 ? "0%" : ((won * 100) / played) + "%";
    }

    function ratioText(won, chances) {
        return won + "/" + chances;
    }

    function drawText(dc, x, centerY, font, text, justification) {
        dc.drawText(x, centerY - (dc.getFontHeight(font) / 2), font, text, justification);
    }

    function drawPageDots(dc, centerX) {
        var count = pageCount();
        var startX = centerX - ((count - 1) * 9);

        for (var i = 0; i < count; i++) {
            dc.setColor(i == _page ? COLOR_ORANGE : 0x555555, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(startX + (i * 18), 360, 3);
        }
    }

    function pageCount() {
        return _finalStats ? 3 : 2;
    }

    function nextPage() {
        if (_page >= pageCount() - 1) {
            return false;
        }
        _page++;
        WatchUi.requestUpdate();
        return true;
    }

    function previousPage() {
        if (_page == 0) {
            return false;
        }
        _page--;
        WatchUi.requestUpdate();
        return true;
    }
}
