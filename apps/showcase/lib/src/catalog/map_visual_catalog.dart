import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import 'catalog_tiles.dart';

/// 지도 renderer가 소비하는 색 역할을 package catalog에서 그대로 보여준다.
class MapVisualCatalog extends StatelessWidget {
  const MapVisualCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutexCluster(
      gap: RoutexClusterGap.content,
      children: [
        for (final role in RoutexMapVisualRole.values)
          _MapVisualTile(role: role, color: role.resolve()),
      ],
    );
  }
}

class _MapVisualTile extends StatelessWidget {
  const _MapVisualTile({required this.role, required this.color});

  final RoutexMapVisualRole role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return SizedBox(
      width: catalogTileWidth,
      child: RoutexStack(
        gap: RoutexStackGap.inline,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: RoutexRadii.control,
              border: Border.all(color: colors.borderSubtle),
            ),
            child: const SizedBox(width: catalogTileWidth, height: 56),
          ),
          Text(role.name, style: RoutexTypography.label),
        ],
      ),
    );
  }
}
