using Toybox.WatchUi;

class IndividualServerSelectionView extends WatchUi.Menu2 {
    function initialize(playerTeam) {
        Menu2.initialize({:title=>"Who serves first?"});

        if (playerTeam) {
            addItem(new MenuItem("ME", null, "first", {}));
            addItem(new MenuItem("P", null, "second", {}));
        } else {
            addItem(new MenuItem("OP 1", null, "first", {}));
            addItem(new MenuItem("OP 2", null, "second", {}));
        }
    }
}
