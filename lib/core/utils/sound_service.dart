import 'package:flutter/services.dart';

class SoundService {
  static const MethodChannel _channel = MethodChannel('nahira.mmpi/audio');

  static Future<void> playTone({required int freqHz, required int durationMs}) async {
    try {
      await _channel.invokeMethod('playTone', {
        'freqHz': freqHz,
        'durationMs': durationMs,
      });
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
