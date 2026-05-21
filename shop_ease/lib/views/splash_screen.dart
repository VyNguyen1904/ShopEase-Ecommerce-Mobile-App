import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    bool isFirstLaunch = await _authService.isFirstLaunch();
    bool loggedIn = await _authService.isLoggedIn();
    
    if (!mounted) return;

    if (isFirstLaunch) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (loggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: SailboatBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Z',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Zanzibar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smart Shopping, Better Living',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(flex: 2),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SailboatBackgroundPainter extends CustomPainter {
  const SailboatBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF132F3D),
          Color(0xFF1E485D),
          Color(0xFF3D8C95),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.65), radius: 180));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.65), 180, sunPaint);

    final sunCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.65), 10, sunCorePaint);

    final mountainPaint1 = Paint()..color = const Color(0xFF1C3D4F);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.64, size.width * 0.5, size.height * 0.67);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.7, size.width, size.height * 0.66);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, mountainPaint1);

    final mountainPaint2 = Paint()..color = const Color(0xFF163242);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.72);
    path2.quadraticBezierTo(size.width * 0.35, size.height * 0.74, size.width * 0.7, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.85, size.height * 0.68, size.width, size.height * 0.71);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, mountainPaint2);

    final seaPaint = Paint()..color = const Color(0xFF0F2430);
    final seaRect = Rect.fromLTRB(0, size.height * 0.74, size.width, size.height);
    canvas.drawRect(seaRect, seaPaint);

    _drawSailboat(canvas, Offset(size.width * 0.22, size.height * 0.725), 34);
    _drawSailboat(canvas, Offset(size.width * 0.78, size.height * 0.74), 18);
  }

  void _drawSailboat(Canvas canvas, Offset bottomCenter, double height) {
    final boatPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    
    final hullPath = Path();
    hullPath.moveTo(bottomCenter.dx - height * 0.4, bottomCenter.dy);
    hullPath.lineTo(bottomCenter.dx + height * 0.4, bottomCenter.dy);
    hullPath.lineTo(bottomCenter.dx + height * 0.25, bottomCenter.dy + height * 0.1);
    hullPath.lineTo(bottomCenter.dx - height * 0.3, bottomCenter.dy + height * 0.1);
    hullPath.close();
    canvas.drawPath(hullPath, boatPaint);

    final mainSail = Path();
    mainSail.moveTo(bottomCenter.dx - height * 0.05, bottomCenter.dy - height * 0.05);
    mainSail.lineTo(bottomCenter.dx - height * 0.05, bottomCenter.dy - height * 0.9);
    mainSail.lineTo(bottomCenter.dx - height * 0.35, bottomCenter.dy - height * 0.25);
    mainSail.close();
    canvas.drawPath(mainSail, boatPaint);

    final jibSail = Path();
    jibSail.moveTo(bottomCenter.dx + height * 0.05, bottomCenter.dy - height * 0.05);
    jibSail.lineTo(bottomCenter.dx + height * 0.05, bottomCenter.dy - height * 0.75);
    jibSail.lineTo(bottomCenter.dx + height * 0.25, bottomCenter.dy - height * 0.25);
    jibSail.close();
    canvas.drawPath(jibSail, boatPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
