import 'package:eslami/screens/Theme%20controller.dart';
import 'package:eslami/widgets/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize {
    // Include the status-bar height so the container is always tall enough.
    final double topPadding =
        WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return Size.fromHeight(kToolbarHeight + 40 + topPadding);
  }
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _particlesController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _particlesController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final double topPadding = MediaQuery.of(context).padding.top;

    final double responsiveLogoSize = responsive.responsive<double>(
      small: 40,
      medium: 46,
      large: 52,
    );
    final double responsiveTitleSize = responsive.responsive<double>(
      small: 15,
      medium: 17,
      large: 19,
    );
    final double responsiveSubtitleSize = responsive.responsive<double>(
      small: 10,
      medium: 11,
      large: 12,
    );

    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Container(
        padding: EdgeInsets.only(
          top: topPadding,
          left: responsive.horizontalPadding,
          right: responsive.horizontalPadding,
        ),
        height: widget.preferredSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeController.isDarkMode.value
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                    const Color(0xFF1A1A1A),
                  ]
                : [
                    const Color(0xFF8BA09E),
                    const Color(0xFFA8B5A8),
                    const Color(0xFFCFC09E),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (themeController.isDarkMode.value
                          ? Colors.black
                          : const Color(0xFFAC844D))
                      .withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // عناصر زخرفية متحركة في الخلفية
            ...List.generate(3, (index) {
              return Positioned(
                right: (index * 100.0) - 15,
                top: -8 + (index * 5),
                child: AnimatedBuilder(
                  animation: _particlesController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle:
                          _particlesController.value *
                          2 *
                          math.pi *
                          (index.isEven ? 1 : -1),
                      child: Opacity(
                        opacity: 0.05 + (index * 0.02),
                        child: Icon(
                          index == 0
                              ? Icons.auto_stories_outlined
                              : index == 1
                              ? Icons.star_outline_rounded
                              : Icons.mosque_outlined,
                          size: responsive.responsive<double>(
                            small: 28,
                            medium: 32,
                            large: 38,
                          ),
                          color: themeController.isDarkMode.value
                              ? Colors.white.withOpacity(0.1)
                              : const Color(0xFFAC844D).withOpacity(0.1),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // المحتوى الرئيسي
            Row(
              children: [
                if (widget.showBackButton)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        responsive.smallRadius,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF4A3F35),
                        size: responsive.iconSizeSmall,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 24,
                    ),
                  ),
                if (!widget.showBackButton)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        responsive.smallRadius,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        color: const Color(0xFF4A3F35),
                        size: responsive.iconSizeMedium,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      splashRadius: 24,
                    ),
                  ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // العنوان الرئيسي
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: responsiveTitleSize,
                                fontWeight: FontWeight.w800,
                                color: themeController.isDarkMode.value
                                    ? Colors.white70
                                    : const Color(0xFF4A3F35),
                                height: 1.15,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: themeController.isDarkMode.value
                                        ? Colors.black26
                                        : Colors.white.withOpacity(0.4),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              textDirection: TextDirection.rtl,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: responsive.isSmallScreen ? 2 : 4),
                            // العنوان الفرعي
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.responsive<double>(
                                  small: 6,
                                  medium: 8,
                                  large: 10,
                                ),
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  responsive.smallRadius - 4,
                                ),
                              ),
                              child: Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: responsiveSubtitleSize,
                                  color: themeController.isDarkMode.value
                                      ? Colors.white60
                                      : const Color(0xFF5A5046),
                                  fontWeight: FontWeight.w600,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: responsive.horizontalPadding),
                      _buildAppLogo(
                        responsiveLogoSize,
                        responsive,
                        themeController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo(
    double size,
    ResponsiveHelper responsive,
    ThemeController themeController,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _headerAnimationController,
        _glowController,
      ]),
      builder: (context, child) {
        final glowIntensity = 0.2 + (_glowController.value * 0.15);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: responsive.isSmallScreen ? 1.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (themeController.isDarkMode.value
                            ? Colors.white54
                            : const Color(0xFFAC844D))
                        .withOpacity(glowIntensity),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'aseets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFAC844D).withOpacity(0.3),
                        const Color(0xFFCFC09E).withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: const Color(0xFF4A3F35),
                    size: size * 0.5,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
