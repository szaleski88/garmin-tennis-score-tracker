using Toybox.Graphics;
using Toybox.WatchUi;

class MatchFinishedView extends WatchUi.View {
    static const COLOR_ORANGE = 0xFF7A1A;
    static const COLOR_GREEN = 0x21BD54;
    static const COLOR_RED = 0xF21D33;

    var _engine;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
    }

    function onUpdate(dc) {
        var centerX = dc.getWidth() / 2;
        var state = _engine.getState();
        var playerWon = state.matchWinner == 1;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 64, Graphics.FONT_XTINY, "Match finished");

        dc.setColor(playerWon ? COLOR_GREEN : COLOR_RED, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 120, Graphics.FONT_LARGE, playerWon ? "YOU WON" : "YOU LOST");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 176, Graphics.FONT_XTINY, resultSummary(state));

        dc.setColor(0xB8B8B8, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 208, Graphics.FONT_XTINY, MatchMetrics.formatDuration(MatchMetrics.elapsedSeconds(state)));

        dc.setColor(COLOR_ORANGE, COLOR_ORANGE);
        dc.fillRoundedRectangle(56, 238, 304, 64, 32);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 270, Graphics.FONT_SMALL, "View stats");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 329, Graphics.FONT_SMALL, "Exit to menu");

        dc.setColor(0xB8B8B8, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 373, Graphics.FONT_XTINY, "Undo match point");
    }

    function drawCentered(dc, x, centerY, font, text) {
        dc.drawText(x, centerY - (dc.getFontHeight(font) / 2), font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function resultSummary(state) {
        var settings = _engine.getSettings();
        if (settings.matchFormat == MatchFormat.STB_MATCH || settings.matchFormat == MatchFormat.TB_MATCH) {
            return state.playerPoints + " points to " + state.opponentPoints;
        }
        return state.playerSets + " sets to " + state.opponentSets;
    }
}
