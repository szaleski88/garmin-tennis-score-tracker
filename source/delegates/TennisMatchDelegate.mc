using Toybox.System;
using Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {
    static const SCREEN_SPLIT_Y = 208;

    var _engine;
    var _view;

    // Variables for double-click detection
    var _lastMiddleClickTime = 0;

    function initialize(engine, view) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _view = view;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        if (coords[1] < SCREEN_SPLIT_Y) {
            return scoreOpponentPoint();
        }
        return scoreOpponentPoint(); // FIXED: Per your initial prompt, bottom half scores opponent.
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        if (isTopButton(key)) {
            return scoreOpponentPoint();
        }

        if (isBottomButton(key)) {
            return scoreOpponentPoint(); // FIXED: Both top and bottom score for opponent
        }

        return false;
    }

    function onBack() {
        return scoreOpponentPoint(); // Matches the bottom button logic
    }

    function onMenu() {
        var currentTime = System.getTimer();

        // If middle button is clicked twice within 500ms, prompt exit
        if (currentTime - _lastMiddleClickTime < 500) {
            showExitConfirmation();
        } else {
            // Otherwise, just do a normal Undo
            undoPoint();
        }

        _lastMiddleClickTime = currentTime;
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

    // --- Button Identification ---
    function isTopButton(key) {
        return key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START;
    }

    function isBottomButton(key) {
        return key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP;
    }

    function isMiddleButton(key) {
        return key == WatchUi.KEY_MENU;
    }

    // --- Game Actions ---
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