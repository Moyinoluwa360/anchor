import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers/data_providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'sheet.dart';

const distractionChips = ['Phone', 'Messages', 'Noise', 'Hunger', 'Worry', 'Tired', 'Nothing'];

/// Focus guard: a gentle stop at the end of a focus block, and an optional
/// note on what pulled attention away (saved with the session).
Future<void> showFocusGuard(BuildContext context, {int? sessionId, required int breakMinutes}) =>
    showAnchorSheet<void>(
      context,
      builder: (_) => _FocusGuard(sessionId: sessionId, breakMinutes: breakMinutes),
    );

class _FocusGuard extends ConsumerStatefulWidget {
  const _FocusGuard({this.sessionId, required this.breakMinutes});
  final int? sessionId;
  final int breakMinutes;

  @override
  ConsumerState<_FocusGuard> createState() => _FocusGuardState();
}

class _FocusGuardState extends ConsumerState<_FocusGuard> {
  final Set<String> _picked = {};
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SheetBody(
      title: 'Block done. Hard stop.',
      subtitle: widget.breakMinutes > 0
          ? 'Stand up, drink water, look at something far away for ${widget.breakMinutes} minutes.'
          : 'Nice start. Keep going, or call it there. Both count.',
      children: [
        Text('ANYTHING PULL YOU AWAY? (OPTIONAL)', style: T.label(c.textDim)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in distractionChips)
              Pill(
                label: d,
                selected: _picked.contains(d),
                onTap: () => setState(() => _picked.contains(d) ? _picked.remove(d) : _picked.add(d)),
              ),
          ],
        ),
        const SizedBox(height: Space.m),
        TextField(
          controller: _note,
          style: T.body(c.text),
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'A word about it (optional)'),
        ),
        const SizedBox(height: Space.l),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Save and rest',
                height: 52,
                onTap: () async {
                  final nav = Navigator.of(context);
                  final parts = [..._picked, if (_note.text.trim().isNotEmpty) _note.text.trim()];
                  if (widget.sessionId != null && parts.isNotEmpty) {
                    await ref
                        .read(journalRepoProvider)
                        .patchSession(
                          widget.sessionId!,
                          FocusSessionsCompanion(distractions: Value(parts.join(', '))),
                        );
                  }
                  nav.pop();
                },
              ),
            ),
            const SizedBox(width: 8),
            GhostButton(label: 'Skip', height: 52, onTap: () => Navigator.pop(context)),
          ],
        ),
      ],
    );
  }
}
