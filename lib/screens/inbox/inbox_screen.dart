import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../providers/data_providers.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/brain_dump.dart';
import '../../widgets/buttons.dart';
import '../../widgets/grain_background.dart';
import '../../widgets/task_editor_sheet.dart';

/// Brain dump inbox: thoughts as loose notes in two columns. Turn one into a
/// task, or let it go.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final pad = MediaQuery.paddingOf(context);
    final dumps = ref.watch(brainDumpsProvider).value ?? const <BrainDump>[];
    final left = <BrainDump>[], right = <BrainDump>[];
    for (var i = 0; i < dumps.length; i++) {
      (i.isEven ? left : right).add(dumps[i]);
    }
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GrainBackground()),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, pad.top + 4, Space.gutter, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.text, size: 20),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      GhostButton(
                        label: 'Dump',
                        icon: Icons.add_rounded,
                        height: 40,
                        onTap: () => showBrainDump(context),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Space.gutter, Space.l, Space.gutter, Space.l),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INBOX · ${dumps.length}', style: T.label(c.textDim)),
                      const SizedBox(height: 6),
                      Text(dumps.isEmpty ? 'Clear head.' : 'Sort when you\'re ready.', style: T.h1(c.text)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, pad.bottom + 32),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(children: [for (final d in left) _Note(d)])),
                      const SizedBox(width: 10),
                      Expanded(child: Column(children: [for (final d in right) _Note(d)])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Note extends ConsumerWidget {
  const _Note(this.d);
  final BrainDump d;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final repo = ref.read(journalRepoProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: c.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.body, style: T.body(c.text)),
          const SizedBox(height: 8),
          Text(dayLabel(d.createdAt), style: T.mono(c.textDim, size: 10)),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  onPressed: () async {
                    final id = await showTaskEditor(context, title: d.body);
                    if (id != null) {
                      HapticFeedback.mediumImpact();
                      await repo.markSorted(d.id);
                    }
                  },
                  icon: Icon(Icons.arrow_forward_rounded, size: 16, color: c.accentInk),
                  label: Text('Make a task', style: T.small(c.accentInk)),
                ),
              ),
              IconButton(
                tooltip: 'Let it go',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded, size: 18, color: c.textDim),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  repo.deleteBrainDump(d.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
