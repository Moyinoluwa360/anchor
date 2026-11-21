import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plays the bundled chime with a strong haptic when a timer phase ends while
/// the app is open. (In the background the scheduled notification plays the
/// same chime: see NotificationService.)
class AlarmPlayer {
  AudioPlayer? _player;

  Future<void> _ensure() async {
    if (_player != null) return;
    final p = AudioPlayer(playerId: 'exe-alarm');
    await p.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          // Plays even with the ring/silent switch on, and ducks music briefly.
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.duckOthers},
        ),
      ),
    );
    await p.setReleaseMode(ReleaseMode.stop);
    _player = p;
  }

  Future<void> ring({bool sound = true}) async {
    unawaited(_haptics());
    if (!sound) return;
    try {
      await _ensure();
      await _player!.stop();
      await _player!.play(AssetSource('sounds/chime.wav'), volume: 1);
    } catch (e) {
      debugPrint('Alarm sound failed: $e');
    }
  }

  Future<void> _haptics() async {
    for (var i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
  }

  Future<void> dispose() async => _player?.dispose();
}
