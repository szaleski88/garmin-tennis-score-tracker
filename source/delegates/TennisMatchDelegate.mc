using Toybox.System;
using Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {
    static const HOLD_TO_MENU_MS = 3000;

    var _engine;
    var _view;
    var _backDownAt;
    var _suppressBack;

    function initialize(engine, view) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _view = view;
        _backDownAt = null;
        _suppressBack = false;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();

        if (coords[1] < 208) {
            _engine.scoreOpponent();
        } else {
            _engine.scorePlayer();
        }

        _view.requestRedraw();
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            return scorePlayerPoint();
        }

        if (isBackKey(key)) {
            return handleBackRelease(true);
        }

        return false;
    }

    function onKeyPressed(keyEvent) {
        if (isBackKey(keyEvent.getKey())) {
            _backDownAt = System.getTimer();
            _suppressBack = false;
            return true;
        }

        return false;
    }

    function onKeyReleased(keyEvent) {
        if (isBackKey(keyEvent.getKey())) {
            return handleBackRelease(true);
        }

        return false;
    }

    function onBack() {
        return handleBackRelease(true);
    }

    function onSelect() {
        return scorePlayerPoint();
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
            showExitConfirmation();
            return true;
        }

        return false;
    }

    function isBackKey(key) {
        return key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP;
    }

    function handleBackRelease(suppressDuplicate) {
        if (_suppressBack) {
            _suppressBack = false;
            _backDownAt = null;
            return true;
        }

        if (_backDownAt != null) {
            var held = System.getTimer() - _backDownAt;
            _backDownAt = null;

            if (suppressDuplicate) {
                _suppressBack = true;
            }

            if (held >= HOLD_TO_MENU_MS) {
                returnToMenu();
                return true;
            }
        }

        undoPoint();
        return true;
    }

    function undoPoint() {
        _engine.undo();
        _view.requestRedraw();
    }

    function scorePlayerPoint() {
        _engine.scorePlayer();
        _view.requestRedraw();
        return true;
    }

    function returnToMenu() {
        WatchUi.switchToView(
            new MainMenuView(),
            new TennisMenuDelegate(),
            WatchUi.SLIDE_RIGHT
        );
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
