import "package:flutter/material.dart";

class NHVMaterialTheme {
  final TextTheme textTheme;

  const NHVMaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff904a45),
      surfaceTint: Color(0xff904a45),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdad6),
      onPrimaryContainer: Color(0xff3b0908),
      secondary: Color(0xff8c4a60),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffd9e2),
      onSecondaryContainer: Color(0xff3a071d),
      tertiary: Color(0xff006874),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9eeffd),
      onTertiaryContainer: Color(0xff001f24),
      error: Color(0xff904a45),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff3b0908),
      background: Color(0xfffff8f7),
      onBackground: Color(0xff231918),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff231918),
      surfaceVariant: Color(0xfff5dddb),
      onSurfaceVariant: Color(0xff534342),
      outline: Color(0xff857371),
      outlineVariant: Color(0xffd8c2bf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2d),
      inverseOnSurface: Color(0xffffedeb),
      inversePrimary: Color(0xffffb3ad),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff3b0908),
      primaryFixedDim: Color(0xffffb3ad),
      onPrimaryFixedVariant: Color(0xff73332f),
      secondaryFixed: Color(0xffffd9e2),
      onSecondaryFixed: Color(0xff3a071d),
      secondaryFixedDim: Color(0xffffb1c8),
      onSecondaryFixedVariant: Color(0xff703348),
      tertiaryFixed: Color(0xff9eeffd),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xff82d3e0),
      onTertiaryFixedVariant: Color(0xff004f58),
      surfaceDim: Color(0xffe8d6d4),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffceae8),
      surfaceContainerHigh: Color(0xfff6e4e2),
      surfaceContainerHighest: Color(0xfff1dedc),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff6e302c),
      surfaceTint: Color(0xff904a45),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffaa5f5a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff6b2f44),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa55f76),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff004a53),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff25808c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff6e302c),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffaa5f5a),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffff8f7),
      onBackground: Color(0xff231918),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff231918),
      surfaceVariant: Color(0xfff5dddb),
      onSurfaceVariant: Color(0xff4e3f3e),
      outline: Color(0xff6c5b59),
      outlineVariant: Color(0xff897675),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2d),
      inverseOnSurface: Color(0xffffedeb),
      inversePrimary: Color(0xffffb3ad),
      primaryFixed: Color(0xffaa5f5a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff8d4843),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffa55f76),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff89475e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff25808c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff006671),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe8d6d4),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffceae8),
      surfaceContainerHigh: Color(0xfff6e4e2),
      surfaceContainerHighest: Color(0xfff1dedc),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff44100e),
      surfaceTint: Color(0xff904a45),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6e302c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff420e24),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6b2f44),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00272c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff004a53),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff44100e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff6e302c),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffff8f7),
      onBackground: Color(0xff231918),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff000000),
      surfaceVariant: Color(0xfff5dddb),
      onSurfaceVariant: Color(0xff2e2120),
      outline: Color(0xff4e3f3e),
      outlineVariant: Color(0xff4e3f3e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2d),
      inverseOnSurface: Color(0xffffffff),
      inversePrimary: Color(0xffffe7e4),
      primaryFixed: Color(0xff6e302c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff521a17),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6b2f44),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff50192e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff004a53),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003238),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe8d6d4),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffceae8),
      surfaceContainerHigh: Color(0xfff6e4e2),
      surfaceContainerHighest: Color(0xfff1dedc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb3ad),
      surfaceTint: Color(0xffffb3ad),
      onPrimary: Color(0xff571e1b),
      primaryContainer: Color(0xff73332f),
      onPrimaryContainer: Color(0xffffdad6),
      secondary: Color(0xffffb1c8),
      onSecondary: Color(0xff541d32),
      secondaryContainer: Color(0xff703348),
      onSecondaryContainer: Color(0xffffd9e2),
      tertiary: Color(0xff82d3e0),
      onTertiary: Color(0xff00363d),
      tertiaryContainer: Color(0xff004f58),
      onTertiaryContainer: Color(0xff9eeffd),
      error: Color(0xffffb3ad),
      onError: Color(0xff571e1b),
      errorContainer: Color(0xff73332f),
      onErrorContainer: Color(0xffffdad6),
      background: Color(0xff1a1110),
      onBackground: Color(0xfff1dedc),
      surface: Color(0xff1a1110),
      onSurface: Color(0xfff1dedc),
      surfaceVariant: Color(0xff534342),
      onSurfaceVariant: Color(0xffd8c2bf),
      outline: Color(0xffa08c8a),
      outlineVariant: Color(0xff534342),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedc),
      inverseOnSurface: Color(0xff392e2d),
      inversePrimary: Color(0xff904a45),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff3b0908),
      primaryFixedDim: Color(0xffffb3ad),
      onPrimaryFixedVariant: Color(0xff73332f),
      secondaryFixed: Color(0xffffd9e2),
      onSecondaryFixed: Color(0xff3a071d),
      secondaryFixedDim: Color(0xffffb1c8),
      onSecondaryFixedVariant: Color(0xff703348),
      tertiaryFixed: Color(0xff9eeffd),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xff82d3e0),
      onTertiaryFixedVariant: Color(0xff004f58),
      surfaceDim: Color(0xff1a1110),
      surfaceBright: Color(0xff423735),
      surfaceContainerLowest: Color(0xff140c0b),
      surfaceContainerLow: Color(0xff231918),
      surfaceContainer: Color(0xff271d1c),
      surfaceContainerHigh: Color(0xff322827),
      surfaceContainerHighest: Color(0xff3d3231),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb9b3),
      surfaceTint: Color(0xffffb3ad),
      onPrimary: Color(0xff330405),
      primaryContainer: Color(0xffcc7b74),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffb7cc),
      onSecondary: Color(0xff330218),
      secondaryContainer: Color(0xffc67b92),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff86d7e5),
      onTertiary: Color(0xff001a1d),
      tertiaryContainer: Color(0xff499ca9),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffb9b3),
      onError: Color(0xff330405),
      errorContainer: Color(0xffcc7b74),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff1a1110),
      onBackground: Color(0xfff1dedc),
      surface: Color(0xff1a1110),
      onSurface: Color(0xfffff9f9),
      surfaceVariant: Color(0xff534342),
      onSurfaceVariant: Color(0xffdcc6c3),
      outline: Color(0xffb39e9c),
      outlineVariant: Color(0xff927f7d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedc),
      inverseOnSurface: Color(0xff322827),
      inversePrimary: Color(0xff743430),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff2c0102),
      primaryFixedDim: Color(0xffffb3ad),
      onPrimaryFixedVariant: Color(0xff5e2320),
      secondaryFixed: Color(0xffffd9e2),
      onSecondaryFixed: Color(0xff2b0012),
      secondaryFixedDim: Color(0xffffb1c8),
      onSecondaryFixedVariant: Color(0xff5b2238),
      tertiaryFixed: Color(0xff9eeffd),
      onTertiaryFixed: Color(0xff001417),
      tertiaryFixedDim: Color(0xff82d3e0),
      onTertiaryFixedVariant: Color(0xff003c44),
      surfaceDim: Color(0xff1a1110),
      surfaceBright: Color(0xff423735),
      surfaceContainerLowest: Color(0xff140c0b),
      surfaceContainerLow: Color(0xff231918),
      surfaceContainer: Color(0xff271d1c),
      surfaceContainerHigh: Color(0xff322827),
      surfaceContainerHighest: Color(0xff3d3231),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff9f9),
      surfaceTint: Color(0xffffb3ad),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffb9b3),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffff9f9),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffb7cc),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff1fdff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff86d7e5),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffb9b3),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff1a1110),
      onBackground: Color(0xfff1dedc),
      surface: Color(0xff1a1110),
      onSurface: Color(0xffffffff),
      surfaceVariant: Color(0xff534342),
      onSurfaceVariant: Color(0xfffff9f9),
      outline: Color(0xffdcc6c3),
      outlineVariant: Color(0xffdcc6c3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedc),
      inverseOnSurface: Color(0xff000000),
      inversePrimary: Color(0xff4e1715),
      primaryFixed: Color(0xffffe0dd),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb9b3),
      onPrimaryFixedVariant: Color(0xff330405),
      secondaryFixed: Color(0xffffdfe6),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb7cc),
      onSecondaryFixedVariant: Color(0xff330218),
      tertiaryFixed: Color(0xffaaf3ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff86d7e5),
      onTertiaryFixedVariant: Color(0xff001a1d),
      surfaceDim: Color(0xff1a1110),
      surfaceBright: Color(0xff423735),
      surfaceContainerLowest: Color(0xff140c0b),
      surfaceContainerLow: Color(0xff231918),
      surfaceContainer: Color(0xff271d1c),
      surfaceContainerHigh: Color(0xff322827),
      surfaceContainerHighest: Color(0xff3d3231),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      primaryFixed: primaryFixed,
      primaryFixedDim: primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      secondaryFixed: secondaryFixed,
      secondaryFixedDim: secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed,
      onSecondaryFixedVariant: onSecondaryFixedVariant,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      tertiaryFixed: tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed,
      onTertiaryFixedVariant: onTertiaryFixedVariant,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
