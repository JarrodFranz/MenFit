import 'package:flutter/material.dart';

/// Full-screen branding and splash screen for MenFit.
///
/// Features the signature Forge charcoal / ember gradient, a glowing
/// brand emblem, and brand typography.
class MenFitSplashScreen extends StatefulWidget {
  const MenFitSplashScreen({
    this.onLoaded,
    this.duration = const Duration(milliseconds: 2200),
    super.key,
  });

  /// Optional callback invoked after splash display duration.
  final VoidCallback? onLoaded;

  /// Duration to hold the splash screen before calling [onLoaded].
  final Duration duration;

  @override
  State<MenFitSplashScreen> createState() => _MenFitSplashScreenState();
}

class _MenFitSplashScreenState extends State<MenFitSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    if (widget.onLoaded != null) {
      Future<void>.delayed(widget.duration, () {
        if (mounted) {
          widget.onLoaded?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A1C0A), // Forge Ember
              Color(0xFF241511), // Deep Char
              Color(0xFF121212), // Charcoal
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Icon / Crest
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6D3A).withValues(
                              alpha: 0.50,
                            ),
                            blurRadius: 36,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/menfit_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const ColoredBox(
                                color: Color(0xFFD84A1B),
                                child: Icon(
                                  Icons.directions_run,
                                  size: 72,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App Title
                    const Text(
                      'MenFit',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x80FF6D3A),
                            blurRadius: 18,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    const Text(
                      'Train Strong. Recover Smarter.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.4,
                        color: Color(0xFFE8DBD2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
