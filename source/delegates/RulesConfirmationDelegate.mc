using Toybox.WatchUi;

class RulesConfirmationDelegate extends WatchUi.BehaviorDelegate {
    var _settings;
    var _playerServesFirst;
    var _initialServer;

    function initialize(settings, playerServesFirst, initialServer) {
        BehaviorDelegate.initialize();
        _settings = settings;
        _playerServesFirst = playerServesFirst;
        _initialServer = initialServer;
    }

    function onTap(clickEvent) {
        var coordinates = clickEvent.getCoordinates();
        var x = coordinates[0];
        var y = coordinates[1];

        if (x >= 64 && x <= 352 && y >= 276 && y <= 356) {
            return startMatch();
        }

        if (x >= 112 && x <= 304 && y >= 356 && y <= 404) {
            WatchUi.pushView(new SettingsView(_settings), new SettingsDelegate(_settings, _settings.clone()), WatchUi.SLIDE_LEFT);
            return true;
        }

        return true;
    }

    function onSelect() {
        return startMatch();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onPreviousMode() {
        return onBack();
    }

    function startMatch() {
        var engine = new ScoringEngine(_settings, _playerServesFirst, _initialServer);
        var view = new TennisMatchView(engine);

        PersistenceManager.saveMatch(engine);
        WatchUi.pushView(view, new TennisMatchDelegate(engine, view), WatchUi.SLIDE_LEFT);
        if (_settings.trackPlays) {
            view.showNotice(PlayerId.serveNotice(_initialServer));
        }
        return true;
    }
}
