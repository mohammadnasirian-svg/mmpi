import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import '../../core/localization/app_strings.dart';
import '../widgets/three_d_widgets.dart';
import 'zen_test_view.dart';
import 'rapid_entry_console.dart';
import 'report_view.dart';
import 'patient_records_screen.dart';
import 'settings_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);
        final s = customState.strings;
        final isEn = customState.isEn;

        return BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, assessState) {
            return Directionality(
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.bgTop, palette.bgBottom],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Top Brand Header (Visible on Home, Records, Settings)
                        if (_selectedNavIndex != 2)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                            child: NahiraTopBrandHeader(
                              strings: s,
                              palette: palette,
                              onToggleLanguage: () =>
                                  context.read<CustomizationCubit>().toggleLanguage(),
                            ),
                          ),

                        // Active Workspace Body
                        Expanded(
                          child: IndexedStack(
                            index: _selectedNavIndex,
                            children: [
                              _buildAssessmentWorkspace(context, assessState, palette, s, isEn),
                              PatientRecordsScreen(
                                onSwitchToAssessmentTab: () {
                                  setState(() => _selectedNavIndex = 0);
                                  _showCleanPatientRegistrationSheet(context, palette, s, isEn);
                                },
                              ),
                              const ReportView(isEmbedded: true),
                              const SettingsScreen(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: palette.cardBottom,
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _navBarItem(
                            index: 0,
                            icon: Icons.assignment_rounded,
                            label: s.navHome,
                            palette: palette,
                          ),
                          _navBarItem(
                            index: 1,
                            icon: Icons.folder_shared_rounded,
                            label: s.navPatients,
                            badgeCount: assessState.history.length,
                            palette: palette,
                          ),
                          _navBarItem(
                            index: 2,
                            icon: Icons.insights_rounded,
                            label: s.navAnalytics,
                            palette: palette,
                          ),
                          _navBarItem(
                            index: 3,
                            icon: Icons.tune_rounded,
                            label: s.navSettings,
                            palette: palette,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _navBarItem({
    required int index,
    required IconData icon,
    required String label,
    int badgeCount = 0,
    required NahiraPalette palette,
  }) {
    final isSelected = _selectedNavIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
          if (index == 2) {
            context.read<AssessmentCubit>().calculateScores();
          }
          setState(() => _selectedNavIndex = index);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? palette.accentPrimary.withOpacity(0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? palette.accentPrimary : palette.textSecondary,
                    size: 23,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: palette.goldAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$badgeCount",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? palette.accentPrimary : palette.textSecondary,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentWorkspace(
    BuildContext context,
    AssessmentState assessState,
    NahiraPalette palette,
    AppStrings s,
    bool isEn,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        // 1. Clean Patient Registration / Active File Card (No pre-filled dummy values!)
        Nahira3DCard(
          depth: 6,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          glowColor: palette.accentPrimary,
          child: !assessState.hasActivePatient
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: palette.accentPrimary.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: palette.accentPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.newPatientRegistration,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.noActivePatientDesc,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12.5,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Nahira3DButton(
                      label: s.registerPatientBtn,
                      icon: Icons.add_circle_outline_rounded,
                      primaryColor: const Color(0xFF0284C7),
                      darkBevelColor: const Color(0xFF075985),
                      height: 50,
                      fontSize: 14.5,
                      onTap: () => _showCleanPatientRegistrationSheet(context, palette, s, isEn),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: palette.accentPrimary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              s.activePatientFile,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _showCleanPatientRegistrationSheet(context, palette, s, isEn),
                          icon: Icon(Icons.person_add_rounded, color: palette.goldAccent, size: 17),
                          label: Text(
                            s.registerPatientBtn,
                            style: TextStyle(
                              color: palette.goldAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoBadge(assessState.clientName, palette),
                        if (assessState.clientAge > 0)
                          _infoBadge(
                            "${assessState.clientAge} ${isEn ? 'yrs' : 'ساله'}",
                            palette,
                          ),
                        _infoBadge(
                          assessState.gender == 'male' ? s.maleNorm : s.femaleNorm,
                          palette,
                        ),
                        if (assessState.education.isNotEmpty)
                          _infoBadge(assessState.education, palette),
                        if (assessState.nationalCode.isNotEmpty)
                          _infoBadge("#${assessState.nationalCode}", palette),
                      ],
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),

        // 2. Protocol & Form Length Selector Card
        Nahira3DCard(
          depth: 5,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.layers_rounded, color: palette.accentPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        s.testModeSectionTitle,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  // Normative Gender Quick Switch
                  Row(
                    children: [
                      _genderQuickChip(
                        context: context,
                        label: s.maleNorm,
                        value: 'male',
                        current: assessState.gender,
                        palette: palette,
                      ),
                      const SizedBox(width: 6),
                      _genderQuickChip(
                        context: context,
                        label: s.femaleNorm,
                        value: 'female',
                        current: assessState.gender,
                        palette: palette,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _lengthSelectorCard(
                    context: context,
                    count: 567,
                    title: s.mode567Title,
                    current: assessState.totalQuestions,
                    palette: palette,
                  ),
                  const SizedBox(width: 8),
                  _lengthSelectorCard(
                    context: context,
                    count: 370,
                    title: s.mode370Title,
                    current: assessState.totalQuestions,
                    palette: palette,
                  ),
                  const SizedBox(width: 8),
                  _lengthSelectorCard(
                    context: context,
                    count: 30,
                    title: s.mode30Title,
                    current: assessState.totalQuestions,
                    palette: palette,
                  ),
                ],
              ),
              if (assessState.answeredCount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${s.answeredWord}: ${assessState.answeredCount} / ${assessState.totalQuestions}",
                      style: TextStyle(
                        color: palette.accentPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.read<AssessmentCubit>().resetTest(),
                      child: Text(
                        s.resetTestBtn,
                        style: const TextStyle(
                          color: Color(0xFFFB7185),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Primary Assessment Launchpad Buttons
        Nahira3DButton(
          label: assessState.answeredCount > 0
              ? "${s.continueTestBtn} (${s.questionWord} ${assessState.currentIndex + 1})"
              : s.startTestBtn,
          sublabel: s.startTestSub,
          icon: Icons.play_circle_fill_rounded,
          primaryColor: const Color(0xFF0284C7),
          darkBevelColor: const Color(0xFF075985),
          height: 68,
          fontSize: 16.5,
          onTap: () {
            context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ZenTestView()),
            );
          },
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Nahira3DButton(
                label: s.rapidConsoleBtn,
                sublabel: s.rapidConsoleSub,
                icon: Icons.dialpad_rounded,
                primaryColor: const Color(0xFF0D9488),
                darkBevelColor: const Color(0xFF115E59),
                height: 64,
                fontSize: 14,
                onTap: () {
                  context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RapidEntryConsole()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Nahira3DButton(
                label: s.viewReportBtn,
                sublabel: s.viewReportSub,
                icon: Icons.insights_rounded,
                primaryColor: const Color(0xFF4F46E5),
                darkBevelColor: const Color(0xFF312E81),
                height: 64,
                fontSize: 14,
                onTap: () {
                  context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
                  context.read<AssessmentCubit>().calculateScores();
                  setState(() => _selectedNavIndex = 2);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 4. Clinical Profile Simulation Lab (2x2 Grid)
        Nahira3DCard(
          depth: 5,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          glowColor: palette.goldAccent,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_graph_rounded, color: palette.goldAccent, size: 21),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.simulatorTitle,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                s.simulatorDesc,
                style: TextStyle(color: palette.textSecondary, fontSize: 11.8, height: 1.5),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.8,
                children: [
                  _simGridTile(
                    context,
                    preset: 'depression_anxiety',
                    label: s.simDepAnx,
                    color: const Color(0xFFE11D48),
                    isEn: isEn,
                  ),
                  _simGridTile(
                    context,
                    preset: 'somatization',
                    label: s.simSomat,
                    color: const Color(0xFFD97706),
                    isEn: isEn,
                  ),
                  _simGridTile(
                    context,
                    preset: 'paranoid_schizo',
                    label: s.simParanoid,
                    color: const Color(0xFF7C3AED),
                    isEn: isEn,
                  ),
                  _simGridTile(
                    context,
                    preset: 'normal',
                    label: s.simNormal,
                    color: const Color(0xFF059669),
                    isEn: isEn,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // 5. Creators & Developers Showcase Card at the Bottom!
        NahiraCreatorsShowcaseCard(
          strings: s,
          palette: palette,
        ),
      ],
    );
  }

  Widget _infoBadge(String text, NahiraPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: TextStyle(color: palette.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _genderQuickChip({
    required BuildContext context,
    required String label,
    required String value,
    required String current,
    required NahiraPalette palette,
  }) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => context.read<AssessmentCubit>().setGender(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? palette.accentPrimary : Colors.black26,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : palette.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _lengthSelectorCard({
    required BuildContext context,
    required int count,
    required String title,
    required int current,
    required NahiraPalette palette,
  }) {
    final isSelected = count == current;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
          context.read<AssessmentCubit>().setTestLength(count);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [palette.accentPrimary, palette.accentSecondary])
                : null,
            color: isSelected ? null : Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white60 : Colors.white12,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : palette.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _simGridTile(
    BuildContext context, {
    required String preset,
    required String label,
    required Color color,
    required bool isEn,
  }) {
    return InkWell(
      onTap: () {
        context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
        context.read<AssessmentCubit>().loadSimulatedProfile(preset, isEn: isEn);
        setState(() => _selectedNavIndex = 2);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.65)),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: color, size: 17),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCleanPatientRegistrationSheet(
    BuildContext context,
    NahiraPalette palette,
    AppStrings s,
    bool isEn,
  ) {
    // Always start with clean, empty controllers so the user never has to erase pre-filled text!
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String selectedGender = context.read<AssessmentCubit>().state.gender;
    String selectedEdu = s.eduBachelor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bgBottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Directionality(
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.newPatientRegistration,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: s.fullNameLabel,
                        hintText: s.fullNameHint,
                        labelStyle: TextStyle(color: palette.textSecondary),
                        hintStyle: TextStyle(color: palette.textSecondary.withOpacity(0.5)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: palette.textPrimary),
                            decoration: InputDecoration(
                              labelText: s.ageLabel,
                              hintText: s.ageHint,
                              labelStyle: TextStyle(color: palette.textSecondary),
                              hintStyle: TextStyle(color: palette.textSecondary.withOpacity(0.5)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: codeCtrl,
                            style: TextStyle(color: palette.textPrimary),
                            decoration: InputDecoration(
                              labelText: s.fileCodeLabel,
                              hintText: s.fileCodeHint,
                              labelStyle: TextStyle(color: palette.textSecondary),
                              hintStyle: TextStyle(color: palette.textSecondary.withOpacity(0.5)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          "${s.genderNormLabel}:",
                          style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: Text(s.maleNorm),
                          selected: selectedGender == 'male',
                          selectedColor: palette.accentPrimary,
                          onSelected: (_) => setModalState(() => selectedGender = 'male'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(s.femaleNorm),
                          selected: selectedGender == 'female',
                          selectedColor: palette.accentPrimary,
                          onSelected: (_) => setModalState(() => selectedGender = 'female'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [s.eduDiploma, s.eduBachelor, s.eduMaster, s.eduPhd].map((edu) {
                        return ChoiceChip(
                          label: Text(edu, style: const TextStyle(fontSize: 12)),
                          selected: selectedEdu == edu,
                          selectedColor: palette.accentSecondary,
                          onSelected: (_) => setModalState(() => selectedEdu = edu),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Nahira3DButton(
                      label: s.saveAndStartBtn,
                      icon: Icons.check_circle_rounded,
                      primaryColor: const Color(0xFF059669),
                      darkBevelColor: const Color(0xFF064E3B),
                      height: 52,
                      fontSize: 15,
                      onTap: () {
                        final enteredName = nameCtrl.text.trim();
                        final enteredAge = int.tryParse(ageCtrl.text.trim()) ?? 30;
                        context.read<AssessmentCubit>().registerClientInfo(
                              clientName: enteredName.isEmpty
                                  ? (isEn ? 'Clinical Patient' : 'مراجع ثبت‌شده')
                                  : enteredName,
                              nationalCode: codeCtrl.text.trim(),
                              clientAge: enteredAge,
                              gender: selectedGender,
                              education: selectedEdu,
                            );
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
