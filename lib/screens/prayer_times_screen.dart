import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:animate_do/animate_do.dart';
import 'package:eslami/screens/Theme%20controller.dart';
import 'package:eslami/screens/qibla_screen.dart';
import 'package:eslami/services/notification_service.dart';
import 'package:eslami/widgets/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({Key? key}) : super(key: key);

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _timer;
  Duration _timeToNextPrayer = Duration.zero;

  @override
  void initState() {
    super.initState();
    _getPrayerTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes != null) {
        _calculateCountdown();
      }
    });
  }

  void _calculateCountdown() {
    if (_prayerTimes == null) return;

    final next = _prayerTimes!.nextPrayer();
    DateTime? nextTime;

    if (next == Prayer.none) {
      if (mounted) {
        setState(() {
          _timeToNextPrayer = Duration.zero;
        });
      }
      return;
    } else {
      nextTime = _prayerTimes!.timeForPrayer(next);
    }

    if (nextTime != null) {
      final now = DateTime.now();
      if (mounted) {
        setState(() {
          _timeToNextPrayer = nextTime!.difference(now);
        });
      }
    }
  }

  Future<void> _getPrayerTimes() async {
    // ── Step 1: Get location & calculate prayer times ─────────────────────
    try {
      Position position = await _determinePosition();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;

      if (!mounted) return;

      setState(() {
        _prayerTimes = PrayerTimes.today(coordinates, params);
        _isLoading = false;
        _errorMessage = '';
      });

      _calculateCountdown();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('خدمات الموقع')
              ? 'GPS غير مفعّل، يرجى تشغيله ثم المحاولة مجدداً'
              : e.toString().contains('إذن')
              ? 'يرجى منح إذن الموقع للتطبيق من الإعدادات'
              : e.toString().contains('مهلة')
              ? 'انتهت مهلة GPS، تأكد من تفعيله وأعد المحاولة'
              : 'تعذّر تحديد موقعك، تأكد من تفعيل GPS وأعد المحاولة';
          _isLoading = false;
        });
      }
      return; // Don't proceed to notifications if location failed
    }

    // ── Step 2: Schedule notifications (silent – never blocks the UI) ─────
    try {
      await NotificationService().schedulePrayerNotifications({
        'الفجر': _prayerTimes!.fajr,
        'الظهر': _prayerTimes!.dhuhr,
        'العصر': _prayerTimes!.asr,
        'المغرب': _prayerTimes!.maghrib,
        'العشاء': _prayerTimes!.isha,
      });
    } catch (_) {
      // Notification scheduling is best-effort; ignore errors silently
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'خدمات الموقع (GPS) غير مفعلة، يرجى تفعيلها والمحاولة مجدداً',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('تم رفض إذن الوصول للموقع');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'إذن الموقع مرفوض نهائياً، يرجى تفعيله من إعدادات التطبيق',
      );
    }

    // Try last known position first (instant, works perfectly on app restart)
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
    } catch (_) {
      // If last known fails, continue to getCurrentPosition
    }

    // Fallback: get fresh position with a 15-second timeout to avoid hanging
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => Future.error(
        'انتهت مهلة تحديد الموقع، تأكد من تفعيل GPS وأعد المحاولة',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackground(themeController),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFAC844D)),
                  )
                : _errorMessage.isNotEmpty
                ? _buildErrorView(themeController)
                : _buildPrayerListView(themeController, responsive),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeController themeController) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeController.isDarkMode.value
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [const Color(0xFF8BA09E).withOpacity(0.5), Colors.white],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(ThemeController themeController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(color: themeController.getColor('text')),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _getPrayerTimes();
            },
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
    );
  }

  Widget _buildPrayerListView(
    ThemeController themeController,
    ResponsiveHelper responsive,
  ) {
    if (_prayerTimes == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Spacer to push content below the CustomAppBar
        const SizedBox(
          height: 15, // SafeArea already accounts for the CustomAppBar height
        ),
        const SizedBox(height: 20),
        _buildHeader(themeController, responsive),
        const SizedBox(height: 24),
        _buildNextPrayerCard(themeController, responsive),
        const SizedBox(height: 16),
        _buildQiblaButton(themeController, responsive),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding,
            ),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                _buildPrayerRow(
                  'الفجر',
                  _prayerTimes!.fajr,
                  themeController,
                  _prayerTimes!.currentPrayer() == Prayer.fajr,
                ),
                _buildPrayerRow(
                  'الشروق',
                  _prayerTimes!.sunrise,
                  themeController,
                  _prayerTimes!.currentPrayer() == Prayer.sunrise,
                ),
                _buildPrayerRow(
                  'الظهر',
                  _prayerTimes!.dhuhr,
                  themeController,
                  _prayerTimes!.currentPrayer() == Prayer.dhuhr,
                ),
                _buildPrayerRow(
                  'العصر',
                  _prayerTimes!.asr,
                  themeController,
                  _prayerTimes!.currentPrayer() == Prayer.asr,
                ),
                _buildPrayerRow(
                  'المغرب',
                  _prayerTimes!.maghrib,
                  themeController,
                  _prayerTimes!.currentPrayer() == Prayer.maghrib,
                ),
                _buildPrayerRow(
                  'العشاء',
                  _prayerTimes!.isha,
                  themeController,
                  _prayerTimes!.currentPrayer() == Prayer.isha,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    ThemeController themeController,
    ResponsiveHelper responsive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFFAC844D),
          ),
          const Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFAC844D)),
            onPressed: () {
              setState(() => _isLoading = true);
              _getPrayerTimes();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaButton(
    ThemeController themeController,
    ResponsiveHelper responsive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: InkWell(
        onTap: () => Get.to(() => const QiblaScreen()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFAC844D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFAC844D).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_rounded, color: Color(0xFFAC844D)),
              const SizedBox(width: 12),
              Text(
                'بوصلة القبلة',
                style: TextStyle(
                  color: themeController.getColor('text'),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(
    ThemeController themeController,
    ResponsiveHelper responsive,
  ) {
    final next = _prayerTimes!.nextPrayer();
    final bool isNone = next == Prayer.none;
    final displayPrayer = isNone ? Prayer.fajr : next;
    final displayTime = _prayerTimes!.timeForPrayer(displayPrayer);

    return FadeInDown(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFAC844D), Color(0xFFD4A76A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAC844D).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              isNone
                  ? 'صلاة الفجر غداً خلال'
                  : 'متبقي على صلاة ${_getPrayerNameArabic(next)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_timeToNextPrayer != Duration.zero)
              Text(
                _formatDuration(_timeToNextPrayer),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            const SizedBox(height: 8),
            if (displayTime != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  intl.DateFormat.jm('ar').format(displayTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Widget _buildPrayerRow(
    String name,
    DateTime time,
    ThemeController themeController,
    bool isCurrent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFFAC844D).withOpacity(0.1)
            : (themeController.isDarkMode.value
                  ? const Color(0xFF1E293B)
                  : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? const Color(0xFFAC844D) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          if (!isCurrent)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isCurrent)
                FadeIn(
                  child: const Icon(
                    Icons.center_focus_strong,
                    color: Color(0xFFAC844D),
                    size: 20,
                  ),
                ),
              if (isCurrent) const SizedBox(width: 8),
              Text(
                intl.DateFormat.jm('ar').format(time),
                style: TextStyle(
                  color: isCurrent
                      ? const Color(0xFFAC844D)
                      : themeController.getColor('text'),
                  fontSize: 18,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            name,
            style: TextStyle(
              color: isCurrent
                  ? const Color(0xFFAC844D)
                  : themeController.getColor('text'),
              fontSize: 18,
              fontFamily: 'Amiri',
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getPrayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return 'انتهت الصلوات';
    }
  }
}
