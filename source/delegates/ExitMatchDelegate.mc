using Toybox.System;
using Toybox.WatchUi;

class ExitMatchDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onTap(clickEvent) {
        var y = clickEvent.getCoordinates()[1];

        if (y >= 176 && y <= 257) {
            System.exit();
            return true;
        }

        if (y >= 258 && y <= 342) {
            return keepPlaying();
        }

        return true;
    }

    function onBack() {
        return keepPlaying();
    }

    function onPreviousMode() {
        return keepPlaying();
    }

    function keepPlaying() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
