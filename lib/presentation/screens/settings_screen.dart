import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../widgets/three_d_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final cubit = context.read<CustomizationCubit>();
        final palette = NahiraPalette.fromPreset(customState.visualPreset);
        final s = customState.strings;
        final isEn = customState.isEn;

        return Directionality(
          textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              // 1. Language Selection Card
              Nahira3DCard(
                depth: 5,
                topColor: palette.cardTop,
                bottomColor: palette.cardBottom,
                bevelColor: palette.cardBevel,
                glowColor: palette.accentPrimary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.translate_rounded, color: palette.accentPrimary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          s.langSectionTitle,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _selectableOptionTile(
                            title: "فارسی (Persian)",
                            subtitle: "چیدمان راست‌به‌چپ استاندارد",
                            isSelected: !isEn,
                            palette: palette,
                            onTap: () => cubit.setLanguage('fa'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _selectableOptionTile(
                            title: "English (International)",
                            subtitle: "Standard LTR Clinical UI",
                            isSelected: isEn,
                            palette: palette,
                            onTap: () => cubit.setLanguage('en'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Visual Theme & 3D Depth Card
              Nahira3DCard(
                depth: 5,
                topColor: palette.cardTop,
                bottomColor: palette.cardBottom,
                bevelColor: palette.cardBevel,
                glowColor: palette.accentSecondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_rounded, color: palette.accentSecondary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          s.themeSectionTitle,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.4,
                      children: [
                        _themeOptionCard(
                          label: s.themeRoyal,
                          preset: 'royal_3d',
                          current: customState.visualPreset,
                          dotColor: const Color(0xFF0EA5E9),
                          palette: palette,
                          onTap: () => cubit.updateTheme('royal_3d'),
                        ),
                        _themeOptionCard(
                          label: s.themeAmoled,
                          preset: 'amoled_black',
                          current: customState.visualPreset,
                          dotColor: const Color(0xFF6366F1),
                          palette: palette,
                          onTap: () => cubit.updateTheme('amoled_black'),
                        ),
                        _themeOptionCard(
                          label: s.themeSepia,
                          preset: 'sepia_warm',
                          current: customState.visualPreset,
                          dotColor: const Color(0xFFD97706),
                          palette: palette,
                          onTap: () => cubit.updateTheme('sepia_warm'),
                        ),
                        _themeOptionCard(
                          label: s.themeDaylight,
                          preset: 'daylight',
                          current: customState.visualPreset,
                          dotColor: const Color(0xFF0284C7),
                          palette: palette,
                          onTap: () => cubit.updateTheme('daylight'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Acoustic Chimes & Sound Engine Card
              Nahira3DCard(
                depth: 5,
                topColor: palette.cardTop,
                bottomColor: palette.cardBottom,
                bevelColor: palette.cardBevel,
                glowColor: palette.goldAccent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volume_up_rounded, color: palette.goldAccent, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          s.soundSectionTitle,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        s.soundToggleTitle,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        s.soundToggleSub,
                        style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                      ),
                      value: customState.enableAudioBeep,
                      activeColor: palette.goldAccent,
                      onChanged: (_) => cubit.toggleAudioBeep(),
                    ),
                    const SizedBox(height: 8),
                    Nahira3DButton(
                      label: s.testSoundBtn,
                      icon: Icons.music_note_rounded,
                      primaryColor: const Color(0xFF0D9488),
                      darkBevelColor: const Color(0xFF115E59),
                      height: 46,
                      fontSize: 13.5,
                      onTap: () => cubit.testAudioChime(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Ergonomics & Typography Card
              Nahira3DCard(
                depth: 5,
                topColor: palette.cardTop,
                bottomColor: palette.cardBottom,
                bevelColor: palette.cardBevel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields_rounded, color: palette.accentPrimary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          s.ergonomicsTitle,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.fontSizeTitle,
                          style: TextStyle(color: palette.textPrimary, fontSize: 13.5),
                        ),
                        Text(
                          "${customState.questionFontSize.round()} pt",
                          style: TextStyle(
                            color: palette.accentPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: customState.questionFontSize,
                      min: 16.0,
                      max: 28.0,
                      divisions: 6,
                      activeColor: palette.accentPrimary,
                      onChanged: (v) => cubit.updateFontSize(v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        s.leftHandedTitle,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: customState.isLeftHanded,
                      activeColor: palette.accentPrimary,
                      onChanged: (_) => cubit.toggleLeftHanded(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 5. Luxury Creators & Developers Showcase at the Bottom
              NahiraCreatorsShowcaseCard(
                strings: s,
                palette: palette,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _selectableOptionTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required NahiraPalette palette,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [palette.accentPrimary, palette.accentSecondary])
              : null,
          color: isSelected ? null : Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.white60 : Colors.white12,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : palette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Colors.white70 : palette.textSecondary,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOptionCard({
    required String label,
    required String preset,
    required String current,
    required Color dotColor,
    required NahiraPalette palette,
    required VoidCallback onTap,
  }) {
    final isSelected = preset == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? dotColor.withOpacity(0.2) : Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? dotColor : Colors.white12,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
