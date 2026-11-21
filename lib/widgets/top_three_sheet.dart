import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/dates.dart';
import '../providers/data_providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'sheet.dart';

/// Pick up to three must-do tasks for today, in order.
Future<void> showTopThreeSheet(BuildContext context) =>
    showExeSheet<void>(context, builder: (_) => const _TopThree());

class _TopThree extends ConsumerStatefulWidget {
  const _TopThree();

  @override
  ConsumerState<_TopThree> createState() => _TopThreeState();
}

class _TopThreeState extends ConsumerState<_TopThree> {
  List<int>? _picked;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final open = ref.watch(openTodayProvider).value ?? const <Task>[];
    _picked ??= ([
      ...open.where((t) => t.topRank != null),
    ]..sort((a, b) => a.topRank!.compareTo(b.topRank!))).map((t) => t.id).toList();
    final picked = _picked!;

    return SheetBody(
      title: 'Today\'s top 3',
      subtitle: 'If only these happen, today was a good day.',
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: context.motion(Motion.fast),
                  height: 86,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: i < picked.length ? c.accent : c.surface2,
                    borderRadius: BorderRadius.circular(Radii.chip),
                    border: Border.all(color: i < picked.length ? c.accent : c.border, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}', style: T.number(i < picked.length ? c.onAccent : c.textDim, size: 22)),
                      const Spacer(),
                      Text(
                        i < picked.length
                            ? open.firstWhere((t) => t.id == picked[i], orElse: () => open.first).title
                            : 'Pick one',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: T.small(i < picked.length ? c.onAccent : c.textDim).copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const FieldLabel('Tap in order of importance'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in open)
              Pill(
                label: t.title.length > 32 ? '${t.title.substring(0, 31)}…' : t.title,
                icon: t.area.icon,
                selected: picked.contains(t.id),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (picked.contains(t.id)) {
                      picked.remove(t.id);
                    } else if (picked.length < 3) {
                      picked.add(t.id);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: Space.xl),
        PrimaryButton(
          label: picked.isEmpty ? 'Clear top 3' : 'Set top ${picked.length}',
          onTap: () async {
            final nav = Navigator.of(context);
            await ref.read(taskRepoProvider).setTopThree(today(), picked);
            nav.pop();
          },
        ),
      ],
    );
  }
}
