using Toybox.WatchUi;

class MatchFinishedDelegate extends WatchUi.BehaviorDelegate {
    var _engine;
    var _matchDelegate;

    function initialize(engine, matchDelegate) {
        BehaviorDelegate.initialize();
        _engine = engine;
        _matchDelegate = matchDelegate;
    }

    function onTap(clickEvent) {
        var coordinates = clickEvent.getCoordinates();
        var x = coordinates[0];
        var y = coordinates[1];

        if (x >= 56 && x <= 360 && y >= 230 && y <= 310) {
            return showStats();
        }

        if (x >= 90 && x <= 326 && y >= 302 && y <= 354) {
            return exitToMenu();
        }

        if (x >= 112 && x <= 304 && y >= 350 && y <= 402) {
            return undoMatchPoint();
        }

        return true;
    }

    function onBack() {
        return exitToMenu();
    }

    function onPreviousMode() {
        return exitToMenu();
    }

    function showStats() {
        var view = new MatchStatsView(_engine);
        WatchUi.pushView(view, new MatchStatsDelegate(view), WatchUi.SLIDE_LEFT);
        return true;
    }

    function exitToMenu() {
        WatchUi.switchToView(new MainMenuView(), new TennisMenuDelegate(), WatchUi.SLIDE_RIGHT);
        return true;
    }

    function undoMatchPoint() {
        if (_matchDelegate != null) {
            _matchDelegate.finishedResultClosedAfterUndo();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }

        if (_engine.undo()) {
            var view = new TennisMatchView(_engine);
            WatchUi.switchToView(view, new TennisMatchDelegate(_engine, view), WatchUi.SLIDE_RIGHT);
        }
        return true;
    }
}
