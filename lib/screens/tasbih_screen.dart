import 'package:animate_do/animate_do.dart';
import 'package:eslami/screens/Theme%20controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eslami/widgets/responsive_helper.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({Key? key}) : super(key: key);

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _selectedDhikrIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _dhikrList = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'أَسْتَغْفِرُ اللَّهَ',
    'لا حول ولا قوة الا بالله',
    'اللهم صل وسلم على نبينا محمد',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter++;
    });
    _animationController
        .forward(from: 0)
        .then((_) => _animationController.reverse());
  }

  void _resetCounter() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة الضبط', textDirection: TextDirection.rtl),
        content: const Text(
          'هل تريد تصفير العداد؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _counter = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('تصفير', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeController.isDarkMode.value
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [
                    const Color(0xFF8BA09E),
                    const Color(0xFFA8B5A8),
                    const Color(0xFFCFC09E),
                    const Color(0xFFF3E5BB),
                  ],
            stops: themeController.isDarkMode.value
                ? [0.0, 1.0]
                : [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kBottomNavigationBarHeight -
                  (kToolbarHeight + 40), // Accounts for CustomAppBar
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spacer to push content below the CustomAppBar
                SizedBox(height: MediaQuery.of(context).padding.top + 5),
                const SizedBox(height: 20),
                // Horizontal Dhikr Selection
                FadeInDown(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    reverse: true, // For RTL feel
                    child: Row(
                      children: List.generate(_dhikrList.length, (index) {
                        final isSelected = _selectedDhikrIndex == index;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedDhikrIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(left: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFAC844D)
                                  : themeController.isDarkMode.value
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.1),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFAC844D,
                                        ).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _dhikrList[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : themeController.getColor('text'),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                                fontFamily: 'Amiri',
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInDown(
                  child: Text(
                    _dhikrList[_selectedDhikrIndex],
                    style: TextStyle(
                      fontSize: responsive.responsive<double>(
                        small: 28,
                        medium: 34,
                        large: 40,
                      ),
                      fontWeight: FontWeight.bold,
                      color: themeController.getColor('text'),
                      fontFamily: 'Amiri',
                    ),
                  ),
                ),
                SizedBox(
                  height: responsive.responsive<double>(
                    small: 20,
                    medium: 30,
                    large: 40,
                  ),
                ),
                GestureDetector(
                  onTap: _incrementCounter,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: responsive.responsive<double>(
                        small: 180,
                        medium: 230,
                        large: 280,
                      ),
                      height: responsive.responsive<double>(
                        small: 180,
                        medium: 230,
                        large: 280,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFAC844D), Color(0xFFD4A76A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (themeController.isDarkMode.value
                                        ? Colors.black
                                        : const Color(0xFFAC844D))
                                    .withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            themeController.isDarkMode.value ? 0.1 : 0.3,
                          ),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_counter',
                          style: TextStyle(
                            fontSize: responsive.responsive<double>(
                              small: 50,
                              medium: 60,
                              large: 70,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: responsive.responsive<double>(
                    small: 30,
                    medium: 40,
                    large: 50,
                  ),
                ),
                FadeInUp(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.refresh_rounded,
                        label: 'تصفير',
                        onTap: _resetCounter,
                        responsive: responsive,
                        themeController: themeController,
                      ),
                      const SizedBox(width: 30),
                      _buildActionButton(
                        icon: Icons.fingerprint_rounded,
                        label: 'تسبيح',
                        onTap: _incrementCounter,
                        responsive: responsive,
                        themeController: themeController,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ResponsiveHelper responsive,
    required ThemeController themeController,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPrimary
                  ? const Color(0xFFAC844D)
                  : themeController.isDarkMode.value
                  ? themeController.getColor('surface')
                  : Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isPrimary ? const Color(0xFFAC844D) : Colors.black)
                      .withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : themeController.getColor('text'),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeController.getColor('text'),
          ),
        ),
      ],
    );
  }
}
