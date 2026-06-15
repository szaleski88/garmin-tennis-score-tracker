class RuleFactory {
    static function defaultSettings() {
        return new MatchSettings();
    }

    static function applyBestOf3(settings) {
        settings.matchFormat = MatchFormat.BEST_OF_3;
        settings.bestOfSets = 3;
    }

    static function applyBestOf5(settings) {
        settings.matchFormat = MatchFormat.BEST_OF_5;
        settings.bestOfSets = 5;
        settings.finalSetMode = FinalSetMode.FULL_SET;
    }

    static function applySuperTieBreakMatch(settings) {
        settings.matchFormat = MatchFormat.STB_MATCH;
        settings.bestOfSets = 1;
    }

    static function applyTieBreakMatch(settings) {
        settings.matchFormat = MatchFormat.TB_MATCH;
        settings.bestOfSets = 1;
    }

    static function applyStandardSets(settings) {
        settings.gamesInSet = 6;
        settings.tieBreakAt = 6;
    }

    static function applyShortSets(settings) {
        settings.gamesInSet = 4;
        settings.tieBreakAt = 3;
    }
}
