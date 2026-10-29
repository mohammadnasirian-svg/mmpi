import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/cubits/customization_cubit.dart';
import 'presentation/cubits/assessment_cubit.dart';
import 'presentation/screens/main_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CustomizationCubit>(create: (_) => CustomizationCubit()),
        BlocProvider<AssessmentCubit>(create: (_) => AssessmentCubit()),
      ],
      child: const NahiraMMPIApp(),
    ),
  );
}

class NahiraMMPIApp extends StatelessWidget {
  const NahiraMMPIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        return MaterialApp(
          title: 'Nahira MMPI',
          debugShowCheckedModeBanner: false,
          locale: customState.isEn ? const Locale('en', 'US') : const Locale('fa', 'IR'),
          supportedLocales: const [
            Locale('fa', 'IR'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF0EA5E9),
          ),
          home: const MainDashboard(),
        );
      },
    );
  }
}
