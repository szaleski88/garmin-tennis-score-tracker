class MatchState {
    var playerSets;
    var opponentSets;
    var playerGames;
    var opponentGames;
    var playerPoints;
    var opponentPoints;
    var stage;
    var playerServing;
    var matchFinished;
    var matchWinner;
    var tieBreakStarterPlayerServing;
    var startedAt;
    var finishedAt;
    var calorieBaseline;
    var calorieFinished;
    var playerTotalPoints;
    var opponentTotalPoints;
    var playerTotalGames;
    var opponentTotalGames;
    var playerBreakPointChances;
    var playerBreakPointsWon;
    var opponentBreakPointChances;
    var opponentBreakPointsWon;
    var playerServicePointsPlayed;
    var playerServicePointsWon;
    var opponentServicePointsPlayed;
    var opponentServicePointsWon;
    var currentPointStreakWinner;
    var currentPointStreak;
    var longestPlayerPointStreak;
    var longestOpponentPointStreak;
    var currentGameStreakWinner;
    var currentGameStreak;
    var longestPlayerGameStreak;
    var longestOpponentGameStreak;
    var maxPlayerPointLead;
    var maxOpponentPointLead;

    function initialize() {
        playerSets = 0;
        opponentSets = 0;
        playerGames = 0;
        opponentGames = 0;
        playerPoints = 0;
        opponentPoints = 0;
        stage = StageType.GAME;
        playerServing = true;
        matchFinished = false;
        matchWinner = 0;
        tieBreakStarterPlayerServing = true;
        startedAt = null;
        finishedAt = null;
        calorieBaseline = null;
        calorieFinished = null;
        playerTotalPoints = 0;
        opponentTotalPoints = 0;
        playerTotalGames = 0;
        opponentTotalGames = 0;
        playerBreakPointChances = 0;
        playerBreakPointsWon = 0;
        opponentBreakPointChances = 0;
        opponentBreakPointsWon = 0;
        playerServicePointsPlayed = 0;
        playerServicePointsWon = 0;
        opponentServicePointsPlayed = 0;
        opponentServicePointsWon = 0;
        currentPointStreakWinner = 0;
        currentPointStreak = 0;
        longestPlayerPointStreak = 0;
        longestOpponentPointStreak = 0;
        currentGameStreakWinner = 0;
        currentGameStreak = 0;
        longestPlayerGameStreak = 0;
        longestOpponentGameStreak = 0;
        maxPlayerPointLead = 0;
        maxOpponentPointLead = 0;
    }

    function clone() {
        var copy = new MatchState();
        copy.playerSets = playerSets;
        copy.opponentSets = opponentSets;
        copy.playerGames = playerGames;
        copy.opponentGames = opponentGames;
        copy.playerPoints = playerPoints;
        copy.opponentPoints = opponentPoints;
        copy.stage = stage;
        copy.playerServing = playerServing;
        copy.matchFinished = matchFinished;
        copy.matchWinner = matchWinner;
        copy.tieBreakStarterPlayerServing = tieBreakStarterPlayerServing;
        copy.startedAt = startedAt;
        copy.finishedAt = finishedAt;
        copy.calorieBaseline = calorieBaseline;
        copy.calorieFinished = calorieFinished;
        copy.playerTotalPoints = playerTotalPoints;
        copy.opponentTotalPoints = opponentTotalPoints;
        copy.playerTotalGames = playerTotalGames;
        copy.opponentTotalGames = opponentTotalGames;
        copy.playerBreakPointChances = playerBreakPointChances;
        copy.playerBreakPointsWon = playerBreakPointsWon;
        copy.opponentBreakPointChances = opponentBreakPointChances;
        copy.opponentBreakPointsWon = opponentBreakPointsWon;
        copy.playerServicePointsPlayed = playerServicePointsPlayed;
        copy.playerServicePointsWon = playerServicePointsWon;
        copy.opponentServicePointsPlayed = opponentServicePointsPlayed;
        copy.opponentServicePointsWon = opponentServicePointsWon;
        copy.currentPointStreakWinner = currentPointStreakWinner;
        copy.currentPointStreak = currentPointStreak;
        copy.longestPlayerPointStreak = longestPlayerPointStreak;
        copy.longestOpponentPointStreak = longestOpponentPointStreak;
        copy.currentGameStreakWinner = currentGameStreakWinner;
        copy.currentGameStreak = currentGameStreak;
        copy.longestPlayerGameStreak = longestPlayerGameStreak;
        copy.longestOpponentGameStreak = longestOpponentGameStreak;
        copy.maxPlayerPointLead = maxPlayerPointLead;
        copy.maxOpponentPointLead = maxOpponentPointLead;
        return copy;
    }

    function toDictionary() {
        return {
            "playerSets" => playerSets,
            "opponentSets" => opponentSets,
            "playerGames" => playerGames,
            "opponentGames" => opponentGames,
            "playerPoints" => playerPoints,
            "opponentPoints" => opponentPoints,
            "stage" => stage,
            "playerServing" => playerServing,
            "matchFinished" => matchFinished,
            "matchWinner" => matchWinner,
            "tieBreakStarterPlayerServing" => tieBreakStarterPlayerServing,
            "startedAt" => startedAt,
            "finishedAt" => finishedAt,
            "calorieBaseline" => calorieBaseline,
            "calorieFinished" => calorieFinished,
            "playerTotalPoints" => playerTotalPoints,
            "opponentTotalPoints" => opponentTotalPoints,
            "playerTotalGames" => playerTotalGames,
            "opponentTotalGames" => opponentTotalGames,
            "playerBreakPointChances" => playerBreakPointChances,
            "playerBreakPointsWon" => playerBreakPointsWon,
            "opponentBreakPointChances" => opponentBreakPointChances,
            "opponentBreakPointsWon" => opponentBreakPointsWon,
            "playerServicePointsPlayed" => playerServicePointsPlayed,
            "playerServicePointsWon" => playerServicePointsWon,
            "opponentServicePointsPlayed" => opponentServicePointsPlayed,
            "opponentServicePointsWon" => opponentServicePointsWon,
            "currentPointStreakWinner" => currentPointStreakWinner,
            "currentPointStreak" => currentPointStreak,
            "longestPlayerPointStreak" => longestPlayerPointStreak,
            "longestOpponentPointStreak" => longestOpponentPointStreak,
            "currentGameStreakWinner" => currentGameStreakWinner,
            "currentGameStreak" => currentGameStreak,
            "longestPlayerGameStreak" => longestPlayerGameStreak,
            "longestOpponentGameStreak" => longestOpponentGameStreak,
            "maxPlayerPointLead" => maxPlayerPointLead,
            "maxOpponentPointLead" => maxOpponentPointLead
        };
    }

    function toArray() {
        return [
            playerSets,
            opponentSets,
            playerGames,
            opponentGames,
            playerPoints,
            opponentPoints,
            stage,
            playerServing,
            matchFinished,
            matchWinner,
            tieBreakStarterPlayerServing,
            startedAt,
            finishedAt,
            calorieBaseline,
            calorieFinished,
            playerTotalPoints,
            opponentTotalPoints,
            playerTotalGames,
            opponentTotalGames,
            playerBreakPointChances,
            playerBreakPointsWon,
            opponentBreakPointChances,
            opponentBreakPointsWon,
            playerServicePointsPlayed,
            playerServicePointsWon,
            opponentServicePointsPlayed,
            opponentServicePointsWon,
            currentPointStreakWinner,
            currentPointStreak,
            longestPlayerPointStreak,
            longestOpponentPointStreak,
            currentGameStreakWinner,
            currentGameStreak,
            longestPlayerGameStreak,
            longestOpponentGameStreak,
            maxPlayerPointLead,
            maxOpponentPointLead
        ];
    }

    static function fromDictionary(data) {
        var state = new MatchState();

        if (data == null) {
            return state;
        }

        if (data.hasKey("playerSets")) {
            state.playerSets = data["playerSets"];
        }
        if (data.hasKey("opponentSets")) {
            state.opponentSets = data["opponentSets"];
        }
        if (data.hasKey("playerGames")) {
            state.playerGames = data["playerGames"];
        }
        if (data.hasKey("opponentGames")) {
            state.opponentGames = data["opponentGames"];
        }
        if (data.hasKey("playerPoints")) {
            state.playerPoints = data["playerPoints"];
        }
        if (data.hasKey("opponentPoints")) {
            state.opponentPoints = data["opponentPoints"];
        }
        if (data.hasKey("stage")) {
            state.stage = data["stage"];
        }
        if (data.hasKey("playerServing")) {
            state.playerServing = data["playerServing"];
        }
        if (data.hasKey("matchFinished")) {
            state.matchFinished = data["matchFinished"];
        }
        if (data.hasKey("matchWinner")) {
            state.matchWinner = data["matchWinner"];
        }
        if (data.hasKey("tieBreakStarterPlayerServing")) {
            state.tieBreakStarterPlayerServing = data["tieBreakStarterPlayerServing"];
        }
        if (data.hasKey("startedAt")) {
            state.startedAt = data["startedAt"];
        }
        if (data.hasKey("finishedAt")) {
            state.finishedAt = data["finishedAt"];
        }
        if (data.hasKey("calorieBaseline")) {
            state.calorieBaseline = data["calorieBaseline"];
        }
        if (data.hasKey("calorieFinished")) {
            state.calorieFinished = data["calorieFinished"];
        }
        if (data.hasKey("playerTotalPoints")) {
            state.playerTotalPoints = data["playerTotalPoints"];
        }
        if (data.hasKey("opponentTotalPoints")) {
            state.opponentTotalPoints = data["opponentTotalPoints"];
        }
        if (data.hasKey("playerTotalGames")) {
            state.playerTotalGames = data["playerTotalGames"];
        }
        if (data.hasKey("opponentTotalGames")) {
            state.opponentTotalGames = data["opponentTotalGames"];
        }
        if (data.hasKey("playerBreakPointChances")) {
            state.playerBreakPointChances = data["playerBreakPointChances"];
        }
        if (data.hasKey("playerBreakPointsWon")) {
            state.playerBreakPointsWon = data["playerBreakPointsWon"];
        }
        if (data.hasKey("opponentBreakPointChances")) {
            state.opponentBreakPointChances = data["opponentBreakPointChances"];
        }
        if (data.hasKey("opponentBreakPointsWon")) {
            state.opponentBreakPointsWon = data["opponentBreakPointsWon"];
        }
        if (data.hasKey("playerServicePointsPlayed")) {
            state.playerServicePointsPlayed = data["playerServicePointsPlayed"];
        }
        if (data.hasKey("playerServicePointsWon")) {
            state.playerServicePointsWon = data["playerServicePointsWon"];
        }
        if (data.hasKey("opponentServicePointsPlayed")) {
            state.opponentServicePointsPlayed = data["opponentServicePointsPlayed"];
        }
        if (data.hasKey("opponentServicePointsWon")) {
            state.opponentServicePointsWon = data["opponentServicePointsWon"];
        }
        if (data.hasKey("currentPointStreakWinner")) {
            state.currentPointStreakWinner = data["currentPointStreakWinner"];
        }
        if (data.hasKey("currentPointStreak")) {
            state.currentPointStreak = data["currentPointStreak"];
        }
        if (data.hasKey("longestPlayerPointStreak")) {
            state.longestPlayerPointStreak = data["longestPlayerPointStreak"];
        }
        if (data.hasKey("longestOpponentPointStreak")) {
            state.longestOpponentPointStreak = data["longestOpponentPointStreak"];
        }
        if (data.hasKey("currentGameStreakWinner")) {
            state.currentGameStreakWinner = data["currentGameStreakWinner"];
        }
        if (data.hasKey("currentGameStreak")) {
            state.currentGameStreak = data["currentGameStreak"];
        }
        if (data.hasKey("longestPlayerGameStreak")) {
            state.longestPlayerGameStreak = data["longestPlayerGameStreak"];
        }
        if (data.hasKey("longestOpponentGameStreak")) {
            state.longestOpponentGameStreak = data["longestOpponentGameStreak"];
        }
        if (data.hasKey("maxPlayerPointLead")) {
            state.maxPlayerPointLead = data["maxPlayerPointLead"];
        }
        if (data.hasKey("maxOpponentPointLead")) {
            state.maxOpponentPointLead = data["maxOpponentPointLead"];
        }

        return state;
    }

    static function fromArray(data) {
        var state = new MatchState();

        if (data == null || data.size() < 11) {
            return state;
        }

        state.playerSets = data[0];
        state.opponentSets = data[1];
        state.playerGames = data[2];
        state.opponentGames = data[3];
        state.playerPoints = data[4];
        state.opponentPoints = data[5];
        state.stage = data[6];
        state.playerServing = data[7];
        state.matchFinished = data[8];
        state.matchWinner = data[9];
        state.tieBreakStarterPlayerServing = data[10];

        if (data.size() > 11) {
            state.startedAt = data[11];
        }
        if (data.size() > 12) {
            state.finishedAt = data[12];
        }
        if (data.size() > 13) {
            state.calorieBaseline = data[13];
        }
        if (data.size() > 14) {
            state.calorieFinished = data[14];
        }
        if (data.size() > 15) {
            state.playerTotalPoints = data[15];
        }
        if (data.size() > 16) {
            state.opponentTotalPoints = data[16];
        }
        if (data.size() > 17) {
            state.playerTotalGames = data[17];
        }
        if (data.size() > 18) {
            state.opponentTotalGames = data[18];
        }
        if (data.size() > 19) {
            state.playerBreakPointChances = data[19];
        }
        if (data.size() > 20) {
            state.playerBreakPointsWon = data[20];
        }
        if (data.size() > 21) {
            state.opponentBreakPointChances = data[21];
        }
        if (data.size() > 22) {
            state.opponentBreakPointsWon = data[22];
        }
        if (data.size() > 23) {
            state.playerServicePointsPlayed = data[23];
        }
        if (data.size() > 24) {
            state.playerServicePointsWon = data[24];
        }
        if (data.size() > 25) {
            state.opponentServicePointsPlayed = data[25];
        }
        if (data.size() > 26) {
            state.opponentServicePointsWon = data[26];
        }
        if (data.size() > 27) {
            state.currentPointStreakWinner = data[27];
        }
        if (data.size() > 28) {
            state.currentPointStreak = data[28];
        }
        if (data.size() > 29) {
            state.longestPlayerPointStreak = data[29];
        }
        if (data.size() > 30) {
            state.longestOpponentPointStreak = data[30];
        }
        if (data.size() > 31) {
            state.currentGameStreakWinner = data[31];
        }
        if (data.size() > 32) {
            state.currentGameStreak = data[32];
        }
        if (data.size() > 33) {
            state.longestPlayerGameStreak = data[33];
        }
        if (data.size() > 34) {
            state.longestOpponentGameStreak = data[34];
        }
        if (data.size() > 35) {
            state.maxPlayerPointLead = data[35];
        }
        if (data.size() > 36) {
            state.maxOpponentPointLead = data[36];
        }

        return state;
    }
}
