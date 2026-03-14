// 주기 타이머와 효과음 재생 같은 저수준 타이머 동작을 감싼다.
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class TimerService {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void startPeriodic({
    required Duration duration,
    required void Function(Timer timer) onTick,
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(duration, onTick);
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> playSound(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // Ignore sound failures to keep the timer flow running.
    }
  }

  Future<void> dispose() async {
    cancelTimer();
    await _audioPlayer.dispose();
  }
}
