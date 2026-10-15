using Toybox.Graphics;
using Toybox.WatchUi;

class MatchPauseView extends WatchUi.View {
    static const COLOR_ORANGE = 0xFF7A1A;
    static const COLOR_SET = 0xF21D33;
    static const COLOR_GAME = 0x21BD54;
    static const COLOR_DANGER = 0xFF4655;

    var _engine;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var centerX = width / 2;
        var state = _engine.getState();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawMatchContext(dc, centerX, state);
        drawResumeButton(dc);
        drawStatsButton(dc);

        dc.setColor(COLOR_DANGER, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, centerX, 320, Graphics.FONT_SMALL, "Exit & save", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawMatchContext(dc, centerX, state) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, centerX, 64, Graphics.FONT_XTINY, "Match paused", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(0xC6C6C6, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 116, 108, Graphics.FONT_XTINY, "Me", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_SET, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 174, 108, Graphics.FONT_XTINY, state.playerSets + "-" + state.opponentSets, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_GAME, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 244, 108, Graphics.FONT_XTINY, state.playerGames + "-" + state.opponentGames, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(0xC6C6C6, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 302, 108, Graphics.FONT_XTINY, "OP", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawStatsButton(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRoundedRectangle(48, 208, 320, 64, 32);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(73, 235, 4, 13, 2);
        dc.fillRoundedRectangle(81, 227, 4, 21, 2);
        dc.fillRoundedRectangle(89, 232, 4, 16, 2);
        drawCenteredText(dc, 116, 240, Graphics.FONT_SMALL, "View stats", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawResumeButton(dc) {
        dc.setColor(COLOR_ORANGE, COLOR_ORANGE);
        dc.fillRoundedRectangle(48, 132, 320, 64, 32);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[74, 152], [74, 176], [94, 164]]);
        drawCenteredText(dc, 116, 164, Graphics.FONT_SMALL, "Resume match", Graphics.TEXT_JUSTIFY_LEFT);
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
}
