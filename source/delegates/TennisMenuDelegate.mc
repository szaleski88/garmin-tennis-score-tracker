using Toybox.WatchUi;

class TennisMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();

        if (id.equals("resume")) {
            openSavedMatch();
        } else if (id.equals("start")) {
            if (PersistenceManager.hasSavedMatch()) {
                WatchUi.pushView(
                    new ReplaceSavedMatchView(),
                    new ReplaceSavedMatchDelegate(),
                    WatchUi.SLIDE_LEFT
                );
            } else {
                openServerSelection();
            }
        } else if (id.equals("settings")) {
            var settings = PersistenceManager.loadSettings().clone();
            WatchUi.pushView(
                new SettingsView(settings),
                new SettingsDelegate(settings, settings.clone()),
                WatchUi.SLIDE_LEFT
            );
        }
    }

    function openSavedMatch() {
        var snapshot = PersistenceManager.loadMatch();

        if (snapshot == null) {
            WatchUi.switchToView(new MainMenuView(), new TennisMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return;
        }

        var engine = ScoringEngine.resume(snapshot);

        if (engine.getState().matchFinished) {
            WatchUi.pushView(
                new MatchFinishedView(engine),
                new MatchFinishedDelegate(engine, null),
                WatchUi.SLIDE_LEFT
            );
            return;
        }

        var view = new TennisMatchView(engine);
        WatchUi.pushView(view, new TennisMatchDelegate(engine, view), WatchUi.SLIDE_LEFT);
    }

    function openServerSelection() {
        WatchUi.pushView(
            new ServerSelectionView(),
            new ServerSelectionDelegate(PersistenceManager.loadSettings()),
            WatchUi.SLIDE_LEFT
        );
    }
}
