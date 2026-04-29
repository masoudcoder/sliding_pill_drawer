# Capture guide

This file documents the demo media used by [`README.md`](../README.md) and
the `screenshots:` block in [`pubspec.yaml`](../pubspec.yaml). The current
captures are committed; this guide exists for re-recording (e.g. after a
visual change).

## Current files

| File | Used by | Subject |
|------|---------|---------|
| `doc/screenshots/01_sliding_pill_drawer_example.jpg` | README, pub.dev | Sticky mode at rest. |
| `doc/screenshots/02_sliding_pill_drawer_example.jpg` | README, pub.dev | Sticky mode mid-drag (panel half-open, gradient visible). |
| `doc/screenshots/03_sliding_pill_drawer_example.jpg` | README, pub.dev | Sticky mode fully open with menu header. |
| `doc/screenshots/sticky__sliding_pill_drawer.gif` | README | Animated sticky mode loop. |
| `doc/screenshots/follower__sliding_pill_drawer.gif` | README | Animated follower mode loop. |
| `doc/screenshots/custom__sliding_pill_drawer.gif` | README | Animated custom pill / backdrop loop. |

> When updating the captures, **keep these exact file names** — both the
> README and `pubspec.yaml` reference them by path.

## Size targets

- **JPG screenshots:** ≤ 400 KB each. pub.dev rejects screenshots above
  ~4 MB and counts the rest against the package size.
- **GIFs:** keep under 3 MB each so pub.dev can render them inline.
  Anything bigger and pub.dev falls back to a link.

## Tools

- **Windows** — [ScreenToGif](https://www.screentogif.com/) (free, exports
  GIF/APNG, has a frame editor).
- **macOS** — built-in `Cmd+Shift+5` for video → convert with
  [Gifski](https://gif.ski/) or
  `ffmpeg -i in.mov -vf "fps=24,scale=480:-1" out.gif`.
- **iOS Simulator / Android emulator** — built-in screen recorders, then
  convert as above.
- **Stills** — `Cmd+Shift+4` (mac) / `Snipping Tool` (Windows) / device-side
  screenshot, then crop to the simulator window.

## Capture checklist

Run the example app first:

```bash
cd example
flutter run
```

For each shot:

1. **Clean status bar.** In iOS Simulator:
   `xcrun simctl status_bar "booted" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3`.
   On Android emulator use a demo-mode profile.
2. **Light theme, default Material 3 colors.** Avoid theming — keep
   visuals neutral.
3. **Capture both LTR and RTL** for the GIFs — flip the toolbar toggle in
   the example app and let it animate.
4. **Show the drag.** A static fully-open or fully-closed shot is less
   informative than mid-animation. For JPG stills, pause at ~50% open by
   holding the drag; for GIFs, include at least one open + close cycle.
5. **Pad bottoms.** Trim everything below the home indicator so
   screenshots aren't dominated by black.

## Verifying

After replacing the files:

```bash
flutter pub publish --dry-run
```

Confirm each path in the `screenshots:` block resolves and the README's
relative `<img>` and Markdown image references render in GitHub's
Markdown preview.
