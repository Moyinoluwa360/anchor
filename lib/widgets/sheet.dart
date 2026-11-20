import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Opens a rounded bottom sheet that grows with the keyboard.
Future<R?> showAnchorSheet<R>(BuildContext context, {required WidgetBuilder builder, bool full = false}) {
  return showModalBottomSheet<R>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: context.reduceMotion
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 320),
            reverseDuration: Duration(milliseconds: 220),
          ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: full
          ? SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.92, child: builder(ctx))
          : builder(ctx),
    ),
  );
}

/// Standard sheet body: title, optional subtitle, content, comfortable padding.
class SheetBody extends StatelessWidget {
  const SheetBody({super.key, required this.title, this.subtitle, required this.children});
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: T.h2(c.text)),
          if (subtitle != null) ...[const SizedBox(height: 6), Text(subtitle!, style: T.body(c.textDim))],
          const SizedBox(height: Space.l),
          ...children,
        ],
      ),
    );
  }
}

/// Small mono section label inside sheets and cards.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 14),
    child: Text(text.toUpperCase(), style: T.label(context.c.textDim)),
  );
}
