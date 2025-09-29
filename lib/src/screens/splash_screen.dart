import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth/sign_in_screen.dart';
import 'tabs/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Defer to ensure context.read works
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      void maybeNavigate() {
        if (_navigated) return;
        if (!mounted) return;
        if (auth.status == AuthStatus.unknown) return;
        _navigated = true;
        if (auth.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        }
      }

      // Listen for changes to move away from splash when ready
      auth.addListener(maybeNavigate);
      // Also try immediately in case already known
      maybeNavigate();

      // Remove listener when disposed
      setState(() {
        _removeListener = () => auth.removeListener(maybeNavigate);
      });
    });
  }

  VoidCallback? _removeListener;

  @override
  void dispose() {
    _removeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

