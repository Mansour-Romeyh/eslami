import 'dart:math' as math;
import 'package:animate_do/animate_do.dart';
import 'package:eslami/screens/Theme%20controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show sin, cos, atan2, pi;

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasPermissions = false;
  bool _isLoading = true;
  bool _hasSensorSupport = true;
  Position? _currentPosition;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Check sensor support
      final support = await FlutterQiblah.androidDeviceSensorSupport();
      if (!mounted) return;
      if (support == false) {
        setState(() {
          _hasSensorSupport = false;
          _isLoading = false;
        });
        return;
      }

      // 2. Check / request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _hasPermissions = false;
          _isLoading = false;
        });
        return;
      }

      // 3. Get a one-shot current position (faster, no waiting)
      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () => Position(
              latitude: 21.3891, // مكة المكرمة كموقع افتراضي
              longitude: 39.8579,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            ),
          );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _hasPermissions = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'اتجاه القبلة',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeController.isDarkMode.value
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFF8BA09E), const Color(0xFFAC844D)],
          ),
        ),
        child: _buildBody(themeController),
      ),
    );
  }

  Widget _buildBody(ThemeController themeController) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'جارٍ تحديد موقعك...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildError('حدث خطأ: $_errorMessage', themeController);
    }

    if (!_hasSensorSupport) {
      return _buildNoSensorError(themeController);
    }

    if (!_hasPermissions) {
      return _buildPermissionError(themeController);
    }

    return _buildCompass(themeController);
  }

  Widget _buildError(String message, ThemeController themeController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.white70),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initialize,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC844D),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSensorError(ThemeController themeController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.screen_rotation_rounded,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            const Text(
              'عذراً، هذا الجهاز لا يدعم حساس البوصلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionError(ThemeController themeController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            const Text(
              'يرجى تفعيل إذن الموقع لتحديد اتجاه القبلة بدقة',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initialize,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC844D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'طلب الإذن',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(ThemeController themeController) {
    final position = _currentPosition!;

    // Calculate Qibla offset from North (Mecca coordinates)
    const meccaLat = 21.3891;
    const meccaLng = 39.8579;
    final qiblaOffset = _calculateQibla(
      position.latitude,
      position.longitude,
      meccaLat,
      meccaLng,
    );

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.heading == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'جارٍ قراءة البوصلة...\nتأكد من تحريك الهاتف بشكل رقم 8',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        final direction = snapshot.data!.heading!;
        // Rotate needle by qiblaOffset against North, then compensate for device rotation
        final qiblahAngle = qiblaOffset - direction;

        // Haptic feedback when aligned with Qibla (within 2 degrees)
        try {
          final diff = ((direction - qiblaOffset) % 360 + 360) % 360;
          if (diff < 2 || diff > 358) {
            HapticFeedback.vibrate();
          }
        } catch (_) {}

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              FadeInDown(
                child: Column(
                  children: [
                    Text(
                      '${direction.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'درجة',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Circle
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  // Inner Circle
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  // Compass Plate
                  Transform.rotate(
                    angle: direction * (math.pi / 180) * -1,
                    child: _buildCompassPlate(),
                  ),
                  // Qibla Needle
                  Transform.rotate(
                    angle: qiblahAngle * (math.pi / 180) * -1,
                    child: _buildQiblaNeedle(),
                  ),
                  // Center dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFAC844D),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'اجعل الهاتف موازياً للأرض للحصول على أفضل دقة',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// حساب زاوية القبلة من موقع المستخدم باتجاه مكة المكرمة
  double _calculateQibla(double lat1, double lng1, double lat2, double lng2) {
    final dLng = (lng2 - lng1) * pi / 180;
    final lat1Rad = lat1 * pi / 180;
    final lat2Rad = lat2 * pi / 180;

    final y = sin(dLng) * cos(lat2Rad);
    final x =
        cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  Widget _buildCompassPlate() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(36, (index) {
            final double angle = index * 10.0;
            return Transform.rotate(
              angle: angle * (math.pi / 180),
              child: Column(
                children: [
                  Container(
                    height: index % 9 == 0 ? 15 : 8,
                    width: 2,
                    color: index % 9 == 0 ? Colors.white : Colors.white38,
                  ),
                  const Spacer(),
                ],
              ),
            );
          }),
          _buildCardinalPoint('N', 0),
          _buildCardinalPoint('E', 90),
          _buildCardinalPoint('S', 180),
          _buildCardinalPoint('W', 270),
        ],
      ),
    );
  }

  Widget _buildCardinalPoint(String text, double degree) {
    return Transform.rotate(
      angle: degree * (math.pi / 180),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            text,
            style: TextStyle(
              color: text == 'N' ? const Color(0xFFAC844D) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildQiblaNeedle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Color(0xFFF3E5BB),
              size: 40,
            ),
            Container(
              height: 120,
              width: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF3E5BB), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFAC844D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
