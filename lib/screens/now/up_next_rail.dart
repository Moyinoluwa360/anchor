import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/glass.dart';

/// Slim "Up next" rail that peeks in from the right edge with the next two
/// blocks. Tap to slide it fully in; tap again to tuck it away.
class UpNextRail extends StatefulWidget {
  const UpNextRail({super.key, required this.blocks, required this.now});
  final List<TimeBlock> blocks;
  final DateTime now;

  static List<TimeBlock> nextTwo(List<TimeBlock> blocks, DateTime now) =>
      blocks.where((b) => b.startAt.isAfter(now)).take(2).toList();

  @override
  State<UpNextRail> createState() => _UpNextRailState();
}

class _UpNextRailState extends State<UpNextRail> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final next = UpNextRail.nextTwo(widget.blocks, widget.now);
    if (next.isEmpty) return const SizedBox.shrink();
    const full = 196.0;
    const peek = 58.0;
    return AnimatedContainer(
      duration: context.motion(Motion.med),
      curve: Curves.easeOutBack,
      width: full,
      transform: Matrix4.translationValues(_open ? 0 : full - peek, 0, 0),
      child: Semantics(
        button: true,
        label:
            'Up next: ${next.map((b) => '${hhmm(b.startAt)} ${b.label.isEmpty ? b.type.label : b.label}').join(', ')}',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _open = !_open);
          },
          child: Glass(
            radius: 20,
            padding: const EdgeInsets.fromLTRB(12, 10, 26, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEXT', style: T.label(c.textDim).copyWith(fontSize: 9)),
                const SizedBox(height: 4),
                for (final b in next)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(hhmm(b.startAt), style: T.mono(c.text, size: 12, w: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Icon(
                          b.type.icon,
                          size: 12,
                          color: b.type == BlockType.focus ? c.accentInk : c.textDim,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            b.label.isEmpty ? b.type.label : b.label,
                            style: T.small(c.textDim),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
