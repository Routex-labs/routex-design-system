import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// Showcase의 모든 섹션이 같은 좌우 경계와 제목·설명 위계를 쓰도록 고정한다.
class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({
    required this.title,
    required this.description,
    required this.child,
    super.key,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    // 섹션마다 칠하는 층을 따로 둔다. 섹션이 독립된 층이라야 골든을 섹션 단위로
    // 찍을 수 있다. 층이 없으면 어느 섹션을 지목해도 페이지 전체가 찍혀, 한 섹션만
    // 고쳐도 관계없는 골든까지 전부 다시 승인해야 한다.
    return RepaintBoundary(
      key: ValueKey('showcase-section-$title'),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsetsDirectional.only(
            top: RoutexSpacing.sectionGap,
            bottom: RoutexSpacing.sectionGap,
          ),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.borderSubtle)),
          ),
          child: RoutexStack(
            gap: RoutexStackGap.section,
            children: [
              RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  Text(title, style: RoutexTypography.headline),
                  Text(
                    description,
                    style: RoutexTypography.body.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
