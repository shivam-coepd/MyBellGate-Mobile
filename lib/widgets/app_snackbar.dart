import 'package:flutter/material.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

/// Defines the type of SnackBar to display, which determines its color and icon.
enum SnackBarType { success, error, warning, info, primary }

class AppSnackbar {
  /// Shows a customized SnackBar using ScaffoldMessenger.
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
    Color? closeButtonColor,
    Duration duration = const Duration(seconds: 4),
    Widget? customIcon,
  }) {
    final snackBar = _buildSnackBar(
      message: message,
      type: type,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
      closeButtonColor: closeButtonColor,
      duration: duration,
      customIcon: customIcon,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // Ensures only one SnackBar is shown at a time
      ..showSnackBar(snackBar);
  }

  /// Builds the actual SnackBar widget.
  static SnackBar _buildSnackBar({
    required String message,
    required SnackBarType type,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
    Color? closeButtonColor,
    required Duration duration,
    Widget? customIcon,
  }) {
    final typeConfig = _getTypeConfig(type);
    final closeColor = closeButtonColor ?? Colors.white70;

    // ✅ FIX: Wrap the content in a Builder to get a safe, guaranteed context
    final content = Builder(
      builder: (snackBarContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: typeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: typeConfig.backgroundColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              customIcon ??
                  Icon(typeConfig.icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    onActionPressed();
                    // ✅ Use the safe snackBarContext here
                    ScaffoldMessenger.of(snackBarContext).hideCurrentSnackBar();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    actionLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],

              if (showCloseButton) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: closeColor,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // ✅ Use the safe snackBarContext here
                    ScaffoldMessenger.of(snackBarContext).hideCurrentSnackBar();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );

    return SnackBar(
      content: content,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Helper to map SnackBarType to specific colors and icons.
  static _SnackBarTypeConfig _getTypeConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFF10B981), // Modern Emerald Green
          icon: Icons.check_circle,
        );
      case SnackBarType.error:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFFEF4444), // Modern Red
          icon: Icons.error,
        );
      case SnackBarType.warning:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFFF59E0B), // Modern Amber
          icon: Icons.warning_amber_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFF3B82F6), // Modern Blue
          icon: Icons.info,
        );
      case SnackBarType.primary:
        return _SnackBarTypeConfig(
          backgroundColor: AppTheme.primary, // Modern Blue
          icon: Icons.info,
        );
    }
  }
}

/// Internal data class to hold type-specific configurations.
class _SnackBarTypeConfig {
  final Color backgroundColor;
  final IconData icon;

  const _SnackBarTypeConfig({
    required this.backgroundColor,
    required this.icon,
  });
}
