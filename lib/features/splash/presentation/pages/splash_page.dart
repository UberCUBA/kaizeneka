import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late AnimationController _textController;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _logoController.forward();
    await _textController.forward();
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final route = authProvider.isAuthenticated ? '/home' : '/login';
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF001100)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_logoOpacity, _logoScale]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: const Text(
                        'KAIZEN',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00FF7F),
                          shadows: [
                            Shadow(
                              blurRadius: 20.0,
                              color: Color(0xFF00FF7F),
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _textOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: const Column(
                      children: [
                        Text(
                          'HACKEA TU ÉXITO VITAL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Bienvenido, Kaizeneka 🥷',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Tu misión empieza ahora.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}