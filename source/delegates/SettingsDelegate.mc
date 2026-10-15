using Toybox.WatchUi;

class SettingsDelegate extends WatchUi.Menu2InputDelegate {
    var _settings;
    var _original;

    function initialize(settings, original) {
        Menu2InputDelegate.initialize();
        _settings = settings;
        _original = original;
    }

    function onSelect(item) {
        var id = item.getId();

        if (id.equals("format")) {
            cycleFormat();
            redraw();
        } else if (id.equals("final")) {
            cycleFinalSet();
            redraw();
        } else if (id.equals("golden")) {
            _settings.goldenPoint = !_settings.goldenPoint;
            redraw();
        } else if (id.equals("games")) {
            if (_settings.gamesInSet == 6) {
                RuleFactory.applyShortSets(_settings);
            } else {
                RuleFactory.applyStandardSets(_settings);
            }
            redraw();
        } else if (id.equals("tieBreakAt")) {
            _settings.tieBreakAt = _settings.tieBreakAt == 6 ? 3 : 6;
            redraw();
        } else if (id.equals("save")) {
            PersistenceManager.saveSettings(_settings);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else if (id.equals("discard")) {
            restoreOriginal();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

    function restoreOriginal() {
        _settings.matchFormat = _original.matchFormat;
        _settings.bestOfSets = _original.bestOfSets;
        _settings.gamesInSet = _original.gamesInSet;
        _settings.tieBreakAt = _original.tieBreakAt;
        _settings.goldenPoint = _original.goldenPoint;
        _settings.finalSetMode = _original.finalSetMode;
    }

    function cycleFormat() {
        if (_settings.matchFormat == MatchFormat.BEST_OF_3) {
            RuleFactory.applyBestOf5(_settings);
        } else if (_settings.matchFormat == MatchFormat.BEST_OF_5) {
            RuleFactory.applySuperTieBreakMatch(_settings);
        } else if (_settings.matchFormat == MatchFormat.STB_MATCH) {
            RuleFactory.applyTieBreakMatch(_settings);
        } else {
            RuleFactory.applyBestOf3(_settings);
        }
    }

    function cycleFinalSet() {
        if (_settings.finalSetMode == FinalSetMode.STB) {
            _settings.finalSetMode = FinalSetMode.TB;
        } else if (_settings.finalSetMode == FinalSetMode.TB) {
            _settings.finalSetMode = FinalSetMode.FULL_SET;
        } else {
            _settings.finalSetMode = FinalSetMode.STB;
        }
    }

    function redraw() {
        WatchUi.switchToView(
            new SettingsView(_settings),
            new SettingsDelegate(_settings, _original),
            WatchUi.SLIDE_IMMEDIATE
        );
    }
}
