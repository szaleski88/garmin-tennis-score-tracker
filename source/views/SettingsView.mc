using Toybox.WatchUi;

class SettingsView extends WatchUi.Menu2 {
    var settings;

    function initialize(matchSettings) {
        settings = matchSettings;
        Menu2.initialize({:title=>"Settings"});
        rebuild();
    }

    function rebuild() {
        addItem(new MenuItem("Match format", ScoreFormatter.formatLabel(settings), "format", {}));

        if (settings.matchFormat != MatchFormat.STB_MATCH && settings.matchFormat != MatchFormat.TB_MATCH) {
            addItem(new MenuItem("Scoring", settings.goldenPoint ? "No-ad" : "Advantage", "golden", {}));
            addItem(new MenuItem("Games per set", settings.gamesInSet.toString(), "games", {}));
            addItem(new MenuItem("Tie-break at", settings.tieBreakAt.toString(), "tieBreakAt", {}));
            addItem(new MenuItem("Final set", ScoreFormatter.finalSetLabel(settings), "final", {}));
        }

        addItem(new MenuItem("Save changes", null, "save", {}));
        addItem(new MenuItem("Cancel", null, "discard", {}));
    }
}
