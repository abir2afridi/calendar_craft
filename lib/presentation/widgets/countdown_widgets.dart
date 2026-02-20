import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/event.dart';
import '../../../core/services/countdown_service.dart';

class EventCountdownWidget extends ConsumerWidget {
  final Event event;
  final bool isDark;

  const EventCountdownWidget({
    super.key,
    required this.event,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(eventCountdownProvider(event));
    final onSurface = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    if (remaining.isNegative) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.greenAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'MANIFEST COMPLETE',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (days > 0) ...[
          _buildTimeUnit(context, days.toString(), 'D', onSurface),
          _buildDivider(onSurface),
        ],
        _buildTimeUnit(
          context,
          hours.toString().padLeft(2, '0'),
          'H',
          onSurface,
        ),
        _buildDivider(onSurface),
        _buildTimeUnit(
          context,
          minutes.toString().padLeft(2, '0'),
          'M',
          onSurface,
        ),
        _buildDivider(onSurface),
        _buildTimeUnit(
          context,
          seconds.toString().padLeft(2, '0'),
          'S',
          onSurface,
        ),
      ],
    );
  }

  Widget _buildTimeUnit(
    BuildContext context,
    String value,
    String unit,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 1),
        Text(
          unit,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: isDark
                ? Colors.white54
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 2,
        height: 2,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class CircularEventProgressIndicator extends ConsumerWidget {
  final Event event;
  final double size;
  final bool isDark;

  const CircularEventProgressIndicator({
    super.key,
    required this.event,
    this.size = 60,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(eventCountdownProvider(event));

    final totalDuration = (event.startTime ?? event.date)
        .difference(event.createdAt)
        .inSeconds;
    final remainingSeconds = remaining.inSeconds;

    double progress = 0;
    if (totalDuration > 0) {
      progress = (remainingSeconds / totalDuration).clamp(0.0, 1.0);
    }

    final isUrgent = remainingSeconds < 3600 && remainingSeconds > 0;
    final onSurface = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isUrgent)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1 - progress),
            duration: const Duration(seconds: 1),
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent
                    ? Colors.redAccent
                    : (isDark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary),
              ),
              strokeCap: StrokeCap.round,
            ),
          ),

          if (remainingSeconds > 0)
            Text(
              '${((1 - progress) * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: onSurface,
              ),
            )
          else
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.greenAccent,
              size: 28,
            ),
        ],
      ),
    );
  }
}
