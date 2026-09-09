using Toybox.Test;

function expectScoreState(logger, condition, message) {
    if (!condition) {
        logger.error(message);
    }

    return condition;
}

function makeDecidingMatch() {
    var settings = new MatchSettings();
    settings.matchFormat = MatchFormat.BEST_OF_3;
    settings.bestOfSets = 3;
    settings.finalSetMode = FinalSetMode.DECIDE;

    var engine = new ScoringEngine(settings, true);
    var state = engine.getState();
    state.playerSets = 1;
    state.opponentSets = 0;
    state.opponentGames = 5;
    state.opponentTotalGames = 5;
    state.opponentPoints = 3;
    state.opponentTotalPoints = 3;
    engine.scoreOpponent();
    return engine;
}

(:test)
function oddCompletedGamesTriggerOneSideSwap(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(new MatchSettings(), true);
    var state = engine.getState();
    var passed = true;

    state.playerPoints = 3;
    var result = engine.scorePlayer();
    passed = expectScoreState(logger, result == MatchResult.GAME, "First game should complete") && passed;
    passed = expectScoreState(logger, state.playerGames == 1, "First game should produce 1-0") && passed;
    passed = expectScoreState(logger, engine.sideSwapTriggered(), "1-0 should trigger a side swap") && passed;

    state.opponentPoints = 3;
    engine.scoreOpponent();
    passed = expectScoreState(logger, state.opponentGames == 1, "Second game should produce 1-1") && passed;
    passed = expectScoreState(logger, !engine.sideSwapTriggered(), "1-1 should not trigger a side swap") && passed;

    state.opponentPoints = 3;
    engine.scoreOpponent();
    passed = expectScoreState(logger, state.opponentGames == 2, "Third game should produce 1-2") && passed;
    passed = expectScoreState(logger, engine.sideSwapTriggered(), "1-2 should trigger a side swap") && passed;

    state.playerGames = 4;
    state.opponentGames = 2;
    state.opponentPoints = 3;
    engine.scoreOpponent();
    passed = expectScoreState(logger, state.opponentGames == 3, "Seventh game should produce 4-3") && passed;
    passed = expectScoreState(logger, engine.sideSwapTriggered(), "4-3 should trigger a side swap") && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function sideSwapDoesNotRepeatAfterCorrectionOrResume(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(new MatchSettings(), true);
    var state = engine.getState();
    var passed = true;

    state.playerPoints = 3;
    engine.scorePlayer();
    passed = expectScoreState(logger, engine.sideSwapTriggered(), "Initial odd game should trigger") && passed;

    engine.undo();
    passed = expectScoreState(logger, !engine.sideSwapTriggered(), "Undo should not replay the notification") && passed;
    engine.scorePlayer();
    passed = expectScoreState(logger, !engine.sideSwapTriggered(), "Correcting the same game should not replay the notification") && passed;

    var snapshot = PersistenceManager.loadMatch();
    var resumed = ScoringEngine.resume(snapshot);
    passed = expectScoreState(logger, !resumed.sideSwapTriggered(), "Resume should not replay the notification") && passed;
    passed = expectScoreState(
        logger,
        resumed.getState().lastSideSwapPointCount == engine.getState().lastSideSwapPointCount,
        "Side-swap watermark should persist"
    ) && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function tieBreakSideSwapBehaviorIsPreserved(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(new MatchSettings(), true);
    var state = engine.getState();
    state.stage = StageType.TIE_BREAK;
    state.playerPoints = 3;
    state.opponentPoints = 2;
    state.playerTotalPoints = 3;
    state.opponentTotalPoints = 2;

    var result = engine.scoreOpponent();
    var passed = expectScoreState(logger, result == MatchResult.SIDE_SWAP, "Sixth tie-break point should retain SIDE_SWAP result");
    passed = expectScoreState(logger, engine.sideSwapTriggered(), "Sixth tie-break point should trigger notification") && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function oddSetEndingGameTriggersBeforeScoresReset(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(new MatchSettings(), true);
    var state = engine.getState();
    state.playerGames = 5;
    state.opponentGames = 3;
    state.playerTotalGames = 5;
    state.opponentTotalGames = 3;
    state.playerPoints = 3;
    state.playerTotalPoints = 3;

    var result = engine.scorePlayer();
    var passed = expectScoreState(logger, result == MatchResult.SET, "6-3 should complete the set");
    passed = expectScoreState(logger, state.playerGames == 0 && state.opponentGames == 0, "New set should reset game scores") && passed;
    passed = expectScoreState(logger, engine.sideSwapTriggered(), "Ninth game should trigger even though set scores reset") && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function finishedMatchInputDoesNotReplaySideSwap(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(new MatchSettings(), true);
    var state = engine.getState();
    state.playerSets = 1;
    state.playerGames = 5;
    state.opponentGames = 3;
    state.playerPoints = 3;
    state.playerTotalPoints = 3;

    engine.scorePlayer();
    var passed = expectScoreState(logger, state.matchFinished, "6-3 should finish the match from one set up");
    passed = expectScoreState(logger, engine.sideSwapTriggered(), "Odd match-ending game should trigger once") && passed;

    var result = engine.scoreOpponent();
    passed = expectScoreState(logger, result == MatchResult.NONE, "Finished match input should not score") && passed;
    passed = expectScoreState(logger, !engine.sideSwapTriggered(), "Finished match input should not replay the notification") && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function decideUpperSelectionStartsSuperTieBreakAndPersists(logger) {
    PersistenceManager.clearMatch();
    var engine = makeDecidingMatch();
    var state = engine.getState();
    var passed = true;

    passed = expectScoreState(logger, engine.isAwaitingFinalSetDecision(), "A 1-1 set score should show the decision") && passed;
    passed = expectScoreState(logger, state.selectedFinalSetMode == null, "No format should be selected before input") && passed;

    var pointsBefore = state.playerTotalPoints + state.opponentTotalPoints;
    engine.scoreOpponent();
    passed = expectScoreState(logger, state.selectedFinalSetMode == FinalSetMode.STB, "Upper input should select STB") && passed;
    passed = expectScoreState(logger, state.stage == StageType.SUPER_TIE_BREAK, "STB selection should start an STB") && passed;
    passed = expectScoreState(
        logger,
        state.playerTotalPoints + state.opponentTotalPoints == pointsBefore,
        "Selecting a format must not score a point"
    ) && passed;

    var snapshot = PersistenceManager.loadMatch();
    var resumed = ScoringEngine.resume(snapshot);
    passed = expectScoreState(logger, !resumed.isAwaitingFinalSetDecision(), "Resume should not show a completed decision") && passed;
    passed = expectScoreState(
        logger,
        resumed.getState().selectedFinalSetMode == FinalSetMode.STB,
        "Selected STB format should persist"
    ) && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function decideLowerSelectionStartsRegularSet(logger) {
    PersistenceManager.clearMatch();
    var engine = makeDecidingMatch();
    var state = engine.getState();
    var passed = true;

    engine.scorePlayer();
    passed = expectScoreState(logger, state.selectedFinalSetMode == FinalSetMode.TB, "Lower input should select regular set") && passed;
    passed = expectScoreState(logger, state.stage == StageType.GAME, "Regular selection should start a game") && passed;

    state.playerGames = 6;
    state.opponentGames = 5;
    state.opponentPoints = 3;
    engine.scoreOpponent();
    passed = expectScoreState(logger, state.stage == StageType.TIE_BREAK, "Regular final set should use the configured tie break") && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function finalSetDecisionCanBeUndoneAndRedone(logger) {
    PersistenceManager.clearMatch();
    var engine = makeDecidingMatch();
    var passed = true;

    engine.scoreOpponent();
    engine.undo();
    passed = expectScoreState(logger, engine.isAwaitingFinalSetDecision(), "Undoing selection should restore the choice") && passed;
    passed = expectScoreState(logger, engine.getState().selectedFinalSetMode == null, "Undo should clear selected format") && passed;

    engine.redo();
    passed = expectScoreState(logger, !engine.isAwaitingFinalSetDecision(), "Redo should restore the selection") && passed;
    passed = expectScoreState(
        logger,
        engine.getState().selectedFinalSetMode == FinalSetMode.STB,
        "Redo should restore the selected STB format"
    ) && passed;

    engine.undo();
    engine.undo();
    passed = expectScoreState(logger, engine.getState().playerSets == 1, "Correcting the set should return to 1-0") && passed;
    passed = expectScoreState(logger, !engine.isAwaitingFinalSetDecision(), "Decision should disappear before 1-1") && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function existingFinalSetModesRemainAutomatic(logger) {
    PersistenceManager.clearMatch();
    var settings = new MatchSettings();
    settings.finalSetMode = FinalSetMode.STB;
    var engine = new ScoringEngine(settings, true);
    var state = engine.getState();
    state.playerSets = 1;
    state.opponentGames = 5;
    state.opponentPoints = 3;
    engine.scoreOpponent();

    var passed = expectScoreState(logger, state.stage == StageType.SUPER_TIE_BREAK, "Existing STB final set should still start automatically");
    passed = expectScoreState(logger, !engine.isAwaitingFinalSetDecision(), "Existing modes should not show DECIDE") && passed;

    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function decideModeSerializesAndCyclesInSettings(logger) {
    var settings = new MatchSettings();
    settings.finalSetMode = FinalSetMode.FULL_SET;
    var delegate = new SettingsDelegate(settings);
    delegate.cycleFinalSet();

    var restored = MatchSettings.fromDictionary(settings.toDictionary());
    var passed = expectScoreState(logger, settings.finalSetMode == FinalSetMode.DECIDE, "Settings should cycle from Full Set to DECIDE");
    passed = expectScoreState(logger, restored.finalSetMode == FinalSetMode.DECIDE, "DECIDE should serialize in settings") && passed;
    passed = expectScoreState(logger, ScoreFormatter.finalSetLabel(restored).equals("DECIDE"), "DECIDE should have a settings label") && passed;

    settings.matchFormat = MatchFormat.BEST_OF_5;
    settings.finalSetMode = FinalSetMode.FULL_SET;
    delegate.cycleFinalSet();
    passed = expectScoreState(logger, settings.finalSetMode == FinalSetMode.STB, "DECIDE should only be offered for Best of 3") && passed;
    return passed;
}
