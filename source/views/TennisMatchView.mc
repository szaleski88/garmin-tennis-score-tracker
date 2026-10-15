using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class TennisMatchView extends WatchUi.View {
    static const SPLIT_Y = 208;
    static const TOP_BLACK_Y = 92;
    static const BOTTOM_BLACK_Y = 352;
    static const COLOR_ORANGE = 0xFF7A1A;
    static const COLOR_SET = 0xF21D33;
    static const COLOR_GAME = 0x21BD54;
    static const COLOR_BALL = 0xE9F400;
    static const COLOR_DIM = 0x5C5C5C;
    static const COLOR_WARNING = 0xFFEA00;
    static const OPPONENT_MARKER_LEFT_X = 100;
    static const OPPONENT_MARKER_RIGHT_X = 292;
    static const OPPONENT_MARKER_Y = 172;
    static const PLAYER_MARKER_LEFT_X = 112;
    static const PLAYER_MARKER_RIGHT_X = 260;
    static const PLAYER_MARKER_Y = 316;

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

    function hasNotice() {
        return _noticeText != null;
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
        drawCenteredText(dc, centerX, 38, Graphics.FONT_XTINY, currentTimeText());
        drawCenteredText(dc, 132, 74, Graphics.FONT_XTINY, caloriesText(state));
        drawCenteredText(dc, width - 132, 74, Graphics.FONT_XTINY, batteryText());
    }

    function drawColumnLabels(dc) {
        dc.setColor(COLOR_SET, Graphics.COLOR_TRANSPARENT);
        dc.drawText(72, 100, Graphics.FONT_XTINY, "SET", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(COLOR_GAME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(344, 100, Graphics.FONT_XTINY, "GAME", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawOpponentScore(dc, centerX, state) {
        var scoreColor = state.matchFinished && state.matchWinner != 2 ?
            COLOR_DIM : Graphics.COLOR_WHITE;
        var sideColor = state.matchFinished && state.matchWinner != 2 ? COLOR_DIM : null;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 142, 153, Graphics.FONT_XTINY, "OP");

        drawSideNumber(dc, 72, 153, state.opponentSets, sideColor == null ? COLOR_SET : sideColor);
        drawPointScore(dc, centerX, 153, _opponentScore, scoreColor);
        drawSideNumber(dc, 344, 153, state.opponentGames, sideColor == null ? COLOR_GAME : sideColor);

        if (!state.playerServing && !state.matchFinished) {
            drawServingSideMarkers(dc, OPPONENT_MARKER_LEFT_X, OPPONENT_MARKER_RIGHT_X, OPPONENT_MARKER_Y, state);
        }
    }

    function drawDivider(dc, width, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(48, SPLIT_Y - 3, width - 96, 6, 3);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, SPLIT_Y, 4);
    }

    function drawPlayerScore(dc, centerX, state) {
        var scoreColor = state.matchFinished && state.matchWinner != 1 ?
            COLOR_DIM : Graphics.COLOR_BLACK;
        var sideColor = state.matchFinished && state.matchWinner != 1 ? COLOR_DIM : Graphics.COLOR_BLACK;

        drawSideNumber(dc, 72, 270, state.playerSets, sideColor);
        drawPointScore(dc, centerX, 270, _playerScore, scoreColor);
        drawSideNumber(dc, 344, 270, state.playerGames, sideColor);

        if (!state.matchFinished) {
            dc.setColor(COLOR_SET, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(57, 324, 30, 4, 2);
            dc.setColor(COLOR_GAME, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(329, 324, 30, 4, 2);
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, 300, 332, Graphics.FONT_XTINY, "ME");

        if (state.playerServing && !state.matchFinished) {
            drawServingSideMarkers(dc, PLAYER_MARKER_LEFT_X, PLAYER_MARKER_RIGHT_X, PLAYER_MARKER_Y, state);
        }
    }

    function drawSideNumber(dc, x, centerY, value, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, x, centerY, Graphics.FONT_NUMBER_MILD, value.toString());
    }

    function drawPointScore(dc, x, centerY, score, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        drawCenteredText(dc, x, centerY, scoreFont(dc, score), score);
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
        drawCenteredText(dc, centerX, 373, Graphics.FONT_XTINY, text);
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
        drawCenteredText(dc, centerX, centerY, Graphics.FONT_SMALL, _noticeText);
    }

    function drawCenteredText(dc, x, centerY, font, text) {
        dc.drawText(
            x,
            centerY - (dc.getFontHeight(font) / 2),
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

    function scoreFont(dc, score) {
        if (score == "AD" || score == "WIN" || score == "END") {
            return Graphics.FONT_LARGE;
        }

        var font = Graphics.FONT_NUMBER_MEDIUM;
        var dimensions = dc.getTextDimensions(score, font);

        if (dimensions[0] > 150) {
            return Graphics.FONT_NUMBER_MILD;
        }

        return font;
    }
}
