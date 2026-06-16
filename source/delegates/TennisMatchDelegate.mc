using Toybox.System;
using Toybox.WatchUi;
using Toybox.Timer; // Required for the hold timer

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {
    static const SCREEN_SPLIT_Y = 208;

    var _engine;
    var _view;

    // Timer variables for the middle button
    var _middleButtonTimer;
    var _middleButtonHoldTriggered = false;

    function initialize(engine, view) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _view = view;
        _middleButtonTimer = new Timer.Timer();
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        if (coords[1] < SCREEN_SPLIT_Y) {
            return scoreOpponentPoint();
        }
        return scorePlayerPoint();
    }

    // Triggered when a button is physically pressed down
    function onKeyPressed(keyEvent) {
        if (isMiddleButton(keyEvent.getKey())) {
            _middleButtonHoldTriggered = false;
            // Start 3-second timer
            _middleButtonTimer.start(method(:onMiddleButtonHeld), 3000, false);
            return true;
        }
        return false;
    }

    // Triggered when a button is physically released
    function onKeyReleased(keyEvent) {
        if (isMiddleButton(keyEvent.getKey())) {
            _middleButtonTimer.stop();

            // If released before 3 seconds, treat it as a standard click (Undo)
            if (!_middleButtonHoldTriggered) {
                return undoPoint();
            }
            return true; // Consume the release event if hold was triggered
        }
        return false;
    }

    // Standard short-press fallback for Top/Bottom buttons
    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        if (isTopButton(key)) {
            return scoreOpponentPoint();
        }

        if (isBottomButton(key)) {
            // NOTE: Change to scoreOpponentPoint() if the prompt wasn't a typo!
            return scorePlayerPoint();
        }

        return false;
    }

    // Fallback for standard behavior events
    function onBack() {
        return scorePlayerPoint();
    }

    function onMenu() {
        // Returning true prevents default OS menu, but we handle logic in onKeyReleased now
        return true;
    }

    function onSelect() {
        return false;
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
            showExitConfirmation();
            return true;
        }
        return false;
    }

    // Button identification helpers
    function isTopButton(key) {
        return key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START;
    }

    function isBottomButton(key) {
        return key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP;
    }

    function isMiddleButton(key) {
        return key == WatchUi.KEY_MENU;
    }

    // Actions
    function undoPoint() {
        _engine.undo();
        _view.requestRedraw();
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

    // 3-Second Hold Callback
    function onMiddleButtonHeld() {
        _middleButtonHoldTriggered = true;
        System.exit(); // Exits immediately as requested. Swap with showExitConfirmation() if you want a prompt first.
    }

    function showExitConfirmation() {
        WatchUi.pushView(
            new WatchUi.Confirmation("Exit Match?"),
            new ExitMatchConfirmationDelegate(),
            WatchUi.SLIDE_RIGHT
        );
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
        WatchUi.popView(WatchUi.SLIDE_LEFT);
        return true;
    }
}