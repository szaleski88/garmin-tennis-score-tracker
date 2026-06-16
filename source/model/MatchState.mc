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
            "calorieFinished" => calorieFinished
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
            calorieFinished
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

        return state;
    }
}
