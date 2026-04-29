# Architecture notes

This document explains the internals of `sliding_pill_drawer` for
contributors and curious users. The public API is documented in the
[README](../README.md) and via dartdoc.

## Widget tree

```
SlidingPillDrawer (StatefulWidget)
└── Stack
    ├── widget.body                     ← page content
    ├── AnimatedBuilder                 ← backdrop layer (shown when value > 0)
    │   └── GestureDetector             ← tap-to-close
    │       └── backdropBuilder OR ColoredBox (default 50% black tint)
    ├── PositionedDirectional           ← drawer panel
    │   └── AnimatedBuilder
    │       └── Transform.translate     ← off-screen → on-screen
    │           └── widget.drawerContent
    ├── overlayBuilder?                 ← optional extra layer above backdrop
    └── _buildPillPositioner            ← pill (sticky OR follower)
```

The `Stack` is the sole layout primitive. Everything is positioned manually
so RTL handling can drive both panel translation and pill anchoring from a
single `Directionality.of(context)` lookup.

## Animation lifecycle

`SlidingPillDrawer` owns an `AnimationController` (single-vsync ticker). On
`initState` it calls `controller.attach(_animController)`, which the
`SlidingPillDrawerController` uses internally to forward `addListener` calls.

```
SlidingPillDrawerController          AnimationController
─ value                  ─────►      .value
─ open() / close()       ─────►      .forward() / .reverse()
─ settle()               ─────►      .forward() or .reverse() based on value
─ addListener            ◄─────      .addListener (forwarded)
```

This means **the controller can be created before the widget mounts** and
will simply no-op until attached. On dispose, `detach()` removes the
listener bridge so the controller can outlive a particular widget instance
(e.g. across hot reload).

## Drag handling

The pill is wrapped in a `GestureDetector` that listens for
`onHorizontalDragUpdate`. Each delta is divided by `panelWidth` to convert
pixels to a normalized animation step:

```dart
final delta = details.primaryDelta! / panelWidth;
_animController.value += isRTL ? -delta : delta;
```

This is what gives the pill its "1:1 with the panel" feel — moving the
finger by `panelWidth/2` advances the controller by exactly `0.5`.

On `onHorizontalDragEnd`, the controller snaps either fully open or fully
closed based on whether `value > 0.5`. There is currently no velocity-aware
fling — see the [README roadmap](../README.md#roadmap).

## Follower mode and `LayerLink`

Follower mode is the more interesting half. We need the pill to:

1. Sit on the leading edge of a target widget that is **inside a
   scrollable** body, and follow that target as the user scrolls.
2. Slide horizontally away from that anchor as the drawer opens, riding the
   panel's trailing edge.
3. Disappear cleanly when the target scrolls off-screen — without a
   one-frame flash on the wrong side in RTL.

The mechanism is Flutter's [`LayerLink`](https://api.flutter.dev/flutter/widgets/LayerLink-class.html):

- `SlidingPillDrawerTarget` plants a `CompositedTransformTarget` inside the
  body. Crucially, it wraps it in `Align(alignment: AlignmentDirectional.centerStart)`
  so the leader is anchored to the leading edge in both LTR and RTL.
- `SlidingPillDrawer` renders a `CompositedTransformFollower` in a sibling
  `Stack` slot. The follower paints at the leader's recorded layer offset,
  with a manual `Offset(dragOffset, 0)` added on top to slide along with the
  drag.

### The unlinked-frame flicker (RTL)

`CompositedTransformFollower` paints at its widget-tree position for one
frame before the leader's layer is captured. If we positioned the follower
with `Positioned(left: 0)`, that one-frame paint would land on the *left*
edge — wrong side in RTL. Two safeguards prevent the flash:

```dart
PositionedDirectional(top: 0, start: 0, ...) // leading-edge fallback
CompositedTransformFollower(
  showWhenUnlinked: false,                   // hides during the unlinked frame
  followerAnchor: isRTL ? topRight : topLeft,
  targetAnchor:   isRTL ? topRight : topLeft,
  ...
)
```

`showWhenUnlinked: false` is the belt-and-suspenders safety net — the
`PositionedDirectional` already places the follower on the correct side,
but we hide it for that one frame anyway to avoid any visible jump.

## RTL handling

Direction is read once per `build`:

```dart
final isRTL = Directionality.of(context) == TextDirection.rtl;
```

It's used in three places:

1. **Panel translation:** the panel sits on the leading edge; when closed
   it's translated off-screen toward that edge — `-panelWidth` in LTR,
   `+panelWidth` in RTL.
2. **Drag direction:** opening the drawer means dragging *away* from the
   leading edge — rightward in LTR, leftward in RTL. Drag delta sign is
   flipped accordingly.
3. **Follower anchor:** `topLeft` in LTR, `topRight` in RTL, so the pill
   anchors to the correct screen edge.

Everything else (`PositionedDirectional`, `EdgeInsetsDirectional`,
`BorderRadiusDirectional`) handles itself via the ambient `Directionality`.

## Why no scroll-clipping concern in sticky mode?

In sticky mode the pill is rendered in the host `Stack`, **above** the
`body`. It never participates in the body's scroll, so no clipping logic is
needed. In follower mode, the pill is also rendered in the same `Stack`,
but its position is derived from a target *inside* the scrollable — so it
appears to scroll, even though it physically lives in a separate paint
layer. This avoids re-laying-out scrollable contents every frame and keeps
60 fps on long lists.
