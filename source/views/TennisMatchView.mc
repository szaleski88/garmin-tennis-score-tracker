using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class TennisMatchView extends WatchUi.View {
    static const SPLIT_Y = 208;
    static const COLOR_PANEL = 0x050505;
    static const COLOR_PANEL_HI = 0x0B0F0A;
    static const COLOR_LINE = 0x2A2A2A;
    static const COLOR_MUTED = 0x8A8A8A;
    static const COLOR_DIM = 0x4D4D4D;
    static const COLOR_BALL = 0xC8F03D;
    static const COLOR_PLAYER = 0x35D990;
    static const COLOR_OPPONENT = 0xF4B45E;
    static const COLOR_WARNING = 0xFF6F4A;

    var _engine;
    var _ball;
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
        var state = _engine.getState();
        var settings = _engine.getSettings();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawStatus(dc, width);
        drawHeader(dc, centerX, state, settings);

        drawScoreZone(
            dc,
            width,
            centerX,
            86,
            104,
            "OPPONENT",
            _opponentScore,
            !state.playerServing && !state.matchFinished,
            false,
            state.matchFinished && state.matchWinner == 2,
            state.matchFinished
        );

        drawDivider(dc, width);

        drawScoreZone(
            dc,
            width,
            centerX,
            226,
            114,
            "ME",
            _playerScore,
            state.playerServing && !state.matchFinished,
            true,
            state.matchFinished && state.matchWinner == 1,
            state.matchFinished
        );

        drawFooter(dc, height, centerX, state);
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

        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(34, 8, Graphics.FONT_XTINY, time, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(width - 34, 8, Graphics.FONT_XTINY, battery, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawHeader(dc, centerX, state, settings) {
        var summaryText = matchSummaryText(state, settings);
        var stageText = stageBadgeText(state);
        var stageColor = stageBadgeColor(state);

        dc.setColor(COLOR_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            36,
            Graphics.FONT_XTINY,
            summaryText,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(stageColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(centerX - 37, 54, 74, 20, 10);
        dc.drawText(
            centerX,
            57,
            Graphics.FONT_XTINY,
            stageText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawDivider(dc, width) {
        dc.setColor(COLOR_LINE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(
            90,
            SPLIT_Y - 1,
            width - 180,
            2,
            1
        );

        dc.setColor(COLOR_BALL, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(width / 2, SPLIT_Y, 6);
    }

    function drawScoreZone(
        dc,
        width,
        centerX,
        y,
        height,
        label,
        score,
        isServing,
        isPlayer,
        isWinner,
        isFinished
    ) {
        var x = 44;
        var panelWidth = width - (x * 2);

        var accent = isPlayer ? COLOR_PLAYER : COLOR_OPPONENT;

        var border = COLOR_LINE;
        var scoreColor = Graphics.COLOR_WHITE;
        var labelColor = COLOR_MUTED;

        if (isServing) {
            border = COLOR_BALL;
            labelColor = accent;
        }

        if (isWinner) {
            border = accent;
            labelColor = accent;
            scoreColor = accent;
        } else if (isFinished) {
            scoreColor = COLOR_DIM;
        }

        dc.setColor(
            (isServing || isWinner) ? COLOR_PANEL_HI : COLOR_PANEL,
            Graphics.COLOR_TRANSPARENT
        );

        dc.fillRoundedRectangle(
            x,
            y,
            panelWidth,
            height,
            20
        );

        dc.setPenWidth(isWinner ? 3 : ((isServing) ? 2 : 1));

        dc.setColor(border, Graphics.COLOR_TRANSPARENT);

        dc.drawRoundedRectangle(
            x,
            y,
            panelWidth,
            height,
            20
        );

        dc.setPenWidth(1);

        dc.setColor(labelColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            y + 13,
            Graphics.FONT_TINY,
            label,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (isServing) {
            dc.setColor(COLOR_BALL, Graphics.COLOR_TRANSPARENT);

            dc.fillCircle(
                centerX - 55,
                y + 20,
                5
            );
        }

        var font = scoreFont(score);

        var scoreY = y + 58 - (Graphics.getFontHeight(font) / 2);

        dc.setColor(scoreColor, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            scoreY,
            font,
            score,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawFooter(dc, height, centerX, state) {
        var text = footerText(state);
        var color = footerColor(state);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - 55, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function matchSummaryText(state, settings) {
        if (settings.matchFormat == MatchFormat.STB_MATCH) {
            return "SUPER TB MATCH";
        }

        if (settings.matchFormat == MatchFormat.TB_MATCH) {
            return "TIE-BREAK MATCH";
        }

        if (state.stage == StageType.SUPER_TIE_BREAK) {
            return "SETS " + state.playerSets + "-" + state.opponentSets + "   SUPER TB";
        }

        return "SETS " + state.playerSets + "-" + state.opponentSets +
            "   GAMES " + state.playerGames + "-" + state.opponentGames;
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

    function stageBadgeColor(state) {
        if (state.matchFinished) {
            if (state.matchWinner == 1) {
                return COLOR_PLAYER;
            }

            return COLOR_WARNING;
        }

        if (state.stage == StageType.TIE_BREAK || state.stage == StageType.SUPER_TIE_BREAK) {
            return COLOR_OPPONENT;
        }

        if (state.stage == StageType.GOLDEN_GAME) {
            return COLOR_WARNING;
        }

        return COLOR_BALL;
    }

    function footerText(state) {
        if (state.matchFinished) {
            if (state.matchWinner == 1) {
                return "✓ MATCH WON";
            }

            return "✕ MATCH LOST";
        }

        if (_detail == "Me serving") {
            return "● ME SERVING";
        }

        if (_detail == "Opponent serving") {
            return "● OPPONENT SERVING";
        }

        return _detail;
    }

    function footerColor(state) {
        if (state.matchFinished) {
            if (state.matchWinner == 1) {
                return COLOR_PLAYER;
            }

            return COLOR_WARNING;
        }

        if (_detail == "GOLDEN POINT") {
            return COLOR_WARNING;
        }

        return COLOR_MUTED;
    }

    function scoreFont(score) {
        if (score == "AD" || score == "WIN" || score == "END") {
            return Graphics.FONT_LARGE;
        }

        return Graphics.FONT_NUMBER_HOT;
    }
}
