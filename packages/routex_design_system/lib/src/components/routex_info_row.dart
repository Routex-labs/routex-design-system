import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_toast.dart';

/// 아이콘 + 값 한 줄. 상세 화면에서 사실 하나를 적는 가장 작은 단위다.
///
/// **라벨을 값 위 캡션으로 올리지 않는다.** 그렇게 두면 한 항목이 두 줄을 쓰고,
/// 항목이 여섯 개면 열두 줄이라 시트가 글 덩어리로 읽힌다. 아이콘은 가로 한 칸만
/// 쓰고 값이 본문 폭을 그대로 받으므로 같은 내용이 절반 높이에 들어간다.
///
/// **아이콘이 없으면 라벨을 글자로 남긴다.** 아이콘이 라벨을 대신할 수 있는 것은
/// 그 아이콘이 라벨을 정확히 가리킬 때뿐이다. 어떤 라벨에 어떤 글리프가 맞는지는
/// 데이터를 아는 소비 앱이 정하고, 모르는 라벨에 아무 아이콘이나 붙이지 않는다 —
/// 그 순간 값이 무슨 뜻인지가 화면에서 사라진다.
///
/// 여러 줄을 세울 때는 줄 사이에 선을 긋지 않는다. 섹션 경계는 이미
/// `RoutexDivider`가 긋고 있어서 행마다 그으면 목록이 표가 된다.
class RoutexInfoRow extends StatelessWidget {
  const RoutexInfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.keepLabel = false,
    this.caption,
    this.copyText,
    this.onCopied,
    super.key,
  });

  /// 값의 뜻이다. 아이콘이 이 뜻을 정확히 가리키면 글자는 그려지지 않는다.
  final String label;

  final String value;

  /// 라벨을 대신하는 글리프다. null이면 라벨을 글자로 남긴다.
  final IconData? icon;

  /// 아이콘이 있어도 라벨 글자를 남긴다.
  ///
  /// 라벨 자체가 **값의 뜻을 바꾸는** 줄에서 쓴다. `고객센터 1522-3232`에서
  /// `고객센터`를 지우면 남는 것은 매장 직통 번호처럼 읽히고, 그건 정보가 줄어든
  /// 것이 아니라 틀린 정보가 된 것이다.
  final bool keepLabel;

  /// 값 아래 작은 글씨(확인일 등)다.
  final String? caption;

  /// 값 옆 복사 버튼이 클립보드에 담을 문자열이다. null이면 버튼이 없다.
  ///
  /// 값 전체가 아니라 **복사할 만한 토막**만 받는다. `1522-3232 (평일 09:00–18:00)`을
  /// 통째로 복사하면 전화 앱에 붙여 넣을 수 없다.
  final String? copyText;

  /// 복사에 성공했을 때 부른다. 주면 **성공 알림 자리를 소비 앱이 가져간다.**
  ///
  /// 기본은 이 컴포넌트가 `복사했습니다`를 띄우는 것이다. 그런데 어떤 플랫폼은
  /// 시스템이 복사 확인을 스스로 띄워서, 그 위에 하나 더 얹으면 같은 말이 두 번
  /// 뜬다. 기기 버전을 조회해야 아는 사실이라 이 패키지는 판정할 수 없다.
  ///
  /// 실패는 이 값과 무관하게 늘 이 컴포넌트가 알린다 — 시스템 확인은 성공에만 뜬다.
  final VoidCallback? onCopied;

  bool get _showLabel => icon == null || keepLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Semantics(
      container: true,
      label: '$label, $value',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            // 아이콘이 없는 줄도 같은 폭을 비운다. 아이콘 유무로 값의 시작선이
            // 달라지면 같은 섹션 안에서 줄마다 왼쪽이 어긋난다.
            width: RoutexMetrics.iconLarge,
            child: icon == null
                ? null
                : Padding(
                    // 아이콘 윗면을 첫 줄 글자 윗면에 맞춘다. line box는 글자보다
                    // 위아래로 여유가 있어 그냥 두면 아이콘이 떠 보인다.
                    padding: const EdgeInsetsDirectional.only(
                      top: RoutexOpticalCorrection.infoRowIconTop,
                    ),
                    child: Icon(
                      icon,
                      size: RoutexMetrics.iconMedium,
                      color: colors.contentSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: RoutexSpacing.contentGap),
          Expanded(
            child: RoutexStack(
              gap: RoutexStackGap.inline,
              children: [
                if (_showLabel)
                  Text(
                    label,
                    style: RoutexTypography.caption.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        // 주소·안내 문구는 어절이 줄 끝에서 쪼개지면 읽는 눈이
                        // 다음 줄 첫 글자를 다시 찾아야 한다.
                        RoutexTypography.keepWordsWhole(value),
                        style: RoutexTypography.body,
                      ),
                    ),
                    // 복사 버튼은 값 **바로 옆**이다. 줄 오른쪽 끝에 붙이면 값이
                    // 짧을 때 무엇을 복사하는 버튼인지가 멀어진다.
                    if (copyText case final copyText?)
                      _CopyAction(
                        text: copyText,
                        label: label,
                        onCopied: onCopied,
                      ),
                  ],
                ),
                if (caption?.trim().isNotEmpty ?? false)
                  Text(
                    caption!,
                    style: RoutexTypography.caption.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 값 옆에 붙는 복사 버튼.
///
/// **아이콘이 아니라 글자다.** 전화번호 옆의 겹친 사각형 글리프는 "저장"·"공유"로도
/// 읽힌다. 잘못 눌러도 잃는 것이 없는 동작에 아이콘 수수께끼를 낼 이유가 없다.
class _CopyAction extends StatelessWidget {
  const _CopyAction({
    required this.text,
    required this.label,
    required this.onCopied,
  });

  final String text;
  final String label;
  final VoidCallback? onCopied;

  /// 클립보드는 실패할 수 있다. 웹은 브라우저 권한을, 리눅스는 클립보드 매니저를
  /// 타고, 둘 다 없으면 플랫폼 채널이 예외를 던진다. 조용히 삼키면 사용자는 복사된
  /// 줄 알고 붙여 넣기를 시도하므로 실패를 실패라고 말한다.
  Future<void> _copy(BuildContext context) async {
    var copied = true;
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (_) {
      copied = false;
    }
    if (copied && onCopied != null) return onCopied!();
    if (!context.mounted) return;
    RoutexToast.show(context, copied ? '복사했습니다' : '복사하지 못했습니다');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Semantics(
      button: true,
      focusable: true,
      label: '$label 복사',
      onTap: () => _copy(context),
      excludeSemantics: true,
      child: TextButton(
        onPressed: () => _copy(context),
        style: ButtonStyle(
          // 글자는 짧아도 누르는 자리는 48을 지킨다. 좌우 패딩으로 만들면 그만큼
          // 글자가 값에서 멀어지므로 상자만 키운다.
          minimumSize: const WidgetStatePropertyAll(
            Size.square(RoutexMetrics.minimumTouchTarget),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: RoutexRadii.control),
          ),
          textStyle: const WidgetStatePropertyAll(RoutexTypography.label),
          foregroundColor: WidgetStatePropertyAll(colors.actionPrimary),
        ),
        child: const Text('복사'),
      ),
    );
  }
}
