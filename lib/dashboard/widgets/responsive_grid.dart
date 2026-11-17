import 'package:flutter/material.dart';

/// Grille à nombre de colonnes imposé : chaque enfant reçoit exactement
/// (largeur disponible - espaces) / colonnes. Wrap gère le retour à la ligne.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.children,
    this.spacing = 12,
  });

  final int columns;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                .floorToDouble();
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
