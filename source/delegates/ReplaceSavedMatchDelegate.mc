using Toybox.WatchUi;

class ReplaceSavedMatchDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onTap(clickEvent) {
        var coordinates = clickEvent.getCoordinates();
        var x = coordinates[0];
        var y = coordinates[1];

        if (x >= 64 && x <= 352 && y >= 186 && y <= 268) {
            return keepSavedMatch();
        }

        if (x >= 92 && x <= 324 && y >= 274 && y <= 352) {
            PersistenceManager.clearMatch();
            WatchUi.switchToView(
                new ServerSelectionView(),
                new ServerSelectionDelegate(PersistenceManager.loadSettings()),
                WatchUi.SLIDE_LEFT
            );
            return true;
        }

        return true;
    }

    function onBack() {
        return keepSavedMatch();
    }

    function onPreviousMode() {
        return keepSavedMatch();
    }

    function keepSavedMatch() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
