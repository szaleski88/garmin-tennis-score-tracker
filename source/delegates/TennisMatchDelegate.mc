using Toybox.System;
using Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.InputDelegate {
    var _engine;
    var _view;
    var _backDownAt;
    var _suppressBack;

    function initialize(engine, view) {
        InputDelegate.initialize();
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
            _engine.scorePlayer();
            _view.requestRedraw();
            return true;
        }

        if (isBackKey(key)) {
            if (_suppressBack) {
                _suppressBack = false;
                return true;
            }

            _engine.undo();
            _view.requestRedraw();
            return true;
        }

        return false;
    }

    function onKeyPressed(keyEvent) {
        if (isBackKey(keyEvent.getKey())) {
            _backDownAt = System.getTimer();
            return true;
        }

        return false;
    }

    function onKeyReleased(keyEvent) {
        if (isBackKey(keyEvent.getKey()) && _backDownAt != null) {
            var held = System.getTimer() - _backDownAt;
            _backDownAt = null;

            if (held >= 900) {
                _suppressBack = true;
                showExitConfirmation();
                return true;
            }
        }

        return false;
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
