import 'package:flutter/material.dart';

/// MemoUp — dark-only design system.
///
/// Adapted from the worksheet's light palette: primary/secondary are
/// swapped (the light gray needs to be loudest on a near-black
/// background, where in light mode the dark gray was loudest on
/// off-white), and the error red is lightened from #E53935 to #FF7A70
/// so it clears 4.5:1 contrast against the dark card surface.

// ---- Raw palette ----
const Color kBackground = Color(0xFF1C1C1E); // new — dark analog of #F5F5F7
const Color kSurface = Color(0xFF3A3A3C); // was "primary" in light mode
const Color kPrimary = Color(0xFFD1D1D6); // was "secondary/accent" in light mode
const Color kOnPrimary = Color(0xFF212121);
const Color kOnSurface = Color(0xFFFFFFFF);
const Color kError = Color(0xFFFF7A70); // lightened from #E53935 for contrast
const Color kOnError = Color(0xFF212121);
const Color kMuted = Color(0xFF8A8A8C); // completed-item label, de-emphasized text

// ---- ColorScheme ----
const ColorScheme darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kPrimary,
  onPrimary: kOnPrimary,
  secondary: kSurface,
  onSecondary: kOnSurface,
  surface: kSurface,
  onSurface: kOnSurface,
  error: kError,
  onError: kOnError,
);

// ---- TextTheme ----
// Heading 20/Bold, Body 16/Regular, Caption 12/Regular-Light.
const TextTheme appTextTheme = TextTheme(
  headlineSmall: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: kOnSurface,
  ),
  bodyMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: kOnSurface,
  ),
  labelSmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: kPrimary, // lightened, not dimmed — a dark caption would vanish here
  ),
);

// ---- ThemeData ----
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkScheme,
  scaffoldBackgroundColor: kBackground,
  textTheme: appTextTheme,
  cardTheme: const CardThemeData(
    color: kSurface,
    margin: EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: kPrimary,
      foregroundColor: kOnPrimary,
      minimumSize: const Size.fromHeight(48),
      shape: const StadiumBorder(),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? kPrimary : Colors.transparent,
    ),
    checkColor: const WidgetStatePropertyAll(kOnPrimary),
    side: const BorderSide(color: kPrimary, width: 2),
  ),
);
