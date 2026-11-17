import 'package:flutter/material.dart';

/// Carte avec un graphe en courbe dessiné à la main (CustomPaint) :
/// aucune dépendance externe, la courbe s'adapte à la largeur disponible.
class MetricChartCard extends StatelessWidget {
  const MetricChartCard({
    super.key,
    required this.title,
    required this.values,
    required this.color,
  });

  final String title;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${values.last.round()} %',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(painter: _SparklinePainter(values, color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final grid = Paint()
      ..color = Colors.grey.withAlpha(60)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final dx = size.width / (values.length - 1);
    final line = Path();
    for (var i = 0; i < values.length; i++) {
      final v = values[i].clamp(0.0, 100.0).toDouble();
      final x = i * dx;
      final y = size.height - (v / 100) * size.height;
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withAlpha(40));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}
