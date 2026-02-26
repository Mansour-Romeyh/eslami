import 'package:flutter/material.dart';

/// Helper class لإدارة التجاوب في التطبيق
class ResponsiveHelper {
  final BuildContext context;
  late final Size size;
  late final double width;
  late final double height;
  late final EdgeInsets padding;
  late final double devicePixelRatio;

  ResponsiveHelper(this.context) {
    final mediaQuery = MediaQuery.of(context);
    size = mediaQuery.size;
    width = size.width;
    height = size.height;
    padding = mediaQuery.padding;
    devicePixelRatio = mediaQuery.devicePixelRatio;
  }

  // === Screen Size Categories ===
  bool get isSmallScreen => width < 360;
  bool get isMediumScreen => width >= 360 && width < 420;
  bool get isLargeScreen => width >= 420 && width < 600;
  bool get isTablet => width >= 600;

  // === Spacing ===
  double get horizontalPadding {
    if (isSmallScreen) return 10;
    if (isMediumScreen) return 14;
    if (isLargeScreen) return 18;
    return 24;
  }

  double get verticalPadding {
    if (isSmallScreen) return 8;
    if (isMediumScreen) return 12;
    if (isLargeScreen) return 16;
    return 20;
  }

  double get cardMargin {
    if (isSmallScreen) return 8;
    if (isMediumScreen) return 10;
    return 14;
  }

  // === Font Sizes ===
  double get titleFontSize {
    if (isSmallScreen) return 16;
    if (isMediumScreen) return 18;
    if (isLargeScreen) return 20;
    return 24;
  }

  double get subtitleFontSize {
    if (isSmallScreen) return 12;
    if (isMediumScreen) return 14;
    if (isLargeScreen) return 16;
    return 18;
  }

  double get bodyFontSize {
    if (isSmallScreen) return 11;
    if (isMediumScreen) return 13;
    if (isLargeScreen) return 15;
    return 17;
  }

  double get captionFontSize {
    if (isSmallScreen) return 9;
    if (isMediumScreen) return 10;
    return 12;
  }

  // === Icon Sizes ===
  double get iconSizeSmall {
    if (isSmallScreen) return 16;
    if (isMediumScreen) return 18;
    return 22;
  }

  double get iconSizeMedium {
    if (isSmallScreen) return 20;
    if (isMediumScreen) return 24;
    return 28;
  }

  double get iconSizeLarge {
    if (isSmallScreen) return 26;
    if (isMediumScreen) return 32;
    return 40;
  }

  // === Button Sizes ===
  double get buttonHeight {
    if (isSmallScreen) return 42;
    if (isMediumScreen) return 48;
    return 54;
  }

  double get buttonPadding {
    if (isSmallScreen) return 10;
    if (isMediumScreen) return 14;
    return 18;
  }

  double get fabSize {
    if (isSmallScreen) return 48;
    if (isMediumScreen) return 54;
    return 60;
  }

  // === Border Radius ===
  double get smallRadius => isSmallScreen ? 8 : 12;
  double get mediumRadius => isSmallScreen ? 12 : 16;
  double get largeRadius => isSmallScreen ? 16 : 24;

  // === Container Sizes ===
  double get cardPadding {
    if (isSmallScreen) return 10;
    if (isMediumScreen) return 14;
    return 18;
  }

  double get bottomNavHeight {
    if (isSmallScreen) return 54;
    if (isMediumScreen) return 60;
    return 68;
  }

  // === Responsive value helper ===
  T responsive<T>({required T small, T? medium, T? large, T? tablet}) {
    if (isTablet && tablet != null) return tablet;
    if (isLargeScreen && large != null) return large;
    if (isMediumScreen && medium != null) return medium;
    return small;
  }

  // === Screen percentage helpers ===
  double widthPercent(double percent) => width * percent / 100;
  double heightPercent(double percent) => height * percent / 100;
}

/// Extension لسهولة الاستخدام في الـ Widgets
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}
