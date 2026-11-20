import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ui_providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'glass.dart';

class BarItem {
  const BarItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

const barItems = [
  BarItem('Now', Icons.adjust_rounded),
  BarItem('Today', Icons.donut_large_rounded),
  BarItem('Week', Icons.space_dashboard_rounded),
  BarItem('Goals', Icons.hub_rounded),
  BarItem('Done', Icons.done_all_rounded),
];

/// Height of the bar; screens pad their content by [GlassBottomBar.reserved].
const kBarHeight = 62.0;

/// Liquid glass capsule tab bar. Sits low (WhatsApp-like spacing), slim, with
/// a smaller glass bubble that springs between tabs and stretches in the
/// direction of travel like a drop of liquid.
class GlassBottomBar extends ConsumerStatefulWidget {
  const GlassBottomBar({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  /// Gap between the bar and the bottom of the screen.
  static double bottomGap(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    // Home indicator sits in the bottom ~13 pt of the inset; leave ~10 pt above it.
    return inset > 0 ? (inset - 12).clamp(10, 40).toDouble() : 12;
  }

  /// Space screens should leave at the bottom so content clears the bar.
  static double reserved(BuildContext context) => bottomGap(context) + kBarHeight + 16;

  @override
  ConsumerState<GlassBottomBar> createState() => _GlassBottomBarState();
}

class _GlassBottomBarState extends ConsumerState<GlassBottomBar> with SingleTickerProviderStateMixin {
  late final AnimationController _pos = AnimationController.unbounded(
    vsync: this,
    value: widget.index.toDouble(),
  );

  static const _spring = SpringDescription(mass: 1, stiffness: 380, damping: 26);

  @override
  void didUpdateWidget(GlassBottomBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _springTo(widget.index);
  }

  void _springTo(int i) {
    if (context.reduceMotion) {
      _pos.value = i.toDouble();
      return;
    }
    _pos.animateWith(SpringSimulation(_spring, _pos.value, i.toDouble(), _pos.velocity));
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final visible = ref.watch(chromeVisibleProvider);
    final d = context.motion(Motion.med);
    final activeColor = c.isDark ? c.accent : c.accentInk;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, GlassBottomBar.bottomGap(context)),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.25),
        duration: d,
        curve: Motion.curve,
        child: AnimatedScale(
          scale: visible ? 1 : 0.9,
          duration: d,
          curve: Motion.curve,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0.6,
            duration: d,
            child: SizedBox(
              height: kBarHeight,
              child: Glass(
                radius: kBarHeight / 2,
                child: LayoutBuilder(
                  builder: (context, box) {
                    const inset = 5.0;
                    final slotW = (box.maxWidth - inset * 2) / barItems.length;
                    return Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _pos,
                          builder: (context, _) {
                            final v = _pos.velocity;
                            final stretch = (v.abs() * 0.045).clamp(0.0, 0.38);
                            final w = (slotW - 4) * (1 + stretch);
                            final h = (kBarHeight - inset * 2) * (1 - stretch * 0.22);
                            final lead = v.sign * stretch * slotW * 0.18;
                            final left = inset + _pos.value * slotW + (slotW - w) / 2 + lead;
                            return Positioned(
                              left: left,
                              top: (kBarHeight - h) / 2,
                              width: w,
                              height: h,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(h / 2),
                                  color: c.isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.06),
                                  border: Border.all(color: c.glassBorder, width: 0.6),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: c.isDark ? 0.14 : 0.5),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Row(
                          children: [
                            const SizedBox(width: inset),
                            for (var i = 0; i < barItems.length; i++)
                              SizedBox(
                                width: slotW,
                                height: kBarHeight,
                                child: _Slot(
                                  item: barItems[i],
                                  active: i == widget.index,
                                  activeColor: activeColor,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    widget.onTap(i);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.item, required this.active, required this.activeColor, required this.onTap});

  final BarItem item;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final d = context.motion(Motion.med);
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedSlide(
              offset: active ? const Offset(0, -0.22) : Offset.zero,
              duration: d,
              curve: Motion.curve,
              child: AnimatedScale(
                scale: active ? 1.06 : 1,
                duration: d,
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: active ? activeColor : c.textDim),
                  duration: d,
                  builder: (_, col, _) => Icon(item.icon, size: 23, color: col),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: AnimatedOpacity(
                opacity: active ? 1 : 0,
                duration: d,
                child: AnimatedSlide(
                  offset: active ? Offset.zero : const Offset(0, 0.4),
                  duration: d,
                  curve: Motion.curve,
                  child: Text(
                    item.label.toUpperCase(),
                    style: T.label(c.text).copyWith(fontSize: 9, letterSpacing: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
