using Toybox.WatchUi;

class MatchPauseDelegate extends WatchUi.BehaviorDelegate {
    var _engine;
    var _matchDelegate;

    function initialize(engine, matchDelegate) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _matchDelegate = matchDelegate;
    }

    function onTap(clickEvent) {
        var y = clickEvent.getCoordinates()[1];

        if (y >= 124 && y <= 198) {
            return resumeMatch();
        }

        if (y >= 199 && y <= 274) {
            return showStats();
        }

        if (y >= 275 && y <= 342) {
            return showExitConfirmation();
        }

        return true;
    }

    function onBack() {
        return resumeMatch();
    }

    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_UP || direction == WatchUi.SWIPE_RIGHT) {
            return resumeMatch();
        }

        return true;
    }

    function onNextPage() {
        return resumeMatch();
    }

    function onPreviousMode() {
        return resumeMatch();
    }

    function showStats() {
        var view = new MatchStatsView(_engine);
        WatchUi.pushView(view, new MatchStatsDelegate(view), WatchUi.SLIDE_LEFT);
        return true;
    }

    function showExitConfirmation() {
        WatchUi.pushView(
            new ExitMatchView(),
            new ExitMatchDelegate(),
            WatchUi.SLIDE_LEFT
        );
        return true;
    }

    function resumeMatch() {
        if (_matchDelegate != null) {
            _matchDelegate.pauseMenuClosed();
        }

        WatchUi.popView(WatchUi.SLIDE_UP);
        return true;
    }
}
