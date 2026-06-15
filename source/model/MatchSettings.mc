module MatchFormat {
    const BEST_OF_3 = 0;
    const BEST_OF_5 = 1;
    const STB_MATCH = 2;
    const TB_MATCH = 3;
}

module FinalSetMode {
    const FULL_SET = 0;
    const TB = 1;
    const STB = 2;
}

class MatchSettings {
    var matchFormat;
    var bestOfSets;
    var gamesInSet;
    var tieBreakAt;
    var goldenPoint;
    var finalSetMode;

    function initialize() {
        matchFormat = MatchFormat.BEST_OF_3;
        bestOfSets = 3;
        gamesInSet = 6;
        tieBreakAt = 6;
        goldenPoint = false;
        finalSetMode = FinalSetMode.STB;
    }

    function clone() {
        var copy = new MatchSettings();
        copy.matchFormat = matchFormat;
        copy.bestOfSets = bestOfSets;
        copy.gamesInSet = gamesInSet;
        copy.tieBreakAt = tieBreakAt;
        copy.goldenPoint = goldenPoint;
        copy.finalSetMode = finalSetMode;
        return copy;
    }

    function setsToWin() {
        if (matchFormat == MatchFormat.STB_MATCH || matchFormat == MatchFormat.TB_MATCH) {
            return 1;
        }

        if (bestOfSets == 5) {
            return 3;
        }

        return 2;
    }

    function useShortSets() {
        return gamesInSet == 4;
    }

    function toDictionary() {
        return {
            "matchFormat" => matchFormat,
            "bestOfSets" => bestOfSets,
            "gamesInSet" => gamesInSet,
            "tieBreakAt" => tieBreakAt,
            "goldenPoint" => goldenPoint,
            "finalSetMode" => finalSetMode
        };
    }

    static function fromDictionary(data) {
        var settings = new MatchSettings();

        if (data == null) {
            return settings;
        }

        if (data.hasKey("matchFormat")) {
            settings.matchFormat = data["matchFormat"];
        }
        if (data.hasKey("bestOfSets")) {
            settings.bestOfSets = data["bestOfSets"];
        }
        if (data.hasKey("gamesInSet")) {
            settings.gamesInSet = data["gamesInSet"];
        }
        if (data.hasKey("tieBreakAt")) {
            settings.tieBreakAt = data["tieBreakAt"];
        }
        if (data.hasKey("goldenPoint")) {
            settings.goldenPoint = data["goldenPoint"];
        }
        if (data.hasKey("finalSetMode")) {
            settings.finalSetMode = data["finalSetMode"];
        }

        return settings;
    }
}
