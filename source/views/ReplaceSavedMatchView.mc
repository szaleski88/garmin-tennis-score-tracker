using Toybox.Graphics;
using Toybox.WatchUi;

class ReplaceSavedMatchView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        var centerX = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 80, Graphics.FONT_SMALL, "Saved match");

        dc.setColor(0xB8B8B8, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 128, Graphics.FONT_XTINY, "Starting again replaces");
        drawCentered(dc, centerX, 160, Graphics.FONT_XTINY, "the current score.");

        dc.setColor(0xFF7A1A, 0xFF7A1A);
        dc.fillRoundedRectangle(72, 194, 272, 64, 32);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 226, Graphics.FONT_SMALL, "Keep saved");

        dc.setColor(0xFF4655, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 312, Graphics.FONT_SMALL, "Start new");
    }

    function drawCentered(dc, x, centerY, font, text) {
        dc.drawText(x, centerY - (dc.getFontHeight(font) / 2), font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
