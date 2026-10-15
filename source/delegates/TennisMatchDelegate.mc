using Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {
    static const SCREEN_SPLIT_Y = 208;

    var _engine;
    var _view;
    var _pauseMenuOpen;
    var _statsConfirmationOpen;

    function initialize(engine, view) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _view = view;
        _pauseMenuOpen = false;
        _statsConfirmationOpen = false;
    }

    // --- Screen Taps ---
    function onTap(clickEvent) {
        if (_view.hasNotice()) {
            return true;
        }
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
        if (_view.hasNotice()) {
            return true;
        }
        if (direction == WatchUi.SWIPE_RIGHT || direction == WatchUi.SWIPE_DOWN) {
            return showPauseMenu();
        } else if (direction == WatchUi.SWIPE_LEFT) {
            return undoPoint();
        } else if (direction == WatchUi.SWIPE_UP) {
            // Mapping Swipe Up to Undo as well for extra forgiveness
            return undoPoint();
        }

        return false;
    }

    // --- Native Swipe Behaviors (Fallbacks if Garmin ignores raw swipe) ---
    function onPreviousPage() {
        if (_view.hasNotice()) {
            return true;
        }
        // Garmin natively maps Swipe Down to this
        return showPauseMenu();
    }

    function onNextPage() {
        if (_view.hasNotice()) {
            return true;
        }
        // Garmin natively maps Swipe Up to this
        return undoPoint();
    }

    // --- Hardware Buttons ---
    function onKey(keyEvent) {
        if (_view.hasNotice()) {
            return true;
        }
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
        if (_view.hasNotice()) {
            return true;
        }
        return scorePlayerPoint();
    }

    function onMenu() {
        if (_view.hasNotice()) {
            return true;
        }
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

    function pauseMenuClosed() {
        _pauseMenuOpen = false;
    }

    function finishedResultClosedAfterUndo() {
        _statsConfirmationOpen = false;
        if (_engine.undo()) {
            _view.requestRedraw();
        }
    }

    function showPauseMenu() {
        if (_pauseMenuOpen) {
            return true;
        }

        _pauseMenuOpen = true;

        WatchUi.pushView(
            new MatchPauseView(_engine),
            new MatchPauseDelegate(_engine, self),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }

    function showStatsConfirmation() {
        if (_statsConfirmationOpen) {
            return true;
        }

        _statsConfirmationOpen = true;

        WatchUi.pushView(new MatchFinishedView(_engine), new MatchFinishedDelegate(_engine, self), WatchUi.SLIDE_LEFT);

        return true;
    }
}
