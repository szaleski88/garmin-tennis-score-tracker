using Toybox.WatchUi;

class MatchStatsDelegate extends WatchUi.BehaviorDelegate {
    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();

        if (coords[0] >= 292 && coords[1] <= 112) {
            return closeStats();
        }

        return true;
    }

    function onSwipe(swipeEvent) {
        return handleSwipe(swipeEvent.getDirection());
    }

    function onNextPage() {
        _view.nextPage();
        return true;
    }

    function onPreviousPage() {
        _view.previousPage();
        return true;
    }

    function onPreviousMode() {
        return closeStats();
    }

    function onBack() {
        return closeStats();
    }

    function handleSwipe(direction) {
        if (direction == WatchUi.SWIPE_UP) {
            _view.nextPage();
            return true;
        }

        if (direction == WatchUi.SWIPE_DOWN) {
            _view.previousPage();
            return true;
        }

        if (direction == WatchUi.SWIPE_RIGHT) {
            return closeStats();
        }

        return true;
    }

    function closeStats() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
