using Toybox.Test;

function expectTrackPlay(logger, condition, message) {
    if (!condition) {
        logger.error(message);
    }
    return condition;
}

function trackedSettings() {
    var settings = new MatchSettings();
    settings.trackPlays = true;
    return settings;
}

function finishTrackedPoint(engine, playerWonPoint, attribution) {
    if (playerWonPoint) {
        engine.scorePlayer();
    } else {
        engine.scoreOpponent();
    }
    return engine.attributePoint(attribution);
}

(:test)
function trackPlaysOffKeepsSingleTapScoring(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(new MatchSettings(), true, PlayerId.ME);
    var result = engine.scorePlayer();
    var passed = expectTrackPlay(logger, result == MatchResult.POINT, "Tracking off should score immediately");
    passed = expectTrackPlay(logger, engine.getState().playerPoints == 1, "Tracking off should retain current scoring flow") && passed;
    passed = expectTrackPlay(logger, !engine.isAwaitingAttribution(), "Tracking off should not request attribution") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function trackPlaysRequiresAttributionAndRecordsContribution(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.ME);
    engine.scorePlayer();
    var state = engine.getState();
    var passed = expectTrackPlay(logger, engine.isAwaitingAttribution(), "First tap should request attribution");
    passed = expectTrackPlay(logger, state.playerPoints == 0, "Point must wait for attribution") && passed;
    engine.attributePoint(PlayerId.ME);
    passed = expectTrackPlay(logger, state.playerPoints == 1, "Second tap should commit the point") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.ME] == 1, "Winner-team player should receive Point Scored") && passed;

    finishTrackedPoint(engine, false, PlayerId.PARTNER);
    passed = expectTrackPlay(logger, state.errors[PlayerId.PARTNER] == 1, "Losing-team player should receive Error") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function doubleFaultAvailabilityAndServerAssignment(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), false, PlayerId.OP_1);
    engine.scoreOpponent();
    var passed = expectTrackPlay(logger, !engine.doubleFaultAvailable(), "DF must be hidden when serving team wins");
    engine.undo();

    engine.scorePlayer();
    passed = expectTrackPlay(logger, engine.doubleFaultAvailable(), "DF must be visible when receiving team wins") && passed;
    engine.attributePoint(PlayerId.DOUBLE_FAULT);
    var state = engine.getState();
    passed = expectTrackPlay(logger, state.doubleFaults[PlayerId.OP_1] == 1, "DF should belong to current server") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.ME] == 0 && state.errors[PlayerId.OP_1] == 0, "DF should not add another attribution") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function aceAttributionStatisticsUndoAndPersistence(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.PARTNER);
    engine.scoreOpponent();
    var passed = expectTrackPlay(logger, !engine.aceAvailable(), "ACE must be hidden when the serving team loses");
    engine.undo();

    engine.scorePlayer();
    passed = expectTrackPlay(logger, engine.aceAvailable(), "ACE must be available when the serving team wins") && passed;
    passed = expectTrackPlay(logger, !engine.doubleFaultAvailable(), "DF behavior must remain exclusive to a serving-team loss") && passed;
    var delegate = new TennisMatchDelegate(engine, null);
    passed = expectTrackPlay(logger, delegate.playerForAttribution(208, 208) == PlayerId.ACE, "Center circle should select ACE") && passed;
    engine.attributePoint(PlayerId.ACE);

    var state = engine.getState();
    passed = expectTrackPlay(logger, state.playerPoints == 1 && state.playerTotalPoints == 1, "ACE should commit the point") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.PARTNER] == 1, "ACE should attribute the point to the server") && passed;
    passed = expectTrackPlay(logger, state.aces[PlayerId.PARTNER] == 1, "ACE should increment the server's ACE total") && passed;

    var restored = ScoringEngine.resume(PersistenceManager.loadMatch());
    passed = expectTrackPlay(logger, restored.getState().aces[PlayerId.PARTNER] == 1, "ACE total should persist") && passed;
    passed = expectTrackPlay(logger, restored.getState().pointsScored[PlayerId.PARTNER] == 1, "ACE attribution should persist") && passed;
    restored.undo();
    passed = expectTrackPlay(logger, restored.getState().playerPoints == 0 && restored.getState().aces[PlayerId.PARTNER] == 0, "Undo should restore score and ACE total") && passed;
    restored.redo();
    passed = expectTrackPlay(logger, restored.getState().playerPoints == 1 && restored.getState().aces[PlayerId.PARTNER] == 1, "Redo should restore score and ACE total") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function doubleFaultTapCannotLeakIntoOpponentQuadrant(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.ME);
    engine.scoreOpponent();
    var delegate = new TennisMatchDelegate(engine, null);
    var passed = expectTrackPlay(
        logger,
        delegate.playerForAttribution(260, 178) == PlayerId.DOUBLE_FAULT,
        "Padded DF hit area should win over the OP 2 quadrant"
    );

    engine.attributePoint(PlayerId.DOUBLE_FAULT);
    for (var i = 0; i < 4; i++) {
        finishTrackedPoint(engine, true, PlayerId.ME);
    }

    var state = engine.getState();
    passed = expectTrackPlay(logger, state.playerGames == 1 && state.opponentGames == 0, "Sequence should produce a 1-0 game score") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.ME] == 4, "All four won points should belong to ME") && passed;
    passed = expectTrackPlay(logger, state.doubleFaults[PlayerId.ME] == 1, "The opening DF should belong to ME") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.PARTNER] == 0 && state.errors[PlayerId.PARTNER] == 0 && state.doubleFaults[PlayerId.PARTNER] == 0, "P should remain at zero") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.OP_1] == 0 && state.errors[PlayerId.OP_1] == 0 && state.doubleFaults[PlayerId.OP_1] == 0, "OP 1 should remain at zero") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.OP_2] == 0 && state.errors[PlayerId.OP_2] == 0 && state.doubleFaults[PlayerId.OP_2] == 0, "OP 2 should remain at zero") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function undoRestoresScoreAndAttributionTogether(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.ME);
    finishTrackedPoint(engine, true, PlayerId.ME);
    engine.undo();
    var state = engine.getState();
    var passed = expectTrackPlay(logger, state.playerPoints == 0 && state.playerTotalPoints == 0, "Undo should restore score");
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.ME] == 0, "Undo should restore attribution") && passed;
    engine.redo();
    passed = expectTrackPlay(logger, engine.getState().playerPoints == 1, "Redo should restore score") && passed;
    passed = expectTrackPlay(logger, engine.getState().pointsScored[PlayerId.ME] == 1, "Redo should restore attribution") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function initialIndividualServerCreatesExpectedRotation(logger) {
    var meEngine = new ScoringEngine(trackedSettings(), true, PlayerId.ME);
    var meState = meEngine.getState();
    var passed = expectTrackPlay(logger, meState.currentServer == PlayerId.ME, "ME chooser should set current server");
    passed = expectTrackPlay(logger, meState.serverRotation[0] == PlayerId.ME && meState.serverRotation[1] == PlayerId.OP_1 && meState.serverRotation[2] == PlayerId.PARTNER && meState.serverRotation[3] == PlayerId.OP_2, "ME rotation should alternate teams") && passed;

    var opponentEngine = new ScoringEngine(trackedSettings(), false, PlayerId.OP_1);
    passed = expectTrackPlay(logger, opponentEngine.getState().currentServer == PlayerId.OP_1, "Opponents should initially default to OP 1") && passed;
    return passed;
}

(:test)
function newSetRequestsAndLocksIndividualServer(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.ME);
    var state = engine.getState();
    state.playerGames = 5;
    state.playerPoints = 3;
    finishTrackedPoint(engine, true, PlayerId.ME);
    var passed = expectTrackPlay(logger, engine.isAwaitingServerSelection(), "A new set should request its starting server");
    passed = expectTrackPlay(logger, !state.playerServing, "Existing team-serving order should choose opponents") && passed;
    passed = expectTrackPlay(logger, engine.selectSetStartingServer(PlayerId.OP_2), "Appropriate team server should be accepted") && passed;
    passed = expectTrackPlay(logger, state.currentServer == PlayerId.OP_2, "Selected server should begin the set") && passed;

    state.opponentPoints = 3;
    finishTrackedPoint(engine, false, PlayerId.OP_2);
    passed = expectTrackPlay(logger, state.currentServer == PlayerId.ME, "Fixed rotation should advance after the game") && passed;
    passed = expectTrackPlay(logger, !engine.selectSetStartingServer(PlayerId.PARTNER), "Rotation cannot change during a set") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function firstGameRequestsOpposingTeamServerAndLocksRotation(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.ME);

    for (var i = 0; i < 4; i++) {
        finishTrackedPoint(engine, true, PlayerId.ME);
    }

    var state = engine.getState();
    var passed = expectTrackPlay(logger, engine.isAwaitingServerSelection(), "First game should request the opposing team's server");
    passed = expectTrackPlay(logger, !state.playerServing, "Opposing team should serve the second game") && passed;
    passed = expectTrackPlay(logger, !engine.selectSetStartingServer(PlayerId.ME), "A player from the first-serving team must not be selectable") && passed;
    passed = expectTrackPlay(logger, engine.selectSetStartingServer(PlayerId.OP_2), "One of the two opposing players should be selectable") && passed;
    passed = expectTrackPlay(logger, state.currentServer == PlayerId.OP_2, "Selected opponent should serve first for that team") && passed;
    passed = expectTrackPlay(logger, state.serverRotation[0] == PlayerId.OP_2 && state.serverRotation[1] == PlayerId.ME && state.serverRotation[2] == PlayerId.OP_1 && state.serverRotation[3] == PlayerId.PARTNER, "Selection should establish the four-player service order") && passed;

    var restored = ScoringEngine.resume(PersistenceManager.loadMatch());
    passed = expectTrackPlay(logger, restored.getState().currentServer == PlayerId.OP_2 && restored.getState().serverRotation[0] == PlayerId.OP_2, "Opposing-team service order should persist") && passed;

    for (var j = 0; j < 4; j++) {
        finishTrackedPoint(restored, false, PlayerId.ACE);
    }

    passed = expectTrackPlay(logger, !restored.isAwaitingServerSelection(), "Later games should not repeat the first-game selection") && passed;
    passed = expectTrackPlay(logger, restored.getState().currentServer == PlayerId.ME, "Service order should advance to the selected next server") && passed;

    var reverseEngine = new ScoringEngine(trackedSettings(), false, PlayerId.OP_1);
    for (var k = 0; k < 4; k++) {
        finishTrackedPoint(reverseEngine, false, PlayerId.OP_1);
    }
    passed = expectTrackPlay(logger, reverseEngine.isAwaitingServerSelection() && reverseEngine.getState().playerServing, "The first-game prompt should target our team when opponents served first") && passed;
    passed = expectTrackPlay(logger, !reverseEngine.selectSetStartingServer(PlayerId.OP_2), "Only the now-serving team should be selectable") && passed;
    passed = expectTrackPlay(logger, reverseEngine.selectSetStartingServer(PlayerId.PARTNER), "Either eligible player on our team should be selectable") && passed;
    passed = expectTrackPlay(logger, reverseEngine.getState().currentServer == PlayerId.PARTNER, "Selected partner should lead our team's service order") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function finalSuperTieBreakRequestsIndividualServer(logger) {
    PersistenceManager.clearMatch();
    var settings = trackedSettings();
    settings.finalSetMode = FinalSetMode.STB;
    var engine = new ScoringEngine(settings, true, PlayerId.ME);
    var state = engine.getState();
    state.playerSets = 1;
    state.opponentGames = 5;
    state.opponentPoints = 3;
    finishTrackedPoint(engine, false, PlayerId.ME);
    var passed = expectTrackPlay(logger, state.stage == StageType.SUPER_TIE_BREAK, "Final STB should start normally");
    passed = expectTrackPlay(logger, engine.isAwaitingServerSelection(), "Final STB should request an individual server") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function tieBreaksTrackOneThenTwoPointServerRotation(logger) {
    PersistenceManager.clearMatch();
    var settings = trackedSettings();
    settings.matchFormat = MatchFormat.TB_MATCH;
    var engine = new ScoringEngine(settings, true, PlayerId.ME);
    var state = engine.getState();
    finishTrackedPoint(engine, true, PlayerId.ME);
    var passed = expectTrackPlay(logger, state.currentServer == PlayerId.OP_1, "After point one, OP 1 should serve");
    finishTrackedPoint(engine, true, PlayerId.ME);
    passed = expectTrackPlay(logger, state.currentServer == PlayerId.OP_1, "OP 1 should serve the second point of the pair") && passed;
    finishTrackedPoint(engine, true, PlayerId.ME);
    passed = expectTrackPlay(logger, state.currentServer == PlayerId.PARTNER, "After two points, P should serve") && passed;

    settings.matchFormat = MatchFormat.STB_MATCH;
    var stb = new ScoringEngine(settings, false, PlayerId.OP_1);
    finishTrackedPoint(stb, true, PlayerId.ME);
    passed = expectTrackPlay(logger, stb.getState().currentServer == PlayerId.ME, "STB should use the same one-then-two sequence") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function serverPresentationStringsMatchSpecification(logger) {
    var passed = expectTrackPlay(logger, PlayerId.serveNotice(PlayerId.ME).equals("YOU SERVE"), "ME notice should match");
    passed = expectTrackPlay(logger, PlayerId.serveNotice(PlayerId.PARTNER).equals("P TO SERVE"), "Partner notice should match") && passed;
    passed = expectTrackPlay(logger, PlayerId.serveNotice(PlayerId.OP_1).equals("OP 1 TO SERVE"), "OP 1 notice should match") && passed;
    passed = expectTrackPlay(logger, PlayerId.serveNotice(PlayerId.OP_2).equals("OP 2 TO SERVE"), "OP 2 notice should match") && passed;
    passed = expectTrackPlay(logger, PlayerId.marker(PlayerId.ME).equals("M") && PlayerId.marker(PlayerId.OP_2).equals("2"), "Serving-ball markers should identify server") && passed;
    return passed;
}

(:test)
function trackedStateAndSettingsRoundTrip(logger) {
    PersistenceManager.clearMatch();
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.PARTNER);
    finishTrackedPoint(engine, true, PlayerId.PARTNER);
    engine.scoreOpponent();

    var snapshot = PersistenceManager.loadMatch();
    var restored = ScoringEngine.resume(snapshot);
    var state = restored.getState();
    var passed = expectTrackPlay(logger, restored.getSettings().trackPlays, "Track Plays setting should persist");
    passed = expectTrackPlay(logger, state.currentServer == PlayerId.PARTNER, "Current server should persist") && passed;
    passed = expectTrackPlay(logger, state.serverRotation[0] == PlayerId.PARTNER, "Serving rotation should persist") && passed;
    passed = expectTrackPlay(logger, state.pointsScored[PlayerId.PARTNER] == 1, "Per-player stats should persist") && passed;
    passed = expectTrackPlay(logger, restored.isAwaitingAttribution(), "Pending point attribution should persist") && passed;
    PersistenceManager.clearMatch();
    return passed;
}

(:test)
function allPlayersRemainRepresentedAtZero(logger) {
    var state = new MatchState();
    var passed = expectTrackPlay(logger, state.pointsScored.size() == 4 && state.errors.size() == 4 && state.doubleFaults.size() == 4 && state.aces.size() == 4, "All four players should have all stat categories");
    for (var i = 0; i < 4; i++) {
        passed = expectTrackPlay(logger, state.pointsScored[i] == 0 && state.errors[i] == 0 && state.doubleFaults[i] == 0 && state.aces[i] == 0, "Zero-value player stats should be retained") && passed;
    }
    return passed;
}

(:test)
function currentAndFinalStatsIncludePlayerPage(logger) {
    var engine = new ScoringEngine(trackedSettings(), true, PlayerId.ME);
    var currentView = new MatchStatsView(engine);
    var passed = expectTrackPlay(logger, currentView.showPlayerStats(), "Current stats should open with per-player stats");
    passed = expectTrackPlay(logger, currentView.pageCount() == 3, "Current stats should include the player page") && passed;

    engine.getState().matchFinished = true;
    var finalView = new MatchStatsView(engine);
    passed = expectTrackPlay(logger, finalView.showPlayerStats(), "Final stats should open with per-player stats") && passed;
    passed = expectTrackPlay(logger, finalView.pageCount() == 4, "Final stats should include the player page") && passed;
    return passed;
}
