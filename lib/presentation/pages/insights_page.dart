import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import '../../domain/models/event.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);
    final events = eventState.events;
    final totalEvents = events.length;
    final completedEvents = events.where((e) => e.isCompleted).length;
    final completionRate = totalEvents > 0
        ? (completedEvents / totalEvents)
        : 0.0;

    final categoryMap = <EventCategory, int>{};
    for (final event in events) {
      categoryMap[event.category] = (categoryMap[event.category] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildConsistencyCard(context, completionRate, totalEvents),
                const SizedBox(height: 48),
                _buildSectionHeader(context, '01 . CORE METRICS'),
                const SizedBox(height: 20),
                _buildMetricsGrid(context, events),
                const SizedBox(height: 48),
                _buildSectionHeader(context, '02 . CATEGORY FLOW'),
                const SizedBox(height: 20),
                _buildCategoryList(context, categoryMap),
                const SizedBox(height: 48),
                _buildEngagementSection(context),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 24, bottom: 16),
        title: Text(
          'Productivity Flow',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.black),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildConsistencyCard(BuildContext context, double rate, int total) {
    final percentage = (rate * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.bolt_rounded, size: 120, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONSISTENCY',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 56,
                      letterSpacing: -2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: Colors.greenAccent,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Based on $total analyzed events this month',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, List<Event> events) {
    final today = events.where((e) => e.isToday).length;
    final critical = events
        .where((e) => e.priority == EventPriority.high)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            today.toString(),
            'TODAY',
            Icons.timer_rounded,
            Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            critical.toString(),
            'CRITICAL',
            Icons.bolt_rounded,
            Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    Map<EventCategory, int> breakdown,
  ) {
    final sortedCategories = EventCategory.values.toList()
      ..sort((a, b) => (breakdown[b] ?? 0).compareTo(breakdown[a] ?? 0));

    return Column(
      children: sortedCategories.take(5).map((cat) {
        final count = breakdown[cat] ?? 0;
        final progress =
            (count /
                    (breakdown.values.isEmpty
                        ? 1
                        : breakdown.values.reduce((a, b) => a + b)))
                .clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cat.uiColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        cat.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$count events',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(cat.uiColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEngagementSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Sync',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Icon(
                Icons.auto_graph_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final heights = [40.0, 70.0, 55.0, 90.0, 65.0, 30.0, 15.0];
              final isToday = i == DateTime.now().weekday - 1;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: 24,
                    height: heights[i],
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    days[i],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

extension EventCategoryX on EventCategory {
  Color get uiColor {
    switch (this) {
      case EventCategory.personal:
        return Colors.blueAccent;
      case EventCategory.work:
        return Colors.orangeAccent;
      case EventCategory.health:
        return Colors.greenAccent;
      case EventCategory.education:
        return Colors.purpleAccent;
      case EventCategory.entertainment:
        return Colors.pinkAccent;
      case EventCategory.social:
        return Colors.indigoAccent;
      case EventCategory.travel:
        return Colors.tealAccent;
      case EventCategory.birthday:
        return Colors.pink;
      case EventCategory.other:
        return Colors.blueGrey;
    }
  }
}
