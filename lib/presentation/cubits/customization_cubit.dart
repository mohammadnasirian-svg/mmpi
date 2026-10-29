import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/sound_service.dart';

class AppCustomizationState {
  final String fontFamily;
  final double questionFontSize;
  final double lineHeight;
  final String visualPreset; // 'daylight', 'sepia_warm', 'slate_dark', 'amoled_black'
  final bool isLeftHanded;
  final bool enableAudioBeep;
  final bool enableTtsReader;

  const AppCustomizationState({
    this.fontFamily = 'Vazirmatn',
    this.questionFontSize = 20.0,
    this.lineHeight = 1.7,
    this.visualPreset = 'sepia_warm',
    this.isLeftHanded = false,
    this.enableAudioBeep = true,
    this.enableTtsReader = false,
  });

  AppCustomizationState copyWith({
    String? fontFamily,
    double? questionFontSize,
    double? lineHeight,
    String? visualPreset,
    bool? isLeftHanded,
    bool? enableAudioBeep,
    bool? enableTtsReader,
  }) {
    return AppCustomizationState(
      fontFamily: fontFamily ?? this.fontFamily,
      questionFontSize: questionFontSize ?? this.questionFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      visualPreset: visualPreset ?? this.visualPreset,
      isLeftHanded: isLeftHanded ?? this.isLeftHanded,
      enableAudioBeep: enableAudioBeep ?? this.enableAudioBeep,
      enableTtsReader: enableTtsReader ?? this.enableTtsReader,
    );
  }
}

class CustomizationCubit extends Cubit<AppCustomizationState> {
  CustomizationCubit() : super(const AppCustomizationState());

  void updateTheme(String theme) => emit(state.copyWith(visualPreset: theme));
  void toggleLeftHanded() => emit(state.copyWith(isLeftHanded: !state.isLeftHanded));
  void updateFontSize(double size) => emit(state.copyWith(questionFontSize: size));
  void updateLineHeight(double height) => emit(state.copyWith(lineHeight: height));
  void toggleAudioBeep() => emit(state.copyWith(enableAudioBeep: !state.enableAudioBeep));
  void toggleTtsReader() => emit(state.copyWith(enableTtsReader: !state.enableTtsReader));

  void onTherapistRapidKeyTap(String answerChoice) {
    if (answerChoice == 'T') {
      HapticFeedback.lightImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 800, durationMs: 45);
    } else if (answerChoice == 'F') {
      HapticFeedback.mediumImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 450, durationMs: 60);
    } else {
      HapticFeedback.heavyImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 300, durationMs: 150);
    }
  }
}
