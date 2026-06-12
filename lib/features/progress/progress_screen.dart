import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/stat_card.dart';
import 'all_sessions_screen.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static const _week = [12, 0, 18, 8, 22, 15, 10];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _cadence = [102, 0, 108, 99, 110, 107, 95];
  static const _steps = [520, 0, 740, 405, 895, 642, 450];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
          AppSpacing.lg, AppSpacing.navClearance),
      children: [
        Text(l10n?.progress ?? 'Progress', style: AppType.h1),
        const SizedBox(height: AppSpacing.md),
        _QuoteCard(
          quote: AppLocalizations.of(context)?.progressQuote ??
              'Every step you take is a small act of courage.',
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.directions_walk,
                value: '12',
                caption: l10n?.totalSessions ?? 'Total sessions',
                accent: AppColors.primary,
                showStrip: false,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department,
                value: '5',
                caption: l10n?.thisWeek ?? 'This week',
                accent: AppColors.primary,
                showStrip: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ChartAndSummaryCard(
            week: _week, days: _days, cadence: _cadence, steps: _steps),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n?.recentSessions ?? 'Recent sessions', style: AppType.h2),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AllSessionsScreen())),
              child: Text(l10n?.seeAll ?? 'See all',
                  style: AppType.label.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SessionTile(date: 'Today · 9:12', steps: 642, mins: 6),
        const _SessionTile(date: 'Yesterday · 5:40', steps: 1180, mins: 11),
        const _SessionTile(date: 'Mon · 8:30', steps: 980, mins: 9),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});
  final String quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.pinkGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: 4,
            child: Icon(
              Icons.format_quote_rounded,
              color: Colors.white.withValues(alpha: 0.10),
              size: 88,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.todaysNote ?? "Today's note",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: kFontFamily,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                quote,
                style: AppType.displaySerif.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartAndSummaryCard extends StatefulWidget {
  const _ChartAndSummaryCard({
    required this.week,
    required this.days,
    required this.cadence,
    required this.steps,
  });
  final List<int> week;
  final List<String> days;
  final List<int> cadence;
  final List<int> steps;

  @override
  State<_ChartAndSummaryCard> createState() => _ChartAndSummaryCardState();
}

class _ChartAndSummaryCardState extends State<_ChartAndSummaryCard> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxY =
        (widget.week.reduce((a, b) => a > b ? a : b) + 6).toDouble();

    // Determine summary row values
    final String cadenceVal;
    final String durationVal;
    final String stepsVal;
    final String cadenceLabel;
    final String durationLabel;
    final String stepsLabel;

    if (_selectedDay == null) {
      cadenceLabel = l10n?.avgCadence ?? 'Avg cadence';
      durationLabel = l10n?.totalWalkTime ?? 'Total walking time';
      stepsLabel = l10n?.walksThisWeek ?? 'Walks this week';
      cadenceVal = '108 steps/min';
      durationVal = '1h 25m';
      stepsVal = '6';
    } else if (widget.week[_selectedDay!] > 0) {
      cadenceLabel = l10n?.avgCadence ?? 'Cadence';
      durationLabel = l10n?.duration ?? 'Duration';
      stepsLabel = l10n?.steps ?? 'Steps';
      cadenceVal = '${widget.cadence[_selectedDay!]} steps/min';
      durationVal = '${widget.week[_selectedDay!]} min';
      stepsVal = '${widget.steps[_selectedDay!]}';
    } else {
      cadenceLabel = l10n?.avgCadence ?? 'Cadence';
      durationLabel = l10n?.duration ?? 'Duration';
      stepsLabel = l10n?.steps ?? 'Steps';
      cadenceVal = '--';
      durationVal = '--';
      stepsVal = '--';
    }

    return Container(
      decoration: AppTheme.cardDecoration(radius: 18),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n?.thisWeek ?? 'This week',
                            style: AppType.label),
                        const SizedBox(height: 2),
                        Text(l10n?.minutesWalked ?? 'Minutes walked',
                            style: AppType.h2.copyWith(fontSize: 19)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.okSoft,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up,
                              color: AppColors.connected, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+12%',
                            style: AppType.label.copyWith(
                              color: AppColors.connected,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchCallback:
                            (FlTouchEvent event, BarTouchResponse? response) {
                          if (!event.isInterestedForInteractions) return;
                          final idx =
                              response?.spot?.touchedBarGroupIndex;
                          if (idx == null) return;
                          setState(() {
                            _selectedDay =
                                _selectedDay == idx ? null : idx;
                          });
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          getTooltipItem: (a, b, c, d) => null,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                widget.days[
                                    value.toInt() % widget.days.length],
                                style: AppType.label.copyWith(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < widget.week.length; i++)
                          BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: widget.week[i].toDouble(),
                              width: 18,
                              gradient: i == _selectedDay
                                  ? const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.fab
                                      ],
                                    )
                                  : null,
                              color: i == _selectedDay
                                  ? null
                                  : AppColors.surfaceDeep,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.lineSoft),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _SummaryRow(label: cadenceLabel, value: cadenceVal),
                const Divider(
                    height: AppSpacing.lg,
                    thickness: 1,
                    color: AppColors.lineSoft),
                _SummaryRow(label: durationLabel, value: durationVal),
                const Divider(
                    height: AppSpacing.lg,
                    thickness: 1,
                    color: AppColors.lineSoft),
                _SummaryRow(label: stepsLabel, value: stepsVal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.fab,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppType.body.copyWith(fontSize: 16)),
        const Spacer(),
        Text(value, style: AppType.h2.copyWith(fontSize: 18)),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile(
      {required this.date, required this.steps, required this.mins});
  final String date;
  final int steps;
  final int mins;

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_walk,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: AppType.h2.copyWith(fontSize: 16)),
                  Text('$steps steps · ${mins}m', style: AppType.label),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
