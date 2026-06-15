using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class TennisMatchView extends WatchUi.View {
    var _engine;
    var _ball;
    var _summary;
    var _playerScore;
    var _opponentScore;
    var _stageLabel;
    var _detail;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
        _ball = null;
        refreshCache();
    }

    function onLayout(dc) {
        _ball = Application.loadResource(Rez.Drawables.TennisBall);
    }

    function onShow() {
        refreshCache();
    }

    function refreshCache() {
        var state = _engine.getState();
        var settings = _engine.getSettings();
        _summary = ScoreFormatter.summary(state, settings);
        _playerScore = ScoreFormatter.playerPoint(state, settings);
        _opponentScore = ScoreFormatter.opponentPoint(state, settings);
        _stageLabel = ScoreFormatter.stageLabel(state, settings);
        _detail = ScoreFormatter.detail(state, settings);
    }

    function requestRedraw() {
        refreshCache();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawStatus(dc, width);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 40, Graphics.FONT_SMALL, _summary, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 68, Graphics.FONT_XTINY, _stageLabel, Graphics.TEXT_JUSTIFY_CENTER);

        drawOpponent(dc, centerX);
        drawDivider(dc, width);
        drawPlayer(dc, centerX);

        dc.drawText(centerX, height - 54, Graphics.FONT_XTINY, _detail, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawStatus(dc, width) {
        var clock = System.getClockTime();
        var minute = clock.min < 10 ? "0" + clock.min : clock.min.toString();
        var time = clock.hour + ":" + minute;
        var battery = "";
        var stats = System.getSystemStats();

        if (stats != null && (stats has :battery)) {
            battery = stats.battery + "%";
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(34, 8, Graphics.FONT_XTINY, time, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width - 34, 8, Graphics.FONT_XTINY, battery, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawOpponent(dc, centerX) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 106, Graphics.FONT_XTINY, "OPP", Graphics.TEXT_JUSTIFY_CENTER);

        drawServerBall(dc, centerX, 134, !_engine.getState().playerServing);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 122, Graphics.FONT_LARGE, _opponentScore, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawDivider(dc, width) {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(52, 208, width - 52, 208);
    }

    function drawPlayer(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 254, Graphics.FONT_LARGE, _playerScore, Graphics.TEXT_JUSTIFY_CENTER);

        drawServerBall(dc, centerX, 266, _engine.getState().playerServing);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 318, Graphics.FONT_XTINY, "ME", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawServerBall(dc, centerX, y, visible) {
        if (!visible || _ball == null) {
            return;
        }

        dc.drawBitmap(centerX - 78, y, _ball);
    }
}
