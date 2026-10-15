using Toybox.Graphics;
using Toybox.WatchUi;

class ExitMatchView extends WatchUi.View {
    static const COLOR_DANGER = 0xFF4655;
    static const COLOR_MUTED = 0xB8B8B8;

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        var centerX = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 80, Graphics.FONT_SMALL, "Exit this match?");

        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 128, Graphics.FONT_XTINY, "Your progress is saved.");
        drawCentered(dc, centerX, 160, Graphics.FONT_XTINY, "Resume from the main menu.");

        dc.setColor(0xFF7A1A, 0xFF7A1A);
        dc.fillRoundedRectangle(56, 194, 304, 64, 32);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 226, Graphics.FONT_SMALL, "Keep playing");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRoundedRectangle(72, 278, 272, 64, 32);
        dc.setColor(COLOR_DANGER, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 310, Graphics.FONT_SMALL, "Exit & save");
    }

    function drawCentered(dc, x, centerY, font, text) {
        dc.drawText(x, centerY - (dc.getFontHeight(font) / 2), font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
