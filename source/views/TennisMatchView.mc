using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class TennisMatchView extends WatchUi.View {
    static const SPLIT_Y = 208;
    static const FACE_RADIUS = 208;
    static const TOP_BLACK_Y = 92;
    static const BOTTOM_BLACK_Y = 352;
    static const COLOR_ORANGE = 0xFF7A1A;
    static const COLOR_SET = 0xF21D33;
    static const COLOR_GAME = 0x21BD54;
    static const COLOR_BALL = 0xE9F400;
    static const COLOR_DIM = 0x5C5C5C;
    static const COLOR_WARNING = 0xFFEA00;
    static const OPPONENT_MARKER_LEFT_X = 90;
    static const OPPONENT_MARKER_RIGHT_X = 304;
    static const OPPONENT_MARKER_Y = 168;
    static const PLAYER_MARKER_LEFT_X = 112;
    static const PLAYER_MARKER_RIGHT_X = 260;
    static const PLAYER_MARKER_Y = 304;

    var _engine;
    var _ball;
    var _playerScore;
    var _opponentScore;
    var _stageLabel;
    var _detail;
    var _timer;
    var _noticeTimer;
    var _noticeText;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
        _ball = null;
        _timer = new Timer.Timer();
        _noticeTimer = new Timer.Timer();
        _noticeText = null;
        refreshCache();
    }

    function onLayout(dc) {
        _ball = Application.loadResource(Rez.Drawables.TennisBall);
    }

    function onShow() {
        refreshCache();
        updateClockTimer();
    }

    function onHide() {
        _timer.stop();
        _noticeTimer.stop();
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
        updateClockTimer();
        WatchUi.requestUpdate();
    }

    function updateClockTimer() {
        _timer.stop();

        if (!_engine.getState().matchFinished) {
            _timer.start(method(:onTimer), 5000, true);
        }
    }

    function showNotice(message) {
        _noticeText = message;
        _noticeTimer.stop();
        _noticeTimer.start(method(:clearNotice), 3000, false);
        WatchUi.requestUpdate();
    }

    function clearNotice() {
        _noticeText = null;
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
        drawNotice(dc, width, centerX, centerY);
    }

    function drawFace(dc, width, height, centerX, centerY) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        // Use centerX as the radius to perfectly fill the width of the screen
        dc.fillCircle(centerX, centerY, centerX);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, TOP_BLACK_Y, width, SPLIT_Y - TOP_BLACK_Y);
        dc.fillRectangle(0, BOTTOM_BLACK_Y, width, height - BOTTOM_BLACK_Y);
    }

    function drawTopCap(dc, width, centerX, state) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        // Push time up closer to the very top edge
        dc.drawText(centerX, 10, Graphics.FONT_MEDIUM, currentTimeText(), Graphics.TEXT_JUSTIFY_CENTER);

        // Push calories and battery down to create separation from the time
        // Note: I'm using the widened X-coordinates (100) here, but adjust to 136 if you kept the original narrow layout.
        dc.drawText(100, 62, Graphics.FONT_XTINY, caloriesText(state), Graphics.TEXT_JUSTIFY_CENTER);

        if (state.matchFinished) {
            dc.drawText(centerX, 62, Graphics.FONT_XTINY, stageBadgeText(state), Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.drawText(width - 100, 62, Graphics.FONT_XTINY, batteryText(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawColumnLabels(dc) {
        dc.setColor(COLOR_SET, Graphics.COLOR_TRANSPARENT);
        dc.drawText(82, 101, Graphics.FONT_XTINY, "SET", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_GAME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(334, 101, Graphics.FONT_XTINY, "GAME", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawOpponentScore(dc, centerX, state) {
        var scoreColor = state.matchFinished && state.matchWinner != 2 ?
            COLOR_DIM : Graphics.COLOR_WHITE;
        var sideColor = state.matchFinished && state.matchWinner != 2 ? COLOR_DIM : null;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // Shifted left from 126 to 104
        dc.drawText(104, 118, Graphics.FONT_SMALL, "OP", Graphics.TEXT_JUSTIFY_CENTER);

        // Shifted side numbers out to 60 and 356
        drawSideNumber(dc, 60, 156, state.opponentSets, sideColor == null ? COLOR_SET : sideColor);
        drawPointScore(dc, centerX, 150, _opponentScore, scoreColor);
        drawSideNumber(dc, 356, 156, state.opponentGames, sideColor == null ? COLOR_GAME : sideColor);

        if (!state.playerServing && !state.matchFinished) {
            drawServingSideMarkers(dc, OPPONENT_MARKER_LEFT_X, OPPONENT_MARKER_RIGHT_X, OPPONENT_MARKER_Y, state);
        }
    }

    function drawDivider(dc, width, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // Changed starting X from 54 to 24, and width reduction from 108 to 48
        dc.fillRoundedRectangle(24, SPLIT_Y - 3, width - 48, 6, 3);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, SPLIT_Y, 4);
    }

    function drawPlayerScore(dc, centerX, state) {
        var scoreColor = state.matchFinished && state.matchWinner != 1 ?
            COLOR_DIM : Graphics.COLOR_BLACK;
        var sideColor = state.matchFinished && state.matchWinner != 1 ? COLOR_DIM : null;

        // Aligned both Y-coordinates to 260
        drawSideNumber(dc, 82, 260, state.playerSets, sideColor == null ? COLOR_SET : sideColor);
        drawPointScore(dc, centerX, 280, _playerScore, scoreColor);
        drawSideNumber(dc, 334, 260, state.playerGames, sideColor == null ? COLOR_GAME : sideColor);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(292, 304, Graphics.FONT_SMALL, "ME", Graphics.TEXT_JUSTIFY_LEFT);

        if (state.playerServing && !state.matchFinished) {
            drawServingSideMarkers(dc, PLAYER_MARKER_LEFT_X, PLAYER_MARKER_RIGHT_X, PLAYER_MARKER_Y, state);
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

    function drawServingMarker(dc, x, y) {
        dc.setColor(COLOR_BALL, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x + 11, y + 11, 16);

        if (_ball != null) {
            dc.drawBitmap(x, y, _ball);
        }
    }

    function drawServingSideMarkers(dc, leftX, rightX, y, state) {
        if (isGoldenPoint(state)) {
            drawServingMarker(dc, leftX, y);
            drawServingMarker(dc, rightX, y);
            return;
        }

        if (((state.playerPoints + state.opponentPoints) % 2) == 0) {
            drawServingMarker(dc, rightX, y);
        } else {
            drawServingMarker(dc, leftX, y);
        }
    }

    function isGoldenPoint(state) {
        return (state.stage == StageType.GOLDEN_GAME || _engine.getSettings().goldenPoint) &&
            state.playerPoints == 3 &&
            state.opponentPoints == 3;
    }

    function drawFooter(dc, height, centerX, state) {
        var text = footerText(state);
        var color = footerColor(state);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        // Moved duration Y-coordinate UP from height - 48 to height - 64
        dc.drawText(centerX, height - 64, Graphics.FONT_SMALL, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawNotice(dc, width, centerX, centerY) {
        if (_noticeText == null) {
            return;
        }

        var boxWidth = width - 96;
        var boxHeight = 72;
        var boxX = 48;
        var boxY = centerY - (boxHeight / 2);

        dc.setColor(COLOR_WARNING, COLOR_WARNING);
        dc.fillRoundedRectangle(boxX, boxY, boxWidth, boxHeight, 6);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(boxX + 4, boxY + 4, boxWidth - 8, boxHeight - 8, 4);

        dc.setColor(COLOR_WARNING, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, boxY + 18, Graphics.FONT_MEDIUM, _noticeText, Graphics.TEXT_JUSTIFY_CENTER);
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
            return (stats.battery + 0.5).toNumber().format("%d") + "%";
        }

        return "--%";
    }

    function caloriesText(state) {
        var calories = MatchMetrics.calorieDelta(state);

        if (calories == null) {
            return "--kcal";
        }

        return calories + "kcal";
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
                return durationText(state) + "  WON";
            }

            return durationText(state) + "  LOST";
        }

        if (_detail == "GOLDEN POINT") {
            return "GOLDEN POINT";
        }

        return durationText(state);
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
