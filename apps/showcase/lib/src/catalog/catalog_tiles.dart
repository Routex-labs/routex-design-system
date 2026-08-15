import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// catalog가 역할 하나를 보여줄 때 쓰는 공통 타일 폭이다.
const double catalogTileWidth = 144;

class ColorTile extends StatelessWidget {
  const ColorTile({required this.role, required this.color, super.key});

  final RoutexColorRole role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: catalogTileWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: RoutexRadii.control,
              border: Border.all(color: context.routexColors.borderSubtle),
            ),
            child: const SizedBox(width: catalogTileWidth, height: 64),
          ),
          const SizedBox(height: RoutexSpacing.controlGap),
          Text(role.name, style: RoutexTypography.label),
        ],
      ),
    );
  }
}

class ValueTile extends StatelessWidget {
  const ValueTile({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: catalogTileWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.routexColors.surfaceCanvas,
          borderRadius: RoutexRadii.control,
        ),
        child: Padding(
          padding: const EdgeInsets.all(RoutexSpacing.contentGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: RoutexTypography.label),
              const SizedBox(height: RoutexSpacing.inlineGap),
              Text(
                value,
                style: RoutexTypography.tabular(RoutexTypography.bodyStrong),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RadiusTile extends StatelessWidget {
  const RadiusTile({required this.role, super.key});

  final RoutexRadiusRole role;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: catalogTileWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.routexColors.actionPrimarySubtle,
          borderRadius: role.borderRadius,
          border: Border.all(color: context.routexColors.actionPrimary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(RoutexSpacing.contentGap),
          child: Text(role.name, style: RoutexTypography.label),
        ),
      ),
    );
  }
}

class LayerTile extends StatelessWidget {
  const LayerTile({required this.role, required this.colors, super.key});

  final RoutexLayerRole role;
  final RoutexColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: catalogTileWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: RoutexRadii.control,
          border: Border.all(color: colors.borderSubtle),
          boxShadow: RoutexLayer.shadow(role, colors),
        ),
        child: Padding(
          padding: const EdgeInsets.all(RoutexSpacing.contentGap),
          child: Text(
            '${role.name} · ${role.elevation.toInt()}',
            style: RoutexTypography.label,
          ),
        ),
      ),
    );
  }
}
