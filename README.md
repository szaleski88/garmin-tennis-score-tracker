# Tennis Score Tracker for Garmin Venu 2 Plus

Touch-first Garmin Connect IQ watch app for fast tennis scoring on the Venu 2 Plus.

## Features

- Venu 2 Plus target, 416x416 round AMOLED layout
- Pure black match screen with large score text
- Top-half tap scores opponent, bottom-half tap scores player
- Upper hardware button scores opponent, lower button scores player, middle button undoes the last point
- Swipe right opens exit confirmation
- Best-of-3, best-of-5, tie-break-only, super-tie-break-only formats
- Normal, no-ad, tie-break, super tie-break, short-set rules via settings
- Rules confirmation before each match starts
- Server indicator with PNG tennis ball asset
- Undo/redo snapshots capped at 5
- Match/settings/history recovery with `Toybox.Application.Storage`
- Haptic patterns for point, game, set, and match events
- Serve-side arrow: left on even points, right on odd points, both at golden point
- Triple haptic and "SWITCH SIDES" notice every six tie-break/super tie-break points
- Optional match-end stats for points, break points, streaks, service points, duration, and calories

## Project Layout

```text
source/
  TennisApp.mc
  model/
  scoring/
  views/
  delegates/
resources/
  drawables/
  images/
  layouts/
  menus/
  strings/
docs/
  play_test_checklist.md
```

## Build

Install the Garmin Connect IQ SDK and Venu 2 Plus device package, then create or choose a developer key.

```sh
monkeyc -f monkey.jungle -d venu2plus -y developer_key.der -o bin/TennisScoreTracker.prg
```

Run in the simulator:

```sh
monkeydo bin/TennisScoreTracker.prg venu2plus
```

Export for device/store testing:

```sh
monkeyc -e -f monkey.jungle -y developer_key.der -o bin/TennisScoreTracker.iq
```

## GitHub Actions Build

The workflow at `.github/workflows/connectiq-build.yml` can compile the Venu 2 Plus `.prg` on GitHub. It uses `connect-iq-sdk-manager-cli` to install the Connect IQ SDK and download the Venu 2 Plus device package.

Add these repository secrets:

- `GARMIN_USERNAME`
- `GARMIN_PASSWORD`
- `GARMIN_AGREEMENT_HASH`

To get the agreement hash locally:

```sh
go install github.com/lindell/connect-iq-sdk-manager-cli@v0.8.4
connect-iq-sdk-manager agreement view
```

After reading and accepting Garmin's SDK agreement, put the displayed hash in `GARMIN_AGREEMENT_HASH`.

Optional secrets/variables:

- `GARMIN_DEVELOPER_KEY_DER_BASE64`: stable signing key for repeatable sideload/store builds. If omitted, CI creates a temporary key.
- `CIQ_SDK_VERSION`: SDK semver range, defaults to `^9.2.0`.

To encode an existing key:

```sh
base64 -i developer_key.der
```

## Install

For sideload testing, connect the Venu 2 Plus over USB and copy the generated `.prg` into `GARMIN/APPS`.

## Notes

This workspace did not have a local Connect IQ SDK installed, so compilation could not be run here. The code avoids Java-style listener porting and uses explicit score-state evaluation.
