using Toybox.WatchUi;

class RulesConfirmationView extends WatchUi.Menu2 {
    function initialize(settings, playerServesFirst) {
        var rules = settings.clone();

        Menu2.initialize({:title=>"Confirm Rules"});

        addItem(new MenuItem("Start Match", null, "start", {}));
        addItem(new MenuItem("Server", playerServesFirst ? "Me" : "Opponent", "server", {}));
        addItem(new MenuItem("Format", ScoreFormatter.formatLabel(rules), "format", {}));
        addItem(new MenuItem("Scoring", rules.goldenPoint ? "No-Ad" : "Advantage", "scoring", {}));

        if (rules.matchFormat == MatchFormat.STB_MATCH) {
            addItem(new MenuItem("Target", "10 by 2", "target", {}));
        } else if (rules.matchFormat == MatchFormat.TB_MATCH) {
            addItem(new MenuItem("Target", "7 by 2", "target", {}));
        } else {
            addItem(new MenuItem("Games/Set", rules.gamesInSet.toString(), "games", {}));
            addItem(new MenuItem("Tie Break At", rules.tieBreakAt.toString(), "tieBreakAt", {}));
            addItem(new MenuItem("Final Set", ScoreFormatter.finalSetLabel(rules), "final", {}));
        }

        addItem(new MenuItem("Cancel", null, "cancel", {}));
    }
}
