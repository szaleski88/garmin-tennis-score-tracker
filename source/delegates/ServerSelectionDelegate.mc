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

        if (_settings.trackPlays && playerServesFirst) {
            WatchUi.pushView(
                new IndividualServerSelectionView(true),
                new IndividualServerSelectionDelegate(_settings, true),
                WatchUi.SLIDE_LEFT
            );
            return;
        }

        var initialServer = playerServesFirst ? PlayerId.ME : PlayerId.OP_1;

        WatchUi.pushView(
            new RulesConfirmationView(_settings, playerServesFirst, initialServer),
            new RulesConfirmationDelegate(_settings, playerServesFirst, initialServer),
            WatchUi.SLIDE_LEFT
        );
    }
}
