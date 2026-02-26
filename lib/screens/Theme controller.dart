import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // حالة الوضع الليلي
  RxBool isDarkMode = false.obs;

  // ألوان الوضع النهاري
  final lightColors = {
    'background': const Color(0xFFF3E5BB),
    'surface': const Color(0xFFFFFFFF),
    'primary': const Color(0xFFAC844D),
    'text': const Color(0xFF4A3F35),
    'textSecondary': const Color(0xFF797E79),
    'cardBackground': const Color(0xFFFFFFFF),
    'divider': const Color(0xFFE0E0E0),
  };

  // ألوان الوضع الليلي
  final darkColors = {
    'background': const Color(0xFF121212),
    'surface': const Color(0xFF1E1E1E),
    'primary': const Color(0xFFAC844D),
    'text': const Color(0xFFE5E5E5),
    'textSecondary': const Color(0xFF9E9E9E),
    'cardBackground': const Color(0xFF2C2C2C),
    'divider': const Color(0xFF333333),
  };

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  // تحميل الإعداد المحفوظ
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
  }

  // تبديل الوضع
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);

    // تطبيق الثيم فوراً
    Get.changeTheme(isDarkMode.value ? darkTheme : lightTheme);
  }

  // الحصول على اللون حسب الوضع
  Color getColor(String colorName) {
    if (isDarkMode.value) {
      return darkColors[colorName] ?? Colors.white;
    } else {
      return lightColors[colorName] ?? Colors.black;
    }
  }

  // تعريف ThemeData للوضع النهاري
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFFAC844D),
      scaffoldBackgroundColor: const Color(0xFFF3E5BB),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFAC844D),
        primary: const Color(0xFFAC844D),
        surface: Colors.white,
        background: const Color(0xFFF3E5BB),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  // تعريف ThemeData للوضع الليلي
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFAC844D),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF333333),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFAC844D),
        primary: const Color(0xFFAC844D),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  // الحصول على لون الـ PDF Viewer
  Color get pdfBackgroundColor {
    return isDarkMode.value ? const Color(0xFF1A1A1A) : Colors.white;
  }

  Color get pdfPageColor {
    return isDarkMode.value ? const Color(0xFF2D2D2D) : Colors.white;
  }
}
