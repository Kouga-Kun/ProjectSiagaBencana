import 'package:flutter/material.dart';

import '../features/auth/data/auth_session_service.dart';
import '../features/education/data/education_data_service.dart';
import '../features/home/data/home_data_service.dart';

import 'navigation/siaga_shell.dart';
import 'siaga_theme.dart';

class SiagaApp extends StatelessWidget {
  const SiagaApp({
    this.homeDataService,
    this.authSessionService,
    this.educationDataService,
    super.key,
  });

  final HomeDataService? homeDataService;
  final AuthSessionService? authSessionService;
  final EducationDataService? educationDataService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiagaBencana',
      debugShowCheckedModeBanner: false,
      theme: SiagaTheme.light,
      home: SiagaShell(
        homeDataService: homeDataService,
        authSessionService: authSessionService,
        educationDataService: educationDataService,
      ),
    );
  }
}
