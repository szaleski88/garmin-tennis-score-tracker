using Toybox.Application.Storage;

class PersistenceManager {
    static const KEY_SETTINGS = "settings";
    static const KEY_STATE = "match_state";
    static const KEY_HISTORY = "match_history";

    static function loadSettings() {
        var data = Storage.getValue(KEY_SETTINGS);
        return MatchSettings.fromDictionary(data);
    }

    static function saveSettings(settings) {
        Storage.setValue(KEY_SETTINGS, settings.toDictionary());
    }

    static function hasSavedMatch() {
        return Storage.getValue(KEY_STATE) != null;
    }

    static function saveMatch(engine) {
        Storage.setValue(KEY_SETTINGS, engine.getSettings().toDictionary());
        Storage.setValue(KEY_STATE, engine.getState().toDictionary());
        Storage.setValue(KEY_HISTORY, engine.historyToStorage());
    }

    static function loadMatch() {
        var stateData = Storage.getValue(KEY_STATE);

        if (stateData == null) {
            return null;
        }

        var settingsData = Storage.getValue(KEY_SETTINGS);
        var historyData = Storage.getValue(KEY_HISTORY);
        var history = [];

        if (historyData != null) {
            for (var i = 0; i < historyData.size(); i++) {
                history.add(MatchState.fromArray(historyData[i]));
            }
        }

        return new MatchSnapshot(
            MatchState.fromDictionary(stateData),
            MatchSettings.fromDictionary(settingsData),
            history
        );
    }

    static function clearMatch() {
        Storage.deleteValue(KEY_STATE);
        Storage.deleteValue(KEY_HISTORY);
    }
}
