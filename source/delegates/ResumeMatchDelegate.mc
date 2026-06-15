using Toybox.WatchUi;

class ResumeMatchDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();

        if (id.equals("resume")) {
            var snapshot = PersistenceManager.loadMatch();

            if (snapshot != null) {
                var engine = ScoringEngine.resume(snapshot);
                var view = new TennisMatchView(engine);
                WatchUi.switchToView(view, new TennisMatchDelegate(engine, view), WatchUi.SLIDE_LEFT);
            } else {
                WatchUi.switchToView(new MainMenuView(), new TennisMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (id.equals("discard")) {
            PersistenceManager.clearMatch();
            WatchUi.switchToView(new MainMenuView(), new TennisMenuDelegate(), WatchUi.SLIDE_RIGHT);
        }
    }
}
