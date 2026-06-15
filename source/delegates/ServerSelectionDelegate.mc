using Toybox.WatchUi;

class ServerSelectionDelegate extends WatchUi.Menu2InputDelegate {
    var _settings;

    function initialize(settings) {
        Menu2InputDelegate.initialize();
        _settings = settings.clone();
    }

    function onSelect(item) {
        var id = item.getId();
        var playerServesFirst = id.equals("me");
        var engine = new ScoringEngine(_settings, playerServesFirst);
        var view = new TennisMatchView(engine);

        PersistenceManager.saveMatch(engine);
        WatchUi.pushView(view, new TennisMatchDelegate(engine, view), WatchUi.SLIDE_LEFT);
    }
}
