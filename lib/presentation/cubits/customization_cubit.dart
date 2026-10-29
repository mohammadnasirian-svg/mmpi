import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/sound_service.dart';
import '../../core/localization/app_strings.dart';

class AppCustomizationState {
  final String languageCode; // 'fa' or 'en'
  final String fontFamily;
  final double questionFontSize;
  final double lineHeight;
  final String visualPreset; // 'royal_3d', 'sepia_warm', 'daylight', 'amoled_black'
  final bool isLeftHanded;
  final bool enableAudioBeep;
  final bool enableTtsReader;

  const AppCustomizationState({
    this.languageCode = 'fa',
    this.fontFamily = 'Roboto',
    this.questionFontSize = 20.0,
    this.lineHeight = 1.75,
    this.visualPreset = 'royal_3d',
    this.isLeftHanded = false,
    this.enableAudioBeep = true,
    this.enableTtsReader = false,
  });

  bool get isEn => languageCode == 'en';
  AppStrings get strings => AppStrings(isEn);

  AppCustomizationState copyWith({
    String? languageCode,
    String? fontFamily,
    double? questionFontSize,
    double? lineHeight,
    String? visualPreset,
    bool? isLeftHanded,
    bool? enableAudioBeep,
    bool? enableTtsReader,
  }) {
    return AppCustomizationState(
      languageCode: languageCode ?? this.languageCode,
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

  void setLanguage(String code) {
    emit(state.copyWith(languageCode: code));
    if (state.enableAudioBeep) {
      SoundService.playTone(freqHz: 680, durationMs: 65);
    }
  }

  void toggleLanguage() {
    setLanguage(state.isEn ? 'fa' : 'en');
  }

  void updateTheme(String theme) {
    emit(state.copyWith(visualPreset: theme));
    if (state.enableAudioBeep) {
      SoundService.playTone(freqHz: 720, durationMs: 60);
    }
  }

  void toggleLeftHanded() => emit(state.copyWith(isLeftHanded: !state.isLeftHanded));
  void updateFontSize(double size) => emit(state.copyWith(questionFontSize: size));
  void updateLineHeight(double height) => emit(state.copyWith(lineHeight: height));

  void toggleAudioBeep() {
    final nextVal = !state.enableAudioBeep;
    emit(state.copyWith(enableAudioBeep: nextVal));
    if (nextVal) {
      SoundService.playTone(freqHz: 840, durationMs: 85);
    }
  }

  void testAudioChime() {
    HapticFeedback.mediumImpact();
    SoundService.playTone(freqHz: 880, durationMs: 110);
  }

  void toggleTtsReader() => emit(state.copyWith(enableTtsReader: !state.enableTtsReader));

  void onTherapistRapidKeyTap(String answerChoice) {
    if (answerChoice == 'T') {
      HapticFeedback.lightImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 820, durationMs: 70);
    } else if (answerChoice == 'F') {
      HapticFeedback.mediumImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 520, durationMs: 80);
    } else {
      HapticFeedback.heavyImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 360, durationMs: 100);
    }
  }
}
