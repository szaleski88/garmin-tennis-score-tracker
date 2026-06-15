using Toybox.WatchUi;

class ServerSelectionView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Who Serves First?"});
        addItem(new MenuItem("Me", null, "me", {}));
        addItem(new MenuItem("Opponent", null, "opponent", {}));
    }
}
