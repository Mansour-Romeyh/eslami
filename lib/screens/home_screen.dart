import 'package:eslami/screens/Theme%20controller.dart';
import 'package:eslami/widgets/custom_app_bar.dart';
import 'package:eslami/widgets/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'prayer_times_screen.dart';
import 'pdf_screen.dart';
import 'adhkar_screen.dart';
import 'tasbih_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _navAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _navAnimationController.forward(from: 0);
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: themeController.getColor('background'),
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          title: 'مختصر منهاج القاصدين',
          subtitle: 'للإمام ابن قُدامة المقدسي',
        ),
        drawer: _buildDrawer(responsive),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: [
            PrayerTimesScreen(),
            PDFScreen(),
            AdhkarScreen(),
            TasbihScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(responsive),
      ),
    );
  }

  Widget _buildBottomNav(ResponsiveHelper responsive) {
    final ThemeController themeController = Get.find<ThemeController>();
    final margin = responsive.widthPercent(5);
    final navWidth = responsive.width - (margin * 2);
    final navHeight = responsive.bottomNavHeight;

    return Obx(
      () => Container(
        margin: EdgeInsets.fromLTRB(
          margin,
          0,
          margin,
          responsive.isSmallScreen ? 8 : 12,
        ),
        height: navHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeController.isDarkMode.value
                ? [
                    const Color(0xFF2C2C2C),
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2C2C2C),
                  ]
                : [
                    const Color(0xFF8BA09E),
                    const Color(0xFFA8B5A8),
                    const Color(0xFFCFC09E),
                  ],
          ),
          borderRadius: BorderRadius.circular(responsive.largeRadius),
          boxShadow: [
            BoxShadow(
              color:
                  (themeController.isDarkMode.value
                          ? Colors.black
                          : const Color(0xFF8BA09E))
                      .withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(responsive.largeRadius),
          child: Stack(
            children: [
              // خلفية متحركة للتبويب النشط
              AnimatedBuilder(
                animation: _navAnimationController,
                builder: (context, child) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    right: _currentIndex == 0
                        ? 0
                        : (_currentIndex == 1
                              ? navWidth / 4
                              : (_currentIndex == 2
                                    ? (navWidth * 2) / 4
                                    : (navWidth * 3) / 4)),
                    width: navWidth / 4,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      margin: EdgeInsets.all(responsive.isSmallScreen ? 4 : 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          responsive.mediumRadius,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildNavItem(
                      Icons.access_time_filled_rounded,
                      'المواقيت',
                      0,
                      responsive,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      Icons.auto_stories_rounded,
                      'الكتاب',
                      1,
                      responsive,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      Icons.menu_book_rounded,
                      'الأذكار',
                      2,
                      responsive,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      Icons.fingerprint_rounded,
                      'سبحة',
                      3,
                      responsive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    ResponsiveHelper responsive,
  ) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabTapped(index),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(isActive ? 1.0 : 0.55),
                size: responsive.iconSizeMedium,
                shadows: isActive
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            SizedBox(height: responsive.isSmallScreen ? 2 : 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: Colors.white.withOpacity(isActive ? 1.0 : 0.55),
                fontSize: responsive.captionFontSize,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                shadows: isActive
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(ResponsiveHelper responsive) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Drawer(
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: themeController.isDarkMode.value
                  ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
                  : [const Color(0xFF8BA09E), const Color(0xFFF3E5BB)],
            ),
          ),
          child: Column(
            children: [
              _buildDrawerHeader(responsive, themeController),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildThemeToggle(themeController),
                    const Divider(
                      color: Colors.white24,
                      indent: 20,
                      endIndent: 20,
                    ),
                    _buildAboutSection(responsive, themeController),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'إصدار 1.0.0',
                  style: TextStyle(
                    color: themeController
                        .getColor('textSecondary')
                        .withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(
    ResponsiveHelper responsive,
    ThemeController themeController,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
      ),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
                image: AssetImage('aseets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'مختصر منهاج القاصدين',
            style: TextStyle(
              color: themeController.getColor('text'),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ThemeController themeController) {
    return ListTile(
      leading: Icon(
        themeController.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
        color: themeController.getColor('primary'),
      ),
      title: Text(
        'الوضع الليلي',
        style: TextStyle(color: themeController.getColor('text')),
        textDirection: TextDirection.rtl,
      ),
      trailing: Switch(
        value: themeController.isDarkMode.value,
        onChanged: (value) => themeController.toggleTheme(),
        activeColor: themeController.getColor('primary'),
      ),
    );
  }

  Widget _buildAboutSection(
    ResponsiveHelper responsive,
    ThemeController themeController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'عن التطبيق',
            style: TextStyle(
              color: themeController.getColor('primary'),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          _buildAboutItem(
            Icons.auto_stories_rounded,
            'كتاب PDF',
            'يحتوي التطبيق على نسخة رقمية من كتاب "مختصر منهاج القاصدين" مع ميزات البحث، التظليل، وإضافة الملاحظات.',
            themeController,
          ),
          _buildAboutItem(
            Icons.access_time_filled_rounded,
            'مواقيت الصلاة',
            'تحديد دقيق لمواعيد الصلاة بناءً على موقعك الجغرافي مع تنبيهات لكل صلاة.',
            themeController,
          ),

          _buildAboutItem(
            Icons.menu_book_rounded,
            'الأذكار اليومية',
            'موسوعة من الأذكار النبوية (الصباح والمساء) مع عداد تفاعلي لكل ذكر.',
            themeController,
          ),
          _buildAboutItem(
            Icons.fingerprint_rounded,
            'سبحة إلكترونية',
            'أداة تفاعلية تساعدك على ذكر الله والاستمرار في التسبيح اليومي.',
            themeController,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(
    IconData icon,
    String title,
    String description,
    ThemeController themeController,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeController.getColor('text'),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: themeController.getColor('textSecondary'),
                    fontSize: 12,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: themeController.getColor('primary'), size: 24),
        ],
      ),
    );
  }
}
