# Changelog

## 1.0.1

No public API changes — packaging, documentation, and quality improvements.

### Documentation
- Rewrote README with badges, full feature list, demo placeholders, expanded
  usage examples, complete API reference, architecture notes, and roadmap.
- Added `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, GitHub issue templates, and
  pull-request template.
- Added `doc/CAPTURE.md` with instructions for recording the demo media used
  by the README and pub.dev screenshots.
- Added `doc/architecture.md` explaining the `LayerLink` /
  `CompositedTransformFollower` follower-mode mechanism.
- Filled in dartdoc for every public member (typedefs, classes,
  constructors, fields, methods).

### Quality
- Strengthened `analysis_options.yaml`: enabled `public_member_api_docs`,
  `package_api_docs`, `prefer_single_quotes`, `require_trailing_commas`,
  `sort_constructors_first`, `sort_pub_dependencies`, `use_super_parameters`,
  `always_declare_return_types`, `unawaited_futures`, and strict type
  inference (`strict-casts`, `strict-inference`, `strict-raw-types`).
- Reordered class members so constructors come first.
- Added widget tests for drag-to-open/close, backdrop tap-to-close, sticky
  positioning, custom `pillBuilder`, custom `backdropBuilder`, and RTL
  panel mirroring.
- Added unit tests for `DefaultPill` (chevron direction in LTR/RTL, tap
  callback, fade-out as animation progresses).

### CI / publishing
- Added GitHub Actions: `ci.yml` (format + analyze + test on push and PR),
  `example-build.yml` (verify the example app still builds), and
  `publish.yml` (tag-driven pub.dev release via OIDC trusted publishing).
- Added `.github/dependabot.yml` for weekly GitHub Actions and pub
  dependency updates.

### Pub.dev metadata
- Added `topics` (`drawer`, `navigation`, `animation`, `rtl`, `ui`),
  `screenshots`, and `documentation` fields to `pubspec.yaml`.

## 1.0.0

Initial release.

- `SlidingPillDrawer` widget that wraps any page with a draggable side drawer.
- Two placement modes:
  - **Sticky** — pill pinned at a fixed vertical offset (`stickyTop`).
  - **Follower** — pill attached to a `SlidingPillDrawerTarget` via a `LayerLink`, so it scrolls with the body.
- `SlidingPillDrawerController` for imperative `open()` / `close()` / `toggle()` and reading `value` / `isOpen`.
- Horizontal drag on the pill moves the panel 1:1 with the finger and snaps based on final position.
- Full RTL / LTR support via `Directionality`.
- Customizable pill via `pillBuilder`, or replace only the default text via `defaultPillText`.
- Tunable `panelWidthFraction` and `animationDuration`.
- Zero external dependencies.
