import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sliding_pill_drawer/sliding_pill_drawer.dart';

void main() => runApp(const SlidingPillDrawerDemoApp());

class SlidingPillDrawerDemoApp extends StatelessWidget {
  const SlidingPillDrawerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sliding_pill_drawer demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _rtl = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('sliding_pill_drawer'),
          actions: [
            const Text('RTL'),
            Switch(
              value: _rtl,
              onChanged: (v) => setState(() => _rtl = v),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Sticky', icon: Icon(Icons.push_pin_outlined)),
              Tab(text: 'Follower', icon: Icon(Icons.list_alt_outlined)),
              Tab(text: 'Custom', icon: Icon(Icons.auto_awesome_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: const [
            StickyDemo(),
            FollowerDemo(),
            CustomDemo(),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenu extends StatelessWidget {
  const _DrawerMenu();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 12,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [scheme.primary, scheme.tertiary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.onPrimary,
                    child: Text(
                      'JD',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Masoud Saeidi',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'masoud.saeedi.dev@gmail.com',
                    style: TextStyle(
                      color: scheme.onPrimary.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final item in const [
              ('Home', Icons.home_outlined),
              ('Profile', Icons.person_outline),
              ('Notifications', Icons.notifications_outlined),
              ('Bookmarks', Icons.bookmark_border),
              ('Settings', Icons.settings_outlined),
            ])
              ListTile(
                leading: Icon(item.$2),
                title: Text(item.$1),
                onTap: () {},
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text('Logout', style: TextStyle(color: scheme.error)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class StickyDemo extends StatefulWidget {
  const StickyDemo({super.key});

  @override
  State<StickyDemo> createState() => _StickyDemoState();
}

class _StickyDemoState extends State<StickyDemo> {
  final _controller = SlidingPillDrawerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return SlidingPillDrawer(
      controller: _controller,
      isSticky: true,
      drawerContent: const _DrawerMenu(),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemCount: 30,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text('Sticky card #${i + 1}'),
            subtitle: const Text('Scroll the list — the pill stays pinned.'),
            trailing: Icon(isRTL ? Icons.chevron_left : Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}

class FollowerDemo extends StatefulWidget {
  const FollowerDemo({super.key});

  @override
  State<FollowerDemo> createState() => _FollowerDemoState();
}

class _FollowerDemoState extends State<FollowerDemo> {
  final _controller = SlidingPillDrawerController();
  final _link = LayerLink();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SlidingPillDrawer(
      controller: _controller,
      link: _link,
      drawerContent: const _DrawerMenu(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [scheme.primary, scheme.tertiary],
              ),
            ),
            alignment: AlignmentDirectional.bottomStart,
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Follower mode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SlidingPillDrawerTarget(link: _link),
          for (int i = 0; i < 30; i++)
            ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text('Scrollable item #${i + 1}'),
              subtitle: const Text('The pill scrolls together with this list.'),
            ),
        ],
      ),
    );
  }
}

class CustomDemo extends StatefulWidget {
  const CustomDemo({super.key});

  @override
  State<CustomDemo> createState() => _CustomDemoState();
}

class _CustomDemoState extends State<CustomDemo> {
  final _controller = SlidingPillDrawerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingPillDrawer(
      controller: _controller,
      isSticky: true,
      stickyTop: 240,
      panelWidthFraction: 0.78,
      animationDuration: const Duration(milliseconds: 450),
      drawerContent: const _DrawerMenu(),
      backdropBuilder: (context, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            final v = animation.value;
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: v * 8, sigmaY: v * 8),
              child: ColoredBox(
                color: Colors.black.withValues(alpha: v * 0.25),
              ),
            );
          },
        );
      },
      pillBuilder: (context, animation) {
        return _GradientPill(
          animation: animation,
          onTap: _controller.toggle,
        );
      },
      body: _CustomBody(controller: _controller),
    );
  }
}

class _GradientPill extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onTap;

  const _GradientPill({required this.animation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(
          end: Radius.circular(28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.tertiary],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5).animate(animation),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor:
                      Tween<double>(begin: 1, end: 0).animate(animation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0).animate(animation),
                    child: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 10),
                      child: Text(
                        'MENU',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomBody extends StatelessWidget {
  final SlidingPillDrawerController controller;

  const _CustomBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.5),
            scheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Custom mode',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Custom pill, blurred backdrop, and programmatic control.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: controller.open,
                    icon: Transform.flip(
                      flipX: isRTL,
                      child: const Icon(Icons.menu_open),
                    ),
                    label: const Text('Open'),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.close,
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                  TextButton.icon(
                    onPressed: controller.toggle,
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Toggle'),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text('Live animation value', style: textTheme.titleMedium),
              const SizedBox(height: 10),
              ListenableBuilder(
                listenable: controller,
                builder: (_, __) {
                  final v = controller.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        v.toStringAsFixed(2),
                        style: textTheme.titleLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              Card(
                color: scheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          color: scheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Drag the pill horizontally to open/close — '
                          'or use the buttons above for programmatic control.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
