import 'package:flutter/material.dart';

import '../features/home/data/home_data_service.dart';

import 'navigation/siaga_shell.dart';
import 'siaga_theme.dart';

class SiagaApp extends StatelessWidget {
  const SiagaApp({this.homeDataService, super.key});

  final HomeDataService? homeDataService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiagaBencana',
      debugShowCheckedModeBanner: false,
      theme: SiagaTheme.light,
      home: SiagaShell(homeDataService: homeDataService),
    );
  }
}
