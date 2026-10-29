import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/cubits/customization_cubit.dart';
import 'presentation/cubits/assessment_cubit.dart';
import 'presentation/screens/main_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CustomizationCubit>(create: (_) => CustomizationCubit()),
        BlocProvider<AssessmentCubit>(create: (_) => AssessmentCubit()),
      ],
      child: const MMPI2App(),
    ),
  );
}

class MMPI2App extends StatelessWidget {
  const MMPI2App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'MMPI-2 Clinical Ultra',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            fontFamily: state.fontFamily,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fa', 'IR'),
            Locale('en', 'US'),
          ],
          locale: const Locale('fa', 'IR'),
          home: const MainDashboard(),
        );
      },
    );
  }
}
