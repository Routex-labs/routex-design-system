import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 매장 분류의 고유색과 아이콘을 목록을 복사하지 않고 catalog에서 순회한다.
class CategoryCatalog extends StatelessWidget {
  const CategoryCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexCluster(
      gap: RoutexClusterGap.content,
      children: [
        for (final category in RoutexCategoryTokens.categories)
          SizedBox(
            width: 148,
            child: RoutexSurface(
              role: RoutexSurfaceRole.outlined,
              child: Padding(
                padding: const EdgeInsetsDirectional.all(
                  RoutexSpacing.contentGap,
                ),
                child: Row(
                  children: [
                    Container(
                      width: RoutexMetrics.compactControl,
                      height: RoutexMetrics.compactControl,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: RoutexCategoryTokens.colorFor(category),
                        borderRadius: RoutexRadii.control,
                      ),
                      child: Icon(
                        RoutexCategoryTokens.iconFor(category),
                        size: RoutexMetrics.iconMedium,
                        color: colors.contentInverse,
                      ),
                    ),
                    const SizedBox(width: RoutexSpacing.contentGap),
                    Expanded(
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RoutexTypography.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
