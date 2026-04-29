# sliding_pill_drawer example

Runnable demo of the `sliding_pill_drawer` package.

```bash
cd example
flutter create .      # first time only — regenerates android/ios/web/... folders
flutter pub get
flutter run
```

The demo provides two tabs:

- **Sticky** — the pill stays pinned at a fixed vertical offset while the list scrolls behind it.
- **Follower** — the pill is attached to a `SlidingPillDrawerTarget` placed inside a `ListView`, so it scrolls with the list.

Toggle the RTL switch in the app bar to see the mirrored layout.
