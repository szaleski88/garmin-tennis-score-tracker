using Toybox.WatchUi;

class MainMenuView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Tennis Score"});

        if (PersistenceManager.hasSavedMatch()) {
            addItem(new MenuItem("Resume Match", null, "resume", {}));
        }

        addItem(new MenuItem("Start Match", null, "start", {}));
        addItem(new MenuItem("Settings", null, "settings", {}));
    }
}
