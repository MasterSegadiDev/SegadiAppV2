import 'package:flutter/material.dart';
import 'package:segadi/presentation/design_system/theme/app_colors.dart';
import 'package:segadi/presentation/design_system/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        bodyMedium: AppTextStyles.body,
      ),
    );
  }
}
