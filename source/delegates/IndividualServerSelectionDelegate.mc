using Toybox.WatchUi;

class IndividualServerSelectionDelegate extends WatchUi.Menu2InputDelegate {
    var _settings;
    var _playerServesFirst;

    function initialize(settings, playerServesFirst) {
        Menu2InputDelegate.initialize();
        _settings = settings;
        _playerServesFirst = playerServesFirst;
    }

    function onSelect(item) {
        var first = item.getId().equals("first");
        var server;

        if (_playerServesFirst) {
            server = first ? PlayerId.ME : PlayerId.PARTNER;
        } else {
            server = first ? PlayerId.OP_1 : PlayerId.OP_2;
        }

        WatchUi.pushView(
            new RulesConfirmationView(_settings, _playerServesFirst, server),
            new RulesConfirmationDelegate(_settings, _playerServesFirst, server),
            WatchUi.SLIDE_LEFT
        );
    }
}
