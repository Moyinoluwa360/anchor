import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/screen_header.dart';

/// Stage 1 placeholder; replaced by the real screen in its stage.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    return CustomScrollView(slivers: [
      const SliverToBoxAdapter(child: ScreenHeader(title: 'Week')),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(Space.gutter, Space.xl, Space.gutter, GlassBottomBar.reserved(context)),
        sliver: SliverToBoxAdapter(child: Text('The bento board lands in Stage 6.', style: T.body(c.textDim))),
      ),
    ]);
  }
}
