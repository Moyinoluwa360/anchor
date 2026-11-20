import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Big lemon pill. The one primary action on a screen.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 60,
    this.trailing,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final double height;
  final String? trailing;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.trailing == null ? widget.label : '${widget.label}, ${widget.trailing}',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: enabled
            ? () {
                HapticFeedback.mediumImpact();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: context.motion(Motion.fast),
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.4,
            duration: context.motion(Motion.fast),
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(widget.height / 2),
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: c.isDark ? 0.25 : 0.4),
                    blurRadius: 24,
                    spreadRadius: -6,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  // On narrow screens (iPhone SE) drop the extras before the label.
                  final roomy = box.maxWidth > 190;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null && box.maxWidth > 120) ...[
                        Icon(widget.icon, color: c.onAccent, size: 22),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          style: T.button(c.onAccent).copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.trailing != null && roomy) ...[
                        const SizedBox(width: 10),
                        Text(widget.trailing!, style: T.mono(c.onAccent.withValues(alpha: 0.6), size: 14)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary button.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onTap, this.icon, this.height = 52});
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: c.border, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: c.text), const SizedBox(width: 8)],
              Text(label, style: T.bodyStrong(c.text)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round icon button for timer controls.
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 64,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? c.text : c.surface,
            border: Border.all(color: c.border, width: 0.8),
          ),
          child: Icon(icon, color: filled ? c.bg : c.text, size: size * 0.4),
        ),
      ),
    );
  }
}

/// Small selectable chip (areas, presets, minutes).
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.mono = false,
  });
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = selected ? c.onAccent : c.text;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: AnimatedContainer(
          duration: context.motion(Motion.fast),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? c.accent : c.surface2,
            borderRadius: BorderRadius.circular(Radii.chip),
            border: Border.all(color: selected ? c.accent : c.border, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
              Text(label, style: mono ? T.mono(fg, size: 13) : T.small(fg)),
            ],
          ),
        ),
      ),
    );
  }
}
