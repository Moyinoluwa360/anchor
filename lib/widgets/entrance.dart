import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Fades and lifts a child in, staggered by [index]. Under 400 ms in total
/// for the first items; nothing at all with Reduce Motion on.
class Entrance extends StatefulWidget {
  const Entrance({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _a.value = 1;
    } else if (_a.value == 0 && _delay == null) {
      _delay = Timer(Duration(milliseconds: 30 * widget.index.clamp(0, 4)), () {
        if (mounted) _a.forward();
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(curve),
        child: widget.child,
      ),
    );
  }
}

/// Wraps each child in an [Entrance] with increasing delay.
List<Widget> staggered(List<Widget> children) => [
      for (var i = 0; i < children.length; i++) Entrance(index: i, child: children[i]),
    ];
