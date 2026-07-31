import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Semantic spacing aliases mapping to [AppConstants] spacing tokens.
class AppSpacing {
  AppSpacing._();

  static const double xs = AppConstants.space4;
  static const double sm = AppConstants.space8;
  static const double md = AppConstants.space16;
  static const double lg = AppConstants.space24;
  static const double xl = AppConstants.space32;

  static const EdgeInsets paddingMd = EdgeInsets.all(AppConstants.space16);
  static const EdgeInsets paddingLg = EdgeInsets.all(AppConstants.space24);

  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(AppConstants.radiusMedium),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(AppConstants.radiusLarge),
  );

  static const Widget gapSm = SizedBox(height: AppConstants.space8);
  static const Widget gapMd = SizedBox(height: AppConstants.space16);
  static const Widget gapLg = SizedBox(height: AppConstants.space24);
}

/// Semantic border radius aliases mapping to [AppConstants] radius tokens.
class AppRadius {
  AppRadius._();

  static const double sm = AppConstants.radiusSmall;
  static const double md = AppConstants.radiusMedium;
  static const double lg = AppConstants.radiusLarge;
  static const double full = AppConstants.radiusCircular;
}
