import 'package:flutter/material.dart';

/// Premium color palette for Zeni ride-hailing platform
/// Designed with Material Design 3 principles and premium aesthetic
class PremiumColors {
  PremiumColors._();

  // ========== LIGHT MODE COLORS ==========
  static class Light {
    // Primary: Sophisticated indigo gradient base
    static const Color primary = Color(0xFF6366F1); // Indigo-500
    static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
    static const Color primaryLight = Color(0xE8EAFF); // Indigo-50

    // Secondary: Rich teal accent
    static const Color secondary = Color(0xFF14B8A6); // Teal-500
    static const Color secondaryDark = Color(0xFF0D9488); // Teal-600
    static const Color secondaryLight = Color(0xF0FDFA); // Teal-50

    // Tertiary: Warm amber for highlights
    static const Color tertiary = Color(0xFFF59E0B); // Amber-500
    static const Color tertiaryDark = Color(0xFFD97706); // Amber-600
    static const Color tertiaryLight = Color(0xFFFEF3C7); // Amber-100

    // Neutral: Professional grays
    static const Color background = Color(0xFFFAFAFA); // Gray-50
    static const Color surface = Color(0xFFFFFFFF); // White
    static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray-100
    static const Color outline = Color(0xFFD1D5DB); // Gray-300
    static const Color outlineVariant = Color(0xFFE5E7EB); // Gray-200

    // Text: High contrast
    static const Color onPrimary = Color(0xFFFFFFFF); // White
    static const Color onSecondary = Color(0xFFFFFFFF); // White
    static const Color onBackground = Color(0xFF1F2937); // Gray-800
    static const Color onSurface = Color(0xFF1F2937); // Gray-800
    static const Color onSurfaceVariant = Color(0xFF6B7280); // Gray-500

    // Semantic colors
    static const Color success = Color(0xFF10B981); // Emerald-500
    static const Color warning = Color(0xFFF59E0B); // Amber-500
    static const Color error = Color(0xFFEF4444); // Red-500
    static const Color info = Color(0xFF3B82F6); // Blue-500

    // Grays for hierarchy
    static const Color textPrimary = Color(0xFF111827); // Gray-900
    static const Color textSecondary = Color(0xFF6B7280); // Gray-500
    static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
    static const Color textDisabled = Color(0xFFD1D5DB); // Gray-300

    // Divider
    static const Color divider = Color(0xFFE5E7EB); // Gray-200

    // Overlay
    static const Color overlay = Color(0x0D000000); // Black 5%
  }

  // ========== DARK MODE COLORS ==========
  static class Dark {
    // Primary: Bright indigo for visibility
    static const Color primary = Color(0xFF818CF8); // Indigo-400
    static const Color primaryDark = Color(0xFF6366F1); // Indigo-500
    static const Color primaryLight = Color(0xFF4F46E5); // Indigo-600

    // Secondary: Vibrant teal
    static const Color secondary = Color(0xFF2DD4BF); // Teal-400
    static const Color secondaryDark = Color(0xFF14B8A6); // Teal-500
    static const Color secondaryLight = Color(0xFF0D9488); // Teal-600

    // Tertiary: Bright amber
    static const Color tertiary = Color(0xFFFBBF24); // Amber-400
    static const Color tertiaryDark = Color(0xFFF59E0B); // Amber-500
    static const Color tertiaryLight = Color(0xFFD97706); // Amber-600

    // Neutral: Dark mode grays
    static const Color background = Color(0xFF0F172A); // Slate-900
    static const Color surface = Color(0xFF1E293B); // Slate-800
    static const Color surfaceVariant = Color(0xFF334155); // Slate-700
    static const Color outline = Color(0xFF475569); // Slate-600
    static const Color outlineVariant = Color(0xFF64748B); // Slate-500

    // Text: High contrast for dark
    static const Color onPrimary = Color(0xFF0F172A); // Slate-900
    static const Color onSecondary = Color(0xFF0F172A); // Slate-900
    static const Color onBackground = Color(0xFFF1F5F9); // Slate-100
    static const Color onSurface = Color(0xFFE2E8F0); // Slate-200
    static const Color onSurfaceVariant = Color(0xFFCBD5E1); // Slate-300

    // Semantic colors (adjusted for dark mode)
    static const Color success = Color(0xFF34D399); // Emerald-400
    static const Color warning = Color(0xFFFBBF24); // Amber-400
    static const Color error = Color(0xFFF87171); // Red-400
    static const Color info = Color(0xFF60A5FA); // Blue-400

    // Text hierarchy for dark
    static const Color textPrimary = Color(0xFFF8FAFC); // Slate-50
    static const Color textSecondary = Color(0xFFCBD5E1); // Slate-300
    static const Color textTertiary = Color(0xFF94A3B8); // Slate-400
    static const Color textDisabled = Color(0xFF64748B); // Slate-500

    // Divider
    static const Color divider = Color(0xFF334155); // Slate-700

    // Overlay
    static const Color overlay = Color(0x1AFFFFFF); // White 10%
  }

  // ========== PREMIUM GRADIENTS ==========
  static class Gradients {
    // Primary gradient
    static const gradient1 = LinearGradient(
      colors: [
        Color(0xFF818CF8), // Indigo-400
        Color(0xFF6366F1), // Indigo-500
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Secondary gradient (cool)
    static const gradient2 = LinearGradient(
      colors: [
        Color(0xFF2DD4BF), // Teal-400
        Color(0xFF14B8A6), // Teal-500
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Warning gradient
    static const gradient3 = LinearGradient(
      colors: [
        Color(0xFFFBBF24), // Amber-400
        Color(0xFFF59E0B), // Amber-500
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Premium dark gradient
    static const gradient4 = LinearGradient(
      colors: [
        Color(0xFF1E293B), // Slate-800
        Color(0xFF0F172A), // Slate-900
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ========== SHADOW DEFINITIONS ==========
  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowXL = BoxShadow(
    color: Color(0x19000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
}
