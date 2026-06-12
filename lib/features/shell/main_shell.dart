import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/floating_nav.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';
import '../session/start_walk.dart';
import '../settings/settings_screen.dart';

/// Hosts the four bottom-nav destinations under a shared warm background with
/// the floating nav overlaid. The active tab lives in [navIndexProvider] so the
/// voice agent can switch tabs too. The centre nav button starts a session.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _pages = [
    HomeScreen(),
    ProgressScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    return Scaffold(
      body: AppTheme.pageBackground(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: IndexedStack(index: index, children: _pages),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingNav(
                index: index,
                onSelect: (i) => ref.read(navIndexProvider.notifier).set(i),
                onStart: () => startWalk(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
