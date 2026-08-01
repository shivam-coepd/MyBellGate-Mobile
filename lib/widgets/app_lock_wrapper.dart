import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/screens/auth/pin_lock_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/blocs/theme/theme_cubit.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    // Initial check when app starts
    _checkLockStatus();
  }

  void _checkLockStatus() {
    if (AppConfig.pinLockEnabled) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked && AppConfig.pinLockEnabled)
          Positioned.fill(
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  home: PinLockScreen(
                    onUnlock: () {
                      setState(() {
                        _isLocked = false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
