import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

class RTPUApp extends StatelessWidget {
  const RTPUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTPU',
      theme: AppTheme.theme(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

