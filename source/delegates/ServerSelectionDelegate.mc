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

        WatchUi.pushView(
            new RulesConfirmationView(_settings, playerServesFirst),
            new RulesConfirmationDelegate(_settings, playerServesFirst),
            WatchUi.SLIDE_LEFT
        );
    }
}
