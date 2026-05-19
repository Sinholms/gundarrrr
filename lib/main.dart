import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const WessLessApp());
}

class WessLessApp extends StatelessWidget {
  const WessLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WessLess',
      debugShowCheckedModeBanner: false,
      theme: WessLessTheme.lightTheme,
      builder: (context, child) {
        return _MobileWrapper(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}

/// Constrains the app to mobile viewport on desktop browsers
class _MobileWrapper extends StatelessWidget {
  final Widget child;
  const _MobileWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopFrame = screenWidth > 430;
    final appWidth = isDesktopFrame ? 430.0 : screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: Center(
        child: SizedBox(
          width: appWidth,
          height: double.infinity,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: WessLessTheme.background,
              borderRadius: isDesktopFrame ? BorderRadius.circular(20) : null,
              boxShadow: isDesktopFrame
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius:
                  isDesktopFrame ? BorderRadius.circular(20) : BorderRadius.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
