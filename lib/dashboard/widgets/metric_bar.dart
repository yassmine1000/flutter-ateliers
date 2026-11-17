import 'package:flutter/material.dart';

/// Ligne « LABEL ▓▓▓░░ 62 % » : le libellé et la valeur ont une largeur
/// fixe, la barre prend tout le reste (Expanded) quelle que soit la largeur.
class MetricBar extends StatelessWidget {
  const MetricBar({super.key, required this.label, required this.value});

  final String label;
  final double value; // 0..100

  @override
  Widget build(BuildContext context) {
    final color = value > 85
        ? Colors.red.shade600
        : value > 65
            ? Colors.orange.shade700
            : Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              color: color,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text('${value.round()} %', textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
