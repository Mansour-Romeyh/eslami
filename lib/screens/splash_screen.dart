import 'package:eslami/screens/Theme%20controller.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _raysController;
  late AnimationController _particlesController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Logo entrance - Multi-stage animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
    ]).animate(_logoController);

    _logoRotateAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Rays rotation - continuous
    _raysController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    )..repeat();

    // Particles floating
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 25000),
      vsync: this,
    )..repeat();

    // Float effect
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Start logo animation
    Future.delayed(Duration(milliseconds: 400), () {
      _logoController.forward();
    });

    // Navigate after longer delay
    Timer(const Duration(seconds: 6), () {
      Get.off(
        () => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1000),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _raysController.dispose();
    _particlesController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: themeController.isDarkMode.value
                  ? [
                      const Color(0xFF121212),
                      const Color(0xFF1E1E1E),
                      const Color(0xFF121212),
                    ]
                  : [
                      const Color(0xFF8BA09E),
                      const Color(0xFFA8B5A8),
                      const Color(0xFFCFC09E),
                      const Color(0xFFF3E5BB),
                    ],
              stops: themeController.isDarkMode.value
                  ? [0.0, 0.5, 1.0]
                  : [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated floating particles background
              ...List.generate(20, (index) {
                final random = math.Random(index);
                final startX = random.nextDouble() * size.width;
                final startY = random.nextDouble() * size.height;
                final particleSize = 3.0 + random.nextDouble() * 5;
                final delay = random.nextDouble() * 2;

                return AnimatedBuilder(
                  animation: _particlesController,
                  builder: (context, child) {
                    final progress = (_particlesController.value + delay) % 1.0;
                    return Positioned(
                      left: startX + math.sin(progress * 2 * math.pi) * 30,
                      top: startY - progress * size.height * 0.3,
                      child: Opacity(
                        opacity: (1 - progress) * 0.3,
                        child: Container(
                          width: particleSize,
                          height: particleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                themeController.getColor('primary'),
                                themeController
                                    .getColor('primary')
                                    .withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 2),

                    // Logo Section with Rays
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating rays behind logo
                        AnimatedBuilder(
                          animation: _raysController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _raysController.value * 2 * math.pi,
                              child: CustomPaint(
                                size: Size(size.width * 0.9, size.width * 0.9),
                                painter: RaysPainter(),
                              ),
                            );
                          },
                        ),

                        // Outer decorative circles
                        AnimatedBuilder(
                          animation: _raysController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: -_raysController.value * 2 * math.pi * 0.5,
                              child: Container(
                                width: size.width * 0.8,
                                height: size.width * 0.8,
                                child: CustomPaint(
                                  painter: DecorativeCirclesPainter(),
                                ),
                              ),
                            );
                          },
                        ),

                        // Shimmer effect
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return ClipOval(
                              child: Container(
                                width: size.width * 0.65,
                                height: size.width * 0.65,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFFFFFFFF).withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    stops: [
                                      _shimmerController.value - 0.3,
                                      _shimmerController.value,
                                      _shimmerController.value + 0.3,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Main Logo with animations
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _logoScaleAnimation,
                            _logoRotateAnimation,
                            _logoOpacityAnimation,
                            _floatAnimation,
                          ]),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: Transform.rotate(
                                angle: _logoRotateAnimation.value,
                                child: Transform.scale(
                                  scale: _logoScaleAnimation.value,
                                  child: Opacity(
                                    opacity: _logoOpacityAnimation.value,
                                    child: Container(
                                      width: size.width * 0.65,
                                      height: size.width * 0.65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(
                                              0xFFAC844D,
                                            ).withOpacity(0.5),
                                            blurRadius: 50,
                                            spreadRadius: 20,
                                          ),
                                          BoxShadow(
                                            color: Color(
                                              0xFFF3E5BB,
                                            ).withOpacity(0.3),
                                            blurRadius: 80,
                                            spreadRadius: 30,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'aseets/images/logo.png',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFFAC844D),
                                                        Color(0xFFCFC09E),
                                                        Color(0xFFF3E5BB),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.menu_book_rounded,
                                                      size: size.width * 0.3,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Text Section - All in One Container
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      delay: Duration(milliseconds: 1500),
                      child: SlideInUp(
                        duration: Duration(milliseconds: 800),
                        delay: Duration(milliseconds: 1500),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 25,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Color(0xFFF3E5BB).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Color(0xFFAC844D).withOpacity(0.6),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (themeController.isDarkMode.value
                                              ? Colors.black
                                              : const Color(0xFFAC844D))
                                          .withOpacity(0.3),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Top Decorative Line
                                Container(
                                  width: 120,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFFAC844D),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),

                                SizedBox(height: 15),

                                // Main Title
                                Text(
                                  'مختصر منهاج القاصدين',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: themeController.getColor('text'),
                                    letterSpacing: 1.3,
                                    height: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: themeController.isDarkMode.value
                                            ? Colors.black26
                                            : Colors.white.withOpacity(0.5),
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 15),

                                // Middle Decorative Line
                                Container(
                                  width: 120,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFFAC844D),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),

                                SizedBox(height: 18),

                                // Author Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFAC844D),
                                        Color(0xFFCFC09E),
                                        Color(0xFFAC844D),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFFAC844D,
                                        ).withOpacity(0.5),
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'ابن قُدامة المقدسي',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.auto_stories_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Spacer(flex: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Rays
class RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Color(0xFFAC844D).withOpacity(0.3),
              Color(0xFFAC844D).withOpacity(0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width / 2,
            ),
          )
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 16; i++) {
      final angle = (i * 22.5) * math.pi / 180;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(angle - 0.05) * radius,
          center.dy + math.sin(angle - 0.05) * radius,
        )
        ..lineTo(
          center.dx + math.cos(angle + 0.05) * radius,
          center.dy + math.sin(angle + 0.05) * radius,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Decorative Circles
class DecorativeCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFAC844D).withOpacity(0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw multiple decorative circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    // Draw decorative dots
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final dotRadius = 4.0;

      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius * 0.9,
          center.dy + math.sin(angle) * radius * 0.9,
        ),
        dotRadius,
        Paint()
          ..color = Color(0xFFAC844D).withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
