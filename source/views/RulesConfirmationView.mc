using Toybox.Graphics;
using Toybox.WatchUi;

class RulesConfirmationView extends WatchUi.View {
    var _settings;
    var _playerServesFirst;

    function initialize(settings, playerServesFirst) {
        View.initialize();
        _settings = settings;
        _playerServesFirst = playerServesFirst;
    }

    function onUpdate(dc) {
        var centerX = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 78, Graphics.FONT_SMALL, "Ready to play?");

        dc.setColor(0xE9F400, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 124, Graphics.FONT_XTINY, _playerServesFirst ? "You serve first" : "Opponent serves first");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 168, Graphics.FONT_XTINY, ScoreFormatter.formatLabel(_settings));
        drawCentered(dc, centerX, 200, Graphics.FONT_XTINY, _settings.goldenPoint ? "No-ad scoring" : "Advantage scoring");

        if (_settings.matchFormat == MatchFormat.STB_MATCH) {
            drawCentered(dc, centerX, 232, Graphics.FONT_XTINY, "First to 10, win by 2");
        } else if (_settings.matchFormat == MatchFormat.TB_MATCH) {
            drawCentered(dc, centerX, 232, Graphics.FONT_XTINY, "First to 7, win by 2");
        } else {
            drawCentered(dc, centerX, 232, Graphics.FONT_XTINY, _settings.gamesInSet + " games per set");
            drawCentered(dc, centerX, 264, Graphics.FONT_XTINY, "Final: " + ScoreFormatter.finalSetLabel(_settings));
        }

        dc.setColor(0xFF7A1A, 0xFF7A1A);
        dc.fillRoundedRectangle(72, 284, 272, 64, 32);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 316, Graphics.FONT_SMALL, "Start match");

        dc.setColor(0xB8B8B8, Graphics.COLOR_TRANSPARENT);
        drawCentered(dc, centerX, 380, Graphics.FONT_XTINY, "Change rules");
    }

    function drawCentered(dc, x, centerY, font, text) {
        dc.drawText(x, centerY - (dc.getFontHeight(font) / 2), font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
