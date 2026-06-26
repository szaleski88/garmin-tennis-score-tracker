using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {
    static const SCREEN_SPLIT_Y = 208;

    var _engine;
    var _view;
    var _exitConfirmationOpen;
    var _statsConfirmationOpen;
    var _statsTimer;

    function initialize(engine, view) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _view = view;
        _exitConfirmationOpen = false;
        _statsConfirmationOpen = false;
        _statsTimer = new Timer.Timer();
    }

    // --- Screen Taps ---
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        if (coords[1] < SCREEN_SPLIT_Y) {
            return scoreOpponentPoint();
        }
        return scorePlayerPoint();
    }

    // --- Raw Swipes ---
    function onSwipe(swipeEvent) {
        return handleSwipe(swipeEvent.getDirection());
    }

    // --- Native Horizontal Swipe Behaviors ---
    function onPreviousMode() {
        return handleSwipe(WatchUi.SWIPE_RIGHT);
    }

    function onNextMode() {
        return handleSwipe(WatchUi.SWIPE_LEFT);
    }

    function handleSwipe(direction) {
        if (direction == WatchUi.SWIPE_RIGHT) {
            return showExitConfirmation();
        } else if (direction == WatchUi.SWIPE_LEFT) {
            return undoPoint();
        } else if (direction == WatchUi.SWIPE_DOWN) {
            return redoPoint();
        } else if (direction == WatchUi.SWIPE_UP) {
            // Mapping Swipe Up to Undo as well for extra forgiveness
            return undoPoint();
        }

        return false;
    }

    // --- Native Swipe Behaviors (Fallbacks if Garmin ignores raw swipe) ---
    function onPreviousPage() {
        // Garmin natively maps Swipe Down to this
        return redoPoint();
    }

    function onNextPage() {
        // Garmin natively maps Swipe Up to this
        return undoPoint();
    }

    // --- Hardware Buttons ---
    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        // Explicitly catch Top Button
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            return scoreOpponentPoint();
        }

        if (key == WatchUi.KEY_MENU) {
            return undoPoint();
        }

        // Catch Bottom Button (if the OS passes it here before onBack)
        if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
            return scorePlayerPoint(); // FIX: Now scores for the player
        }

        return false;
    }

    // --- System Behaviors ---
    function onBack() {
        return scorePlayerPoint();
    }

    function onMenu() {
        return undoPoint();
    }

    // --- Game Actions ---
    function undoPoint() {
        if (_engine.undo()) {
            _view.requestRedraw();
        }
        return true;
    }

    function redoPoint() {
        var wasFinished = _engine.getState().matchFinished;

        if (_engine.redo()) {
            _view.requestRedraw();

            if (!wasFinished && _engine.getState().matchFinished) {
                return showStatsConfirmation();
            }
        }
        return true;
    }

    function scoreOpponentPoint() {
        return scorePoint(false);
    }

    function scorePlayerPoint() {
        return scorePoint(true);
    }

    function scorePoint(playerWonPoint) {
        var result = playerWonPoint ? _engine.scorePlayer() : _engine.scoreOpponent();
        _view.requestRedraw();

        if (result == MatchResult.SIDE_SWAP) {
            _view.showNotice("SWITCH SIDES");
        } else if (result == MatchResult.MATCH) {
            return showStatsConfirmation();
        }

        return true;
    }

    function exitConfirmationClosed() {
        _exitConfirmationOpen = false;
    }

    function statsConfirmationClosed(showStats) {
        _statsConfirmationOpen = false;

        if (showStats) {
            _statsTimer.stop();
            _statsTimer.start(method(:showStatsView), 250, false);
            return;
        }

        if (_engine.undo()) {
            _view.requestRedraw();
        }
    }

    function showStatsView() {
        WatchUi.pushView(
            new MatchStatsView(_engine),
            new MatchStatsDelegate(),
            WatchUi.SLIDE_LEFT
        );
    }

    function showExitConfirmation() {
        if (_exitConfirmationOpen) {
            return true;
        }

        _exitConfirmationOpen = true;

        WatchUi.pushView(
            new WatchUi.Confirmation("Exit Match?"),
            new ExitMatchConfirmationDelegate(self),
            WatchUi.SLIDE_RIGHT
        );

        return true;
    }

    function showStatsConfirmation() {
        if (_statsConfirmationOpen) {
            return true;
        }

        _statsConfirmationOpen = true;

        WatchUi.pushView(
            new WatchUi.Confirmation("Show Stats?"),
            new MatchStatsConfirmationDelegate(self),
            WatchUi.SLIDE_LEFT
        );

        return true;
    }
}

class ExitMatchConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    var _matchDelegate;

    function initialize(matchDelegate) {
        ConfirmationDelegate.initialize();
        _matchDelegate = matchDelegate;
    }

    function onResponse(response) {
        if (_matchDelegate != null) {
            _matchDelegate.exitConfirmationClosed();
        }

        if (response == WatchUi.CONFIRM_YES) {
            System.exit();
        }
        // FIX: Removed the manual popView. Garmin auto-dismisses Confirmations!
        return true;
    }
}

class MatchStatsConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    var _matchDelegate;

    function initialize(matchDelegate) {
        ConfirmationDelegate.initialize();
        _matchDelegate = matchDelegate;
    }

    function onResponse(response) {
        if (_matchDelegate != null) {
            _matchDelegate.statsConfirmationClosed(response == WatchUi.CONFIRM_YES);
        }

        return true;
    }
}
