using Toybox.System;
using Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {
    static const SCREEN_SPLIT_Y = 208;

    var _engine;
    var _view;

    function initialize(engine, view) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _view = view;
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
        // Venu lower-button Back/ESC should score the player and never pop the match view.
        return scorePlayerPoint();
    }

    function onMenu() {
        return undoPoint();
    }

    // --- Game Actions ---
    function undoPoint() {
        _engine.undo();
        _view.requestRedraw();
        return true;
    }

    function redoPoint() {
        if (_engine has :redo) {
            _engine.redo();
            _view.requestRedraw();
        }
        return true;
    }

    function scoreOpponentPoint() {
        _engine.scoreOpponent();
        _view.requestRedraw();
        return true;
    }

    function scorePlayerPoint() {
        _engine.scorePlayer();
        _view.requestRedraw();
        return true;
    }

    function showExitConfirmation() {
        WatchUi.pushView(
            new WatchUi.Confirmation("Exit Match?"),
            new ExitMatchConfirmationDelegate(),
            WatchUi.SLIDE_RIGHT
        );

        return true;
    }
}

class ExitMatchConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            System.exit();
        }
        // FIX: Removed the manual popView. Garmin auto-dismisses Confirmations!
        return true;
    }
}
