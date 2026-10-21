import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/model/thought_monitoring/thought_monitoring_chart_model.dart';

/// One layer of the stacked area chart.
/// `values` are the layer's own amounts (NOT cumulative) for each x point.
class StackedAreaSeries {
  const StackedAreaSeries({
    required this.label,
    required this.color,
    required this.values,
    Color? legendColor,
  }) : legendColor = legendColor ?? color;

  final String label;
  final Color color;
  final Color legendColor; // design uses a darker grey dot for "Skipped"
  final List<double> values;
}

/// The full card: title + chart + legend.
class ThoughtMonitoringCard extends StatelessWidget {
  const ThoughtMonitoringCard({super.key, required this.series, this.legend});

  /// Stack order: first item is drawn at the bottom.
  final List<StackedAreaSeries> series;

  /// Optional legend order (defaults to top-to-bottom of the stack).
  final List<StackedAreaSeries>? legend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Thought Monitoring',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 0.95,
            child: StackedAreaChart(series: series),
          ),
          const SizedBox(height: 16),
          _Legend(items: legend ?? series.reversed.toList()),
        ],
      ),
    );
  }
}

/// Reusable stacked area chart with arrow axes and % labels.
class StackedAreaChart extends StatelessWidget {
  const StackedAreaChart({
    super.key,
    required this.series,
    this.maxY = 100,
    this.yStep = 10,
    this.duration = const Duration(milliseconds: 900),
  });

  final List<StackedAreaSeries> series;
  final double maxY;
  final double yStep;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => CustomPaint(
        size: Size.infinite,
        painter: _StackedAreaPainter(
          series: series,
          maxY: maxY,
          yStep: yStep,
          progress: t,
        ),
      ),
    );
  }
}

class _StackedAreaPainter extends CustomPainter {
  _StackedAreaPainter({
    required this.series,
    required this.maxY,
    required this.yStep,
    required this.progress,
  });

  final List<StackedAreaSeries> series;
  final double maxY;
  final double yStep;
  final double progress;

  static const _labelStyle = TextStyle(fontSize: 12, color: Color(0xFF9E9E9E));

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || series.first.values.isEmpty) return;

    // ---- Layout ----
    const labelWidth = 40.0;
    const arrowSpace = 24.0;
    final origin = Offset(labelWidth + 8, size.height - 8);
    const yAxisTop = 0.0;
    final xAxisEnd = size.width;

    final plotTop = arrowSpace + 8;
    final plotLeft = origin.dx + 6;
    final plotRight = xAxisEnd - 15;
    final plotBottom = origin.dy - 8;
    final plotHeight = plotBottom - plotTop;

    double yFor(double v) => plotBottom - (v / maxY) * plotHeight;

    // ---- Y-axis labels (0% … 100%) ----
    for (double v = 0; v <= maxY; v += yStep) {
      final tp = TextPainter(
        text: TextSpan(text: '${v.toInt()}%', style: _labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(labelWidth - tp.width, yFor(v) - tp.height / 2));
    }

    // ---- Stacked areas ----
    final pointCount = series.first.values.length;
    final dx = pointCount > 1 ? (plotRight - plotLeft) / (pointCount - 1) : 0.0;
    double xFor(int i) => plotLeft + i * dx;

    var lower = List<double>.filled(pointCount, 0);
    for (final s in series) {
      assert(s.values.length == pointCount, 'All series need the same length');
      final upper = List<double>.generate(
        pointCount,
        (i) => lower[i] + s.values[i] * progress,
      );

      // Polygon: along the top edge left→right, back along the bottom edge.
      final path = Path()..moveTo(xFor(0), yFor(upper[0]));
      for (var i = 1; i < pointCount; i++) {
        path.lineTo(xFor(i), yFor(upper[i]));
      }
      for (var i = pointCount - 1; i >= 0; i--) {
        path.lineTo(xFor(i), yFor(lower[i]));
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.fill,
      );
      lower = upper;
    }

    // ---- Axes with arrow heads ----
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(origin, Offset(origin.dx, yAxisTop + 1), axisPaint);
    canvas.drawLine(origin, Offset(xAxisEnd - 1, origin.dy), axisPaint);

    const head = 10.0;
    canvas.drawPath(
      Path()
        ..moveTo(origin.dx - head, yAxisTop + head + 1)
        ..lineTo(origin.dx, yAxisTop + 1)
        ..lineTo(origin.dx + head, yAxisTop + head + 1),
      axisPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(xAxisEnd - head - 1, origin.dy - head)
        ..lineTo(xAxisEnd - 1, origin.dy)
        ..lineTo(xAxisEnd - head - 1, origin.dy + head),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StackedAreaPainter old) =>
      old.progress != progress ||
      old.series != series ||
      old.maxY != maxY ||
      old.yStep != yStep;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});
  final List<StackedAreaSeries> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: items[i].legendColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    items[i].label,
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ThoughtMonitoring extends StatelessWidget {
  const ThoughtMonitoring({
    super.key,
    required this.chart,
    this.padding = EdgeInsets.zero,
  });

  final ThoughtMonitoringChart? chart;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final positive = chart?.positive ?? const <double>[];
    final negative = chart?.negative ?? const <double>[];
    final neutral = chart?.neutral ?? const <double>[];
    final skipped = chart?.skipped ?? const <double>[];

    final length = positive.length;
    final hasData =
        length > 0 &&
        negative.length == length &&
        neutral.length == length &&
        skipped.length == length;
    if (!hasData) return const SizedBox.shrink();

    // The chart needs at least two points, so a single value becomes a flat band.
    List<double> points(List<double> values) =>
        length == 1 ? [values.first, values.first] : values;

    final neutralSeries = StackedAreaSeries(
      label: 'Neutral',
      color: const Color(0xFF93C4C4),
      values: points(neutral),
    );
    final skippedSeries = StackedAreaSeries(
      label: 'Skipped',
      color: const Color(0xFFD0D0D0),
      legendColor: const Color(0xFF8E8E8E),
      values: points(skipped),
    );
    final negativeSeries = StackedAreaSeries(
      label: 'Negative',
      color: const Color(0xFF1E2C55),
      values: points(negative),
    );
    final positiveSeries = StackedAreaSeries(
      label: 'Positive',
      color: const Color(0xFFE16E57),
      values: points(positive),
    );

    return Padding(
      padding: padding,
      child: ThoughtMonitoringCard(
        // bottom → top
        series: [neutralSeries, skippedSeries, negativeSeries, positiveSeries],
        // legend order as in the design
        legend: [positiveSeries, negativeSeries, neutralSeries, skippedSeries],
      ),
    );
  }
}
