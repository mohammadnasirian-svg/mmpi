import 'package:flutter/services.dart';

class SoundService {
  static void playTone({required int freqHz, required int durationMs}) {
    // Auditory feedback for rapid entry
    // On mobile devices, system haptic / click sounds can accompany or represent tones
    if (freqHz >= 800) {
      SystemSound.play(SystemSoundType.click);
    } else if (freqHz >= 450) {
      SystemSound.play(SystemSoundType.alert);
    } else {
      HapticFeedback.heavyImpact();
    }
  }
}
