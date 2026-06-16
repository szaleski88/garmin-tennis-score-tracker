using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class TennisMatchView extends WatchUi.View {
    static const SPLIT_Y = 208;
    static const FACE_RADIUS = 176;
    static const TOP_BLACK_Y = 92;
    static const BOTTOM_BLACK_Y = 352;
    static const COLOR_ORANGE = 0xFF7A1A;
    static const COLOR_SET = 0xF21D33;
    static const COLOR_GAME = 0x21BD54;
    static const COLOR_BALL = 0xE9F400;
    static const COLOR_DIM = 0x5C5C5C;
    static const COLOR_WARNING = 0xFFEA00;

    var _engine;
    var _ball;
    var _playerScore;
    var _opponentScore;
    var _stageLabel;
    var _detail;
    var _timer;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
        _ball = null;
        _timer = new Timer.Timer();
        refreshCache();
    }

    function onLayout(dc) {
        _ball = Application.loadResource(Rez.Drawables.TennisBall);
    }

    function onShow() {
        refreshCache();

        if (!_engine.getState().matchFinished) {
            _timer.start(method(:onTimer), 5000, true);
        }
    }

    function onHide() {
        _timer.stop();
    }

    function onTimer() {
        if (_engine.getState().matchFinished) {
            _timer.stop();
            return;
        }

        WatchUi.requestUpdate();
    }

    function refreshCache() {
        var state = _engine.getState();
        var settings = _engine.getSettings();
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
        var centerY = height / 2;
        var state = _engine.getState();

        drawFace(dc, width, height, centerX, centerY);
        drawTopCap(dc, width, centerX, state);
        drawColumnLabels(dc);
        drawOpponentScore(dc, centerX, state);
        drawDivider(dc, width, centerX);
        drawPlayerScore(dc, centerX, state);
        drawFooter(dc, height, centerX, state);
    }

    function drawFace(dc, width, height, centerX, centerY) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, FACE_RADIUS);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, TOP_BLACK_Y, width, SPLIT_Y - TOP_BLACK_Y);
        dc.fillRectangle(0, BOTTOM_BLACK_Y, width, height - BOTTOM_BLACK_Y);
    }

    function drawTopCap(dc, width, centerX, state) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 36, Graphics.FONT_MEDIUM, currentTimeText(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(96, 70, Graphics.FONT_XTINY, caloriesText(state), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 70, Graphics.FONT_XTINY, stageBadgeText(state), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width - 96, 70, Graphics.FONT_XTINY, batteryText(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawColumnLabels(dc) {
        dc.setColor(COLOR_SET, Graphics.COLOR_TRANSPARENT);
        dc.drawText(82, 101, Graphics.FONT_XTINY, "SET", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_GAME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(334, 101, Graphics.FONT_XTINY, "GAME", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawOpponentScore(dc, centerX, state) {
        var scoreColor = state.matchFinished && state.matchWinner != 2 ? COLOR_DIM : Graphics.COLOR_WHITE;
        var sideColor = state.matchFinished && state.matchWinner != 2 ? COLOR_DIM : null;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(108, 112, Graphics.FONT_MEDIUM, "OP", Graphics.TEXT_JUSTIFY_CENTER);

        drawSideNumber(dc, 82, 156, state.opponentSets, sideColor == null ? COLOR_SET : sideColor);
        drawPointScore(dc, centerX, 150, _opponentScore, scoreColor);
        drawSideNumber(dc, 334, 156, state.opponentGames, sideColor == null ? COLOR_GAME : sideColor);

        if (!state.playerServing && !state.matchFinished) {
            drawServingMarker(dc, 112, 168, false);
        }
    }

    function drawDivider(dc, width, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(54, SPLIT_Y - 3, width - 108, 6, 3);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, SPLIT_Y, 4);
    }

    function drawPlayerScore(dc, centerX, state) {
        var scoreColor = state.matchFinished && state.matchWinner != 1 ? COLOR_DIM : Graphics.COLOR_BLACK;
        var sideColor = state.matchFinished && state.matchWinner != 1 ? COLOR_DIM : null;

        drawSideNumber(dc, 82, 268, state.playerSets, sideColor == null ? COLOR_SET : sideColor);
        drawPointScore(dc, centerX, 280, _playerScore, scoreColor);
        drawSideNumber(dc, 334, 252, state.playerGames, sideColor == null ? COLOR_GAME : sideColor);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(300, 296, Graphics.FONT_MEDIUM, "ME", Graphics.TEXT_JUSTIFY_LEFT);

        if (state.playerServing && !state.matchFinished) {
            drawServingMarker(dc, 112, 304, true);
        }
    }

    function drawSideNumber(dc, x, centerY, value, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, x, centerY, Graphics.FONT_NUMBER_MEDIUM, value.toString());
    }

    function drawPointScore(dc, x, centerY, score, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, x, centerY, scoreFont(score), score);
    }

    function drawServingMarker(dc, x, y, playerServing) {
        dc.setColor(COLOR_BALL, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x + 11, y + 11, 16);

        if (_ball != null) {
            dc.drawBitmap(x, y, _ball);
        }

        if (playerServing) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(COLOR_WARNING, Graphics.COLOR_TRANSPARENT);
        }

        dc.drawText(x + 30, y + 2, Graphics.FONT_XTINY, "SERVE", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawFooter(dc, height, centerX, state) {
        var text = footerText(state);
        var color = footerColor(state);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - 48, Graphics.FONT_SMALL, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawCenteredText(dc, x, centerY, font, text) {
        dc.drawText(
            x,
            centerY - (Graphics.getFontHeight(font) / 2),
            font,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function currentTimeText() {
        var clock = System.getClockTime();
        var minute = clock.min < 10 ? "0" + clock.min : clock.min.toString();
        return clock.hour + ":" + minute;
    }

    function batteryText() {
        var stats = System.getSystemStats();

        if (stats != null && (stats has :battery)) {
            return stats.battery + "%";
        }

        return "--%";
    }

    function caloriesText(state) {
        var calories = MatchMetrics.calorieDelta(state);

        if (calories == null) {
            return "-- kcal";
        }

        return calories + " kcal";
    }

    function stageBadgeText(state) {
        if (state.matchFinished) {
            if (state.matchWinner == 1) {
                return "WON";
            }

            return "LOST";
        }

        return _stageLabel;
    }

    function footerText(state) {
        if (state.matchFinished) {
            if (state.matchWinner == 1) {
                return durationText(state) + "  MATCH WON";
            }

            return durationText(state) + "  MATCH LOST";
        }

        if (_detail == "Me serving") {
            return durationText(state) + "  ME SERVING";
        }

        if (_detail == "Opponent serving") {
            return durationText(state) + "  OP SERVING";
        }

        return durationText(state) + "  " + _detail;
    }

    function durationText(state) {
        return MatchMetrics.formatDuration(MatchMetrics.elapsedSeconds(state));
    }

    function footerColor(state) {
        if (state.matchFinished) {
            if (state.matchWinner == 1) {
                return COLOR_GAME;
            }

            return COLOR_SET;
        }

        if (_detail == "GOLDEN POINT") {
            return COLOR_WARNING;
        }

        return Graphics.COLOR_WHITE;
    }

    function scoreFont(score) {
        if (score == "AD" || score == "WIN" || score == "END") {
            return Graphics.FONT_LARGE;
        }

        return Graphics.FONT_NUMBER_HOT;
    }
}
