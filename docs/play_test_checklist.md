# Venu 2 Plus Play-Test Checklist

Use a physical Venu 2 Plus for the final pass. Test outdoors and while walking or lightly jogging; the desktop simulator cannot validate wrist-angle readability, sweat, glove behavior, vibration strength, or accidental presses.

## Visual and Circular-Screen Pass

- Inspect every screen at normal wrist distance with display brightness at low, medium, and high.
- Confirm no title, value, button, close icon, page dot, or notice touches the bezel or clips at the circular edge.
- Confirm the live point score is readable in a quick glance while moving.
- Confirm orange always identifies the court/primary action, red identifies set/danger, green identifies game/win, and yellow identifies the ball/attention notice.
- Confirm muted gray copy remains readable without competing with scores and actions.
- Confirm no animation leaves stale or partially drawn text after it settles.

## Main Menu and Recovery

- With no saved match, verify the menu contains Start Match and Settings only.
- With an active saved match, verify Resume Match appears with a compact score summary.
- Resume and confirm score, server, rules, statistics, and undo history are restored.
- With a finished saved match, verify View Last Match appears instead of Resume Match.
- Select Start Match while a match is saved; verify the guarded warning appears.
- Choose Keep saved and verify no score or settings are changed.
- Choose Start new and verify the old match is cleared only after that explicit action.

## Setup, Rules, and Settings

- Select both You and Opponent as first server and verify the rule summary changes correctly.
- Verify Best of 3 and Best of 5 summaries show scoring, games per set, and final-set mode.
- Verify TB Match shows “First to 7, win by 2.”
- Verify STB Match shows “First to 10, win by 2.”
- Open Change rules, edit each setting, save, and verify the rule-confirmation screen updates.
- Open Change rules, edit each setting, cancel, and verify all original values are restored.
- Confirm TB/STB settings hide irrelevant game, tie-break-at, and final-set rows.
- Confirm Back from rule confirmation returns to server selection without starting or saving a match.

## Live Scoring and Touch Targets

- Verify set, point, and game values do not collide for 0, 15, 30, 40, AD, and two-digit tie-break scores.
- Verify the serving ball never obscures a value or the Me/OP label.
- Tap the top half ten times while moving; verify exactly ten opponent points are recorded.
- Tap the bottom half ten times while moving; verify exactly ten player points are recorded.
- Verify taps close to the center divider still score the intended half.
- Swipe left and up; verify each gesture undoes exactly one stored point.
- Swipe right and down; verify each gesture opens pause without changing the score.
- Verify the duration, time, calories, and battery values remain inside the safe area.

## Hardware Controls

- Press the top hardware button; verify it scores the opponent.
- Press the bottom hardware button; verify it scores the player without closing the app.
- Press the middle hardware button; verify it undoes one point.
- Repeat each control with the display wet and while the wrist is moving.
- Verify hardware input is ignored while the SWITCH SIDES notice is visible.

## Side Switch and Notices

- In TB and STB formats, score the sixth point and verify triple vibration plus SWITCH SIDES.
- While the notice is visible, tap both halves, swipe, and press every hardware button; verify the score and navigation do not change.
- Verify scoring resumes normally after the notice clears.
- Confirm the notice text and outline remain clear over both score halves.

## Pause, Current Stats, and Exit

- Open pause and verify Resume match is the dominant orange action.
- Verify View stats and Exit & save are visually distinct and do not overlap.
- Open current stats before the first point; verify the empty-state message appears.
- After scoring, verify points, service points, break points, point streak, and game streak compare Me with OP.
- Swipe through every current-stat page and verify page dots track the current page.
- Close stats with the close target, Back, and right swipe; each should return to pause.
- Open Exit & save; verify Keep playing is the primary action and Back returns safely.
- Confirm Exit & save; relaunch the app and verify recovery data is intact.

## Scoring Rules

- Standard advantage: exercise deuce, advantage each side, return to deuce, and game by two.
- No-ad: reach 40-40, verify two serving-side balls, and confirm the next point wins the game.
- Standard set: finish 6-0 and 6-4; verify set and game resets.
- Tie-break set: reach 6-6, verify numeric scoring and A-BB-AA serving order, then finish 7-5.
- Full final set: verify it continues until a two-game lead.
- STB final set: verify it starts only in the deciding set and ends at 10 by two.
- Standalone TB and STB matches: verify the winner and final point score are reported correctly.

## Undo and Persistence

- Undo a normal point, game-winning point, set-winning point, and match-winning point.
- Verify server, stage, totals, streaks, break points, duration state, and match status restore each time.
- Score six points, undo five times, and verify a sixth undo does not change the score.
- Exit and resume after an undo; verify the restored state and available undo history persist.

## Finished Match and Final Stats

- Finish once as the player and once as the opponent; verify YOU WON/YOU LOST uses the correct green/red semantic color.
- Verify a normal match reports the final set score and TB/STB matches report the final point score.
- Select Undo match point and verify live scoring returns to the exact pre-match-point state.
- Finish again, open View stats, and inspect all three final-stat pages.
- Verify page 1 contains points, games, service points, and break points.
- Verify page 2 contains best point streak, best game streak, and max point lead.
- Verify page 3 contains duration and calories.
- Exit to menu and verify View Last Match opens the finished summary and final stats again.
