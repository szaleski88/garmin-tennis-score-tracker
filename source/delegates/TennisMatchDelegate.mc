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

    // --- Touch & Swipe Handling ---
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();

        // Top half of the screen
        if (coords[1] < SCREEN_SPLIT_Y) {
            return scoreOpponentPoint();
        }

        // Bottom half of the screen
        return scorePlayerPoint();
    }

    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_RIGHT) {
            showExitConfirmation();
            return true;
        } else if (direction == WatchUi.SWIPE_LEFT) {
            return undoPoint();
        } else if (direction == WatchUi.SWIPE_DOWN) {
            return redoPoint();
        }

        return false;
    }

    // --- Hardware Button Short Presses ---
    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        // Both top and bottom buttons score for the opponent
        if (isTopButton(key) || isBottomButton(key)) {
            return scoreOpponentPoint();
        }

        return false;
    }

    // --- System Fallbacks ---
    function onBack() {
        // Consume the back event to prevent an accidental native exit
        return true;
    }

    function onMenu() {
        // Consume the menu event to prevent native menu bleed-through on a short middle-button press
        return true;
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

    function redoPoint() {
        // Safety check to ensure the engine supports redo
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