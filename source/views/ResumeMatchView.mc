using Toybox.WatchUi;

class ResumeMatchView extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Saved Match"});
        addItem(new MenuItem("Resume", null, "resume", {}));
        addItem(new MenuItem("Discard", null, "discard", {}));
    }
}
