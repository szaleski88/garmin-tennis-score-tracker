using Toybox.ActivityMonitor;
using Toybox.Time;

class MatchMetrics {
    static function nowSeconds() {
        return Time.now().value();
    }

    static function currentCalories() {
        if (!(Toybox has :ActivityMonitor)) {
            return null;
        }

        var info = ActivityMonitor.getInfo();

        if (info != null && (info has :calories) && info.calories != null) {
            return info.calories;
        }

        return null;
    }

    static function elapsedSeconds(state) {
        if (state.startedAt == null) {
            return 0;
        }

        var endAt = state.finishedAt;

        if (endAt == null || endAt < state.startedAt) {
            endAt = nowSeconds();
        }

        var elapsed = endAt - state.startedAt;

        if (elapsed < 0) {
            return 0;
        }

        return elapsed;
    }

    static function calorieDelta(state) {
        if (state.calorieBaseline == null) {
            return null;
        }

        var current = null;

        if (state.matchFinished && state.calorieFinished != null) {
            current = state.calorieFinished;
        } else {
            current = currentCalories();
        }

        if (current == null) {
            return null;
        }

        var delta = current - state.calorieBaseline;

        if (delta < 0) {
            return 0;
        }

        return delta;
    }

    static function formatDuration(seconds) {
        var hours = seconds / 3600;
        var minutes = (seconds % 3600) / 60;
        var secs = seconds % 60;

        return pad2(hours) + ":" + pad2(minutes) + ":" + pad2(secs);
    }

    static function pad2(value) {
        if (value < 10) {
            return "0" + value;
        }

        return value.toString();
    }
}
