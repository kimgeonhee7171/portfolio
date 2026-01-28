import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/main/main_screen.dart';

void main() {
  runApp(const MyApp());
}

// 보증지킨이 앱 진입점
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '보증지킴이',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard',
      ),
      home: const MainScreen(),
    );
  }
}
