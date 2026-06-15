using Toybox.WatchUi;

class SettingsView extends WatchUi.Menu2 {
    var settings;

    function initialize(matchSettings) {
        settings = matchSettings;
        Menu2.initialize({:title=>"Settings"});
        rebuild();
    }

    function rebuild() {
        addItem(new MenuItem("Match Format", ScoreFormatter.formatLabel(settings), "format", {}));
        addItem(new MenuItem("Final Set", ScoreFormatter.finalSetLabel(settings), "final", {}));
        addItem(new MenuItem("Golden Point", settings.goldenPoint ? "On" : "Off", "golden", {}));
        addItem(new MenuItem("Set Games", settings.gamesInSet.toString(), "games", {}));
        addItem(new MenuItem("Tie Break At", settings.tieBreakAt.toString(), "tieBreakAt", {}));
        addItem(new MenuItem("Save", null, "save", {}));
        addItem(new MenuItem("Discard", null, "discard", {}));
    }
}
