using Toybox.WatchUi;

class RulesConfirmationDelegate extends WatchUi.Menu2InputDelegate {
    var _settings;
    var _playerServesFirst;

    function initialize(settings, playerServesFirst) {
        Menu2InputDelegate.initialize();
        _settings = settings.clone();
        _playerServesFirst = playerServesFirst;
    }

    function onSelect(item) {
        var id = item.getId();

        if (id.equals("start")) {
            startMatch();
        } else if (id.equals("cancel")) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        return true;
    }

    function startMatch() {
        var engine = new ScoringEngine(_settings, _playerServesFirst);
        var view = new TennisMatchView(engine);

        PersistenceManager.saveMatch(engine);
        WatchUi.pushView(view, new TennisMatchDelegate(engine, view), WatchUi.SLIDE_LEFT);
    }
}
