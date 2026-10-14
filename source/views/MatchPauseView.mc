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

        drawCourtArc(dc, centerX);
        drawMatchContext(dc, centerX, state);
        drawStatsButton(dc);
        drawResumeButton(dc);

        dc.setColor(COLOR_DANGER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 292, Graphics.FONT_SMALL, "Exit match", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawCourtArc(dc, centerX) {
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawCircle(centerX, -112, 150);
        dc.setPenWidth(1);
    }

    function drawMatchContext(dc, centerX, state) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 53, Graphics.FONT_MEDIUM, "Match paused", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(0xC6C6C6, Graphics.COLOR_TRANSPARENT);
        dc.drawText(116, 91, Graphics.FONT_XTINY, "Me", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_SET, Graphics.COLOR_TRANSPARENT);
        dc.drawText(174, 87, Graphics.FONT_SMALL, state.playerSets + "-" + state.opponentSets, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_GAME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(244, 87, Graphics.FONT_SMALL, state.playerGames + "-" + state.opponentGames, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(0xC6C6C6, Graphics.COLOR_TRANSPARENT);
        dc.drawText(302, 91, Graphics.FONT_XTINY, "OP", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawStatsButton(dc) {
        dc.setColor(COLOR_ORANGE, COLOR_ORANGE);
        dc.fillRoundedRectangle(44, 124, 328, 66, 33);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(69, 152, 4, 13, 2);
        dc.fillRoundedRectangle(77, 142, 4, 23, 2);
        dc.fillRoundedRectangle(85, 148, 4, 17, 2);
        dc.drawText(112, 139, Graphics.FONT_SMALL, "View stats", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawResumeButton(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRoundedRectangle(44, 202, 328, 66, 33);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[70, 222], [70, 248], [91, 235]]);
        dc.drawText(112, 217, Graphics.FONT_SMALL, "Resume match", Graphics.TEXT_JUSTIFY_LEFT);
    }
}
