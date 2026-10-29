import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import '../widgets/three_d_widgets.dart';
import 'report_view.dart';

class PatientRecordsScreen extends StatefulWidget {
  final VoidCallback? onSwitchToAssessmentTab;

  const PatientRecordsScreen({Key? key, this.onSwitchToAssessmentTab}) : super(key: key);

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);
        final s = customState.strings;
        final isEn = customState.isEn;

        return BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, assessState) {
            final filtered = assessState.history.where((rec) {
              if (_searchQuery.trim().isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return rec.clientName.toLowerCase().contains(q) ||
                  rec.nationalCode.toLowerCase().contains(q) ||
                  rec.result.twoPointCode.toLowerCase().contains(q);
            }).toList();

            return Directionality(
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                children: [
                  // Header Card
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
                            Icon(Icons.folder_shared_rounded, color: palette.accentPrimary, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.recordsHeader,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: palette.accentPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${assessState.history.length}",
                                style: TextStyle(
                                  color: palette.accentPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: TextStyle(color: palette.textPrimary, fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: s.searchPatientsHint,
                            hintStyle: TextStyle(color: palette.textSecondary, fontSize: 12.5),
                            prefixIcon: Icon(Icons.search_rounded, color: palette.textSecondary),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (filtered.isEmpty)
                    Nahira3DCard(
                      depth: 5,
                      topColor: palette.cardTop,
                      bottomColor: palette.cardBottom,
                      bevelColor: palette.cardBevel,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
                      child: Column(
                        children: [
                          Icon(
                            Icons.clinical_notes_rounded,
                            size: 52,
                            color: palette.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            s.emptyRecordsTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.emptyRecordsSub,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12.5,
                              height: 1.6,
                            ),
                          ),
                          if (widget.onSwitchToAssessmentTab != null) ...[
                            const SizedBox(height: 18),
                            Nahira3DButton(
                              label: s.registerPatientBtn,
                              icon: Icons.person_add_alt_1_rounded,
                              primaryColor: const Color(0xFF0284C7),
                              darkBevelColor: const Color(0xFF075985),
                              height: 50,
                              fontSize: 14,
                              onTap: widget.onSwitchToAssessmentTab!,
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    ...filtered.map((record) {
                      final dateStr =
                          "${record.date.year}/${record.date.month.toString().padLeft(2, '0')}/${record.date.day.toString().padLeft(2, '0')}";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: NahiraInteractive3DCard(
                          palette: palette,
                          glowColor: palette.accentPrimary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: palette.accentPrimary.withOpacity(0.18),
                                          child: Icon(
                                            record.gender == 'male'
                                                ? Icons.person_rounded
                                                : Icons.person_3_rounded,
                                            color: palette.accentPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                record.clientName,
                                                style: TextStyle(
                                                  color: palette.textPrimary,
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${record.gender == 'male' ? s.maleNorm : s.femaleNorm}  •  ${record.age} ${isEn ? 'yrs' : 'ساله'}  •  $dateStr",
                                                style: TextStyle(
                                                  color: palette.textSecondary,
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: palette.goldAccent.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: palette.goldAccent.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      record.result.twoPointCode,
                                      style: TextStyle(
                                        color: palette.goldAccent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _recordChip(
                                    "Welsh: ${record.result.welshCode}",
                                    palette,
                                  ),
                                  _recordChip(
                                    "F-K: ${record.result.fMinusKIndex}",
                                    palette,
                                  ),
                                  _recordChip(
                                    "${record.totalQuestions} ${s.questionWord}",
                                    palette,
                                  ),
                                  if (record.nationalCode.isNotEmpty)
                                    _recordChip(
                                      "#${record.nationalCode}",
                                      palette,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Nahira3DButton(
                                      label: s.loadRecordBtn,
                                      icon: Icons.insights_rounded,
                                      primaryColor: const Color(0xFF0284C7),
                                      darkBevelColor: const Color(0xFF075985),
                                      height: 46,
                                      fontSize: 13.5,
                                      onTap: () {
                                        context.read<AssessmentCubit>().loadSavedRecord(record);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const ReportView()),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: Nahira3DButton(
                                      label: s.deleteRecordBtn,
                                      primaryColor: const Color(0xFF475569),
                                      darkBevelColor: const Color(0xFF1E293B),
                                      height: 46,
                                      fontSize: 12.5,
                                      onTap: () =>
                                          context.read<AssessmentCubit>().deleteSavedRecord(record.id),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _recordChip(String text, NahiraPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: TextStyle(color: palette.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
