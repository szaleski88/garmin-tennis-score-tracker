class MatchSnapshot {
    var state;
    var settings;
    var history;
    var redoHistory;

    function initialize(matchState, matchSettings, matchHistory, matchRedoHistory) {
        state = matchState;
        settings = matchSettings;
        history = matchHistory;
        redoHistory = matchRedoHistory;
    }
}
