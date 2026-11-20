import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/screen_header.dart';

/// Stage 1 placeholder; replaced by the 24-hour dial in Stage 4.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenHeader(
            title: 'Today',
            actions: [
              HeaderButton(
                icon: Icons.notifications_none_rounded,
                label: 'Reminders',
                onTap: () => context.push(Routes.reminders),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            Space.gutter,
            Space.xl,
            Space.gutter,
            GlassBottomBar.reserved(context),
          ),
          sliver: SliverToBoxAdapter(
            child: Text('Your day as a dial: coming in Stage 4.', style: T.body(c.textDim)),
          ),
        ),
      ],
    );
  }
}
