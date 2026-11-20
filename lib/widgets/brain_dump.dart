import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../providers/data_providers.dart';
import '../providers/ui_providers.dart';
import '../router.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'glass.dart';
import 'glass_bottom_bar.dart';
import 'sheet.dart';

final brainDumpsProvider = StreamProvider<List<BrainDump>>(
  (ref) => ref.watch(journalRepoProvider).watchBrainDumps(),
);

/// Small glass button above the bar, on every main screen: tap to dump a
/// thought, hold to open the inbox. Shows how many are waiting.
class CaptureButton extends ConsumerWidget {
  const CaptureButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final visible = ref.watch(chromeVisibleProvider);
    final waiting = ref.watch(brainDumpsProvider).value?.length ?? 0;
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(1.4, 0),
      duration: context.motion(Motion.med),
      curve: Motion.curve,
      child: Semantics(
        button: true,
        label: 'Brain dump. $waiting waiting in the inbox. Hold to open the inbox.',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            showBrainDump(context);
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            context.push(Routes.inbox);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Glass(
                radius: 25,
                blur: 16,
                child: SizedBox.square(
                  dimension: 50,
                  child: Icon(Icons.edit_note_rounded, color: c.text, size: 24),
                ),
              ),
              if (waiting > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(9)),
                    alignment: Alignment.center,
                    child: Text('$waiting', style: T.mono(c.onAccent, size: 10, w: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom offset that keeps it just above the glass bar.
  static double bottom(BuildContext context) => GlassBottomBar.bottomGap(context) + kBarHeight + 12;
}

/// Quick capture: type, hit return, gone. Sorting happens later.
Future<void> showBrainDump(BuildContext context) =>
    showAnchorSheet<void>(context, builder: (_) => const _BrainDumpSheet());

class _BrainDumpSheet extends ConsumerStatefulWidget {
  const _BrainDumpSheet();

  @override
  ConsumerState<_BrainDumpSheet> createState() => _BrainDumpSheetState();
}

class _BrainDumpSheetState extends ConsumerState<_BrainDumpSheet> {
  final _ctl = TextEditingController();
  int _saved = 0;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _save({bool close = false}) async {
    final t = _ctl.text.trim();
    final nav = Navigator.of(context);
    if (t.isNotEmpty) {
      await ref.read(journalRepoProvider).addBrainDump(t);
      HapticFeedback.lightImpact();
      _ctl.clear();
      setState(() => _saved++);
    }
    if (close) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SheetBody(
      title: 'Brain dump',
      subtitle: _saved == 0 ? 'Get it out of your head. Sort it later.' : '$_saved saved. Anything else?',
      children: [
        TextField(
          controller: _ctl,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          style: T.body(c.text).copyWith(fontSize: 17),
          decoration: const InputDecoration(hintText: 'A thought, a task, a worry…'),
          onSubmitted: (_) => _save(),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: Space.l),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(label: 'Dump it', height: 52, onTap: () => _save(close: true)),
            ),
            const SizedBox(width: 8),
            GhostButton(
              label: 'Inbox',
              height: 52,
              onTap: () {
                Navigator.pop(context);
                context.push(Routes.inbox);
              },
            ),
          ],
        ),
      ],
    );
  }
}
