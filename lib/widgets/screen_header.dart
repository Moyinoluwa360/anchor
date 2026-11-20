import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Top of every main screen. The top-left corner is left empty on purpose:
/// it belongs to the floating streak bubble. Actions sit top-right; the big
/// title sits below.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.kicker, this.actions = const []});

  final String title;

  /// Small mono line above the title, e.g. "THU 20 NOV".
  final String? kicker;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.gutter, MediaQuery.paddingOf(context).top + 4, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 44, child: Row(children: [const Spacer(), ...actions])),
          const SizedBox(height: 6),
          if (kicker != null) ...[
            Text(kicker!.toUpperCase(), style: T.label(c.textDim)),
            const SizedBox(height: 6),
          ],
          Semantics(header: true, child: Text(title, style: T.h1(c.text))),
        ],
      ),
    );
  }
}

/// Round icon button used in headers.
class HeaderButton extends StatelessWidget {
  const HeaderButton({super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.surface,
            border: Border.all(color: c.border, width: 0.8),
          ),
          child: Icon(icon, size: 19, color: c.text),
        ),
      ),
    );
  }
}
