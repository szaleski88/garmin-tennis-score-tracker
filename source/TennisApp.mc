using Toybox.Application;

class TennisApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [new MainMenuView(), new TennisMenuDelegate()];
    }
}
