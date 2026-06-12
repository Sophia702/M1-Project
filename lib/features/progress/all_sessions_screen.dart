import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

enum _SortOrder { latestFirst, oldestFirst, longestSession, mostSteps }

class AllSessionsScreen extends ConsumerStatefulWidget {
  const AllSessionsScreen({super.key});
  @override
  ConsumerState<AllSessionsScreen> createState() => _AllSessionsScreenState();
}

class _MockSession {
  final String date;
  final int steps;
  final int mins;
  final DateTime dt;
  const _MockSession(
      {required this.date,
      required this.steps,
      required this.mins,
      required this.dt});
}

class _AllSessionsScreenState extends ConsumerState<AllSessionsScreen> {
  _SortOrder _sort = _SortOrder.latestFirst;

  static final _sessions = [
    _MockSession(
        date: 'Today · 9:12',
        steps: 642,
        mins: 6,
        dt: DateTime(2026, 6, 12, 9, 12)),
    _MockSession(
        date: 'Yesterday · 5:40',
        steps: 1180,
        mins: 11,
        dt: DateTime(2026, 6, 11, 5, 40)),
    _MockSession(
        date: 'Mon · 8:30',
        steps: 980,
        mins: 9,
        dt: DateTime(2026, 6, 9, 8, 30)),
    _MockSession(
        date: 'Sun · 7:15',
        steps: 1340,
        mins: 15,
        dt: DateTime(2026, 6, 8, 7, 15)),
    _MockSession(
        date: 'Sat · 10:00',
        steps: 760,
        mins: 7,
        dt: DateTime(2026, 6, 7, 10, 0)),
    _MockSession(
        date: 'Fri · 6:45',
        steps: 1050,
        mins: 10,
        dt: DateTime(2026, 6, 6, 6, 45)),
    _MockSession(
        date: 'Thu · 9:20',
        steps: 880,
        mins: 8,
        dt: DateTime(2026, 6, 5, 9, 20)),
    _MockSession(
        date: 'Wed · 8:00',
        steps: 1240,
        mins: 12,
        dt: DateTime(2026, 6, 4, 8, 0)),
    _MockSession(
        date: 'Tue · 7:30',
        steps: 720,
        mins: 7,
        dt: DateTime(2026, 6, 3, 7, 30)),
    _MockSession(
        date: 'Mon · 9:00',
        steps: 1450,
        mins: 14,
        dt: DateTime(2026, 6, 2, 9, 0)),
    _MockSession(
        date: 'Sun · 10:30',
        steps: 590,
        mins: 6,
        dt: DateTime(2026, 6, 1, 10, 30)),
    _MockSession(
        date: 'Sat · 8:15',
        steps: 1120,
        mins: 11,
        dt: DateTime(2026, 5, 31, 8, 15)),
  ];

  List<_MockSession> get _sorted {
    final list = List<_MockSession>.from(_sessions);
    switch (_sort) {
      case _SortOrder.latestFirst:
        list.sort((a, b) => b.dt.compareTo(a.dt));
      case _SortOrder.oldestFirst:
        list.sort((a, b) => a.dt.compareTo(b.dt));
      case _SortOrder.longestSession:
        list.sort((a, b) => b.mins.compareTo(a.mins));
      case _SortOrder.mostSteps:
        list.sort((a, b) => b.steps.compareTo(a.steps));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessions = _sorted;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.allSessions ?? 'All sessions'),
        backgroundColor: AppColors.bgTop,
        foregroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<_SortOrder>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SortOrder.latestFirst,
                child: Text(l10n?.sortLatest ?? 'Latest first'),
              ),
              PopupMenuItem(
                value: _SortOrder.oldestFirst,
                child: Text(l10n?.sortOldest ?? 'Oldest first'),
              ),
              PopupMenuItem(
                value: _SortOrder.longestSession,
                child: Text(l10n?.sortLongest ?? 'Longest first'),
              ),
              PopupMenuItem(
                value: _SortOrder.mostSteps,
                child: Text(l10n?.sortMostSteps ?? 'Most steps'),
              ),
            ],
          ),
        ],
      ),
      body: AppTheme.pageBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: AppTheme.cardDecoration(radius: 18),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: AppColors.primarySoft, shape: BoxShape.circle),
                      child: const Icon(Icons.directions_walk,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.date,
                              style: AppType.h2.copyWith(fontSize: 16)),
                          Text('${session.steps} steps · ${session.mins}m',
                              style: AppType.label),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkFaint),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
