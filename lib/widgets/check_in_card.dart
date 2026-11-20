import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/data_providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';

const energyFaces = ['🪫', '😴', '😐', '🙂', '⚡️'];
const energyWords = ['Empty', 'Low', 'Okay', 'Good', 'Charged'];
const moodFaces = ['😞', '😕', '😐', '🙂', '😄'];
const moodWords = ['Rough', 'Meh', 'Fine', 'Good', 'Great'];

/// The 10-second morning check-in: energy and mood, 1 to 5, big tappable faces.
/// Shown as the first card of the Now deck until done today.
class CheckInCard extends ConsumerStatefulWidget {
  const CheckInCard({super.key, this.onSaved, this.compact = false});
  final VoidCallback? onSaved;
  final bool compact;

  @override
  ConsumerState<CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends ConsumerState<CheckInCard> {
  int? _energy;
  int? _mood;
  final _note = TextEditingController();
  bool _showNote = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _note.text.trim();
    await ref
        .read(journalRepoProvider)
        .saveCheckIn(ref.read(todayProvider), _energy!, _mood!, note.isEmpty ? null : note);
    HapticFeedback.heavyImpact();
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.big),
        border: Border.all(color: c.accentInk.withValues(alpha: c.isDark ? 0.55 : 0.8), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MORNING CHECK-IN · 10 SEC', style: T.label(c.accentInk)),
          const SizedBox(height: Space.m),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How are you\narriving today?', style: T.display(c.text).copyWith(fontSize: 34)),
                  const SizedBox(height: Space.xl),
                  _Scale(
                    label: 'Energy',
                    faces: energyFaces,
                    words: energyWords,
                    value: _energy,
                    onPick: (v) => setState(() => _energy = v),
                  ),
                  const SizedBox(height: Space.l),
                  _Scale(
                    label: 'Mood',
                    faces: moodFaces,
                    words: moodWords,
                    value: _mood,
                    onPick: (v) => setState(() => _mood = v),
                  ),
                  if (_showNote) ...[
                    const SizedBox(height: Space.m),
                    TextField(
                      controller: _note,
                      style: T.body(c.text),
                      maxLines: 2,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Anything on your mind? (optional)'),
                    ),
                  ],
                  const SizedBox(height: Space.m),
                ],
              ),
            ),
          ),
          Row(
            children: [
              if (!_showNote)
                GestureDetector(
                  onTap: () => setState(() => _showNote = true),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text('+ note', style: T.mono(c.textDim, size: 13)),
                  ),
                ),
              Expanded(
                child: PrimaryButton(
                  label: 'Set my day',
                  height: 54,
                  onTap: _energy != null && _mood != null ? _save : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Scale extends StatelessWidget {
  const _Scale({
    required this.label,
    required this.faces,
    required this.words,
    required this.value,
    required this.onPick,
  });
  final String label;
  final List<String> faces;
  final List<String> words;
  final int? value;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label.toUpperCase(), style: T.label(c.textDim)),
            const Spacer(),
            if (value != null) Text(words[value! - 1].toUpperCase(), style: T.label(c.accentInk)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 1; i <= 5; i++) ...[
              if (i > 1) const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  button: true,
                  selected: value == i,
                  label: '$label ${words[i - 1]}, $i of 5',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onPick(i);
                    },
                    child: AnimatedContainer(
                      duration: context.motion(Motion.fast),
                      height: 54,
                      decoration: BoxDecoration(
                        color: value == i ? c.accent : c.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: value == i ? c.accent : c.border, width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedScale(
                        scale: value == i ? 1.18 : 1,
                        duration: context.motion(Motion.fast),
                        curve: Curves.easeOutBack,
                        child: Text(faces[i - 1], style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
