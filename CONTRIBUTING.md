# Contributing

Thanks for considering a contribution to `sliding_pill_drawer`! This guide
covers the practical setup and conventions. By participating you also
agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Local setup

```bash
git clone https://github.com/masoudcoder/sliding_pill_drawer.git
cd sliding_pill_drawer
flutter pub get

# Run the example app
cd example
flutter pub get
flutter run
```

The package is pure Dart/Flutter with zero runtime dependencies, so any
recent Flutter stable channel (>= 3.27) works out of the box.

## Branching

- `main` is the release branch. Tagged commits on `main` publish to
  pub.dev via the `publish.yml` workflow.
- Branch names: `feat/<short-name>`, `fix/<short-name>`,
  `docs/<short-name>`, `chore/<short-name>`. One topic per branch.

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add velocity-based fling
fix: prevent flicker on first frame in RTL
docs: clarify follower-mode anchor behavior
test: add widget test for backdrop tap-to-close
refactor: extract pill positioner into its own widget
chore: bump flutter_lints
```

Scope the imperative subject to ≤ 72 chars. Body, if any, explains *why*
not *what*.

## Code style

- Run `dart format .` before pushing — CI enforces it.
- Run `flutter analyze` — must be clean. The repo enables strict lints
  (`public_member_api_docs`, `prefer_single_quotes`,
  `require_trailing_commas`, `sort_constructors_first`, etc.) in
  [`analysis_options.yaml`](analysis_options.yaml).
- Public API additions need dartdoc (`///`). Private helpers don't.

## Tests

- Run `flutter test` from the package root before opening a PR. CI runs
  the same on every push.
- Add a test for any bugfix (regression test) and any new public API.
- Prefer widget tests over unit tests when the change is visible (drag,
  layout, RTL behavior, backdrop interaction).

## Pull request checklist

- [ ] `dart format --set-exit-if-changed .` is clean.
- [ ] `flutter analyze --fatal-infos` is clean.
- [ ] `flutter test` passes.
- [ ] `CHANGELOG.md` has an entry under an `## Unreleased` heading or a
      new minor/patch version.
- [ ] Public API changes are documented with dartdoc.
- [ ] If visuals changed, update or note the screenshots in
      [`doc/CAPTURE.md`](doc/CAPTURE.md).

## Releasing (maintainers only)

1. Bump `version` in `pubspec.yaml`.
2. Move the `## Unreleased` section in `CHANGELOG.md` under the new
   version heading and add the date.
3. Commit, tag with `v<version>` (e.g. `v1.0.2`), push the tag.
4. The `publish.yml` workflow handles the pub.dev release via OIDC
   trusted publishing — no token management needed.
