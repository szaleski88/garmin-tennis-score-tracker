using Toybox.System;
using Toybox.WatchUi;

class ExitMatchDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onTap(clickEvent) {
        var y = clickEvent.getCoordinates()[1];

        if (y >= 186 && y <= 266) {
            return keepPlaying();
        }

        if (y >= 270 && y <= 350) {
            System.exit();
            return true;
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
