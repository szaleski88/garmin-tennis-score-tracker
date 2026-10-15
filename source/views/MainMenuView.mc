using Toybox.WatchUi;

class MainMenuView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Tennis Score"});

        if (PersistenceManager.hasSavedMatch()) {
            var snapshot = PersistenceManager.loadMatch();

            if (snapshot != null && snapshot.state.matchFinished) {
                addItem(new MenuItem("View Last Match", ScoreFormatter.summary(snapshot.state, snapshot.settings), "resume", {}));
            } else if (snapshot != null) {
                addItem(new MenuItem("Resume Match", ScoreFormatter.summary(snapshot.state, snapshot.settings), "resume", {}));
            }
        }

        addItem(new MenuItem("Start Match", null, "start", {}));
        addItem(new MenuItem("Settings", null, "settings", {}));
    }
}
