import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/controllers/theme_controller.dart';
import 'package:news_app/utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables dari folder assets.
  await dotenv.load(fileName: 'assets/.env');

  // Initialize local storage
  await GetStorage.init();
  Get.put<ThemeController>(ThemeController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : Get.put(ThemeController(useStorage: false));
    return Obx(
      () => GetMaterialApp(
        title: 'News App',
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: themeController.themeMode,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: brightness,
      primary: isDark ? AppColors.accentLight : AppColors.primary,
      secondary: isDark ? AppColors.accentLight : AppColors.accent,
      surface: isDark ? const Color(0xFF172431) : AppColors.surface,
      error: AppColors.error,
    );
    return ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0D1720)
          : AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: isDark ? const Color(0xFFE7F0F5) : AppColors.textPrimary,
        displayColor: isDark ? const Color(0xFFE7F0F5) : AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF172431) : AppColors.surface,
        foregroundColor: isDark
            ? const Color(0xFFE7F0F5)
            : AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
