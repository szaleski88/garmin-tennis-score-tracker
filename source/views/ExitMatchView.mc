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
        dc.drawText(centerX, 76, Graphics.FONT_MEDIUM, "Exit this match?", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 122, Graphics.FONT_XTINY, "Your progress is saved.", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 143, Graphics.FONT_XTINY, "Resume from the main menu anytime.", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_DANGER, COLOR_DANGER);
        dc.fillRoundedRectangle(44, 184, 328, 68, 34);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 201, Graphics.FONT_SMALL, "Exit match", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRoundedRectangle(44, 262, 328, 68, 34);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 279, Graphics.FONT_SMALL, "Keep playing", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
