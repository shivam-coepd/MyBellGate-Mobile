import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

/// Defines the type of SnackBar to display, which determines its color and icon.
enum SnackBarType { success, error, warning, info, primary }

/// Defines the position of the SnackBar on screen.
enum SnackBarPosition { top, bottom, floating }

class AppSnackbar {
  /// Shows a customized SnackBar using ScaffoldMessenger.
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    SnackBarPosition position = SnackBarPosition.floating,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
    Color? closeButtonColor,
    Duration duration = const Duration(seconds: 4),
    Widget? customIcon,
    bool showProgressIndicator = false,
    bool slideAnimation = true,
  }) {
    final snackBar = _buildSnackBar(
      message: message,
      type: type,
      position: position,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
      closeButtonColor: closeButtonColor,
      duration: duration,
      customIcon: customIcon,
      showProgressIndicator: showProgressIndicator,
      slideAnimation: slideAnimation,
    );

    // Handle top-positioned SnackBars by inserting above content
    if (position == SnackBarPosition.top) {
      _showTopSnackBar(context, snackBar);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  /// Shows a SnackBar at the top of the screen using Overlay.
  static void _showTopSnackBar(BuildContext context, SnackBar snackBar) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 16.w,
        right: 16.w,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 0.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value * 100),
                child: Opacity(
                  opacity: value < 0 ? 1 + value : 1,
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < -5) {
                  overlayEntry.remove();
                }
              },
              child: snackBar.content,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(snackBar.duration).then((_) {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Builds the actual SnackBar widget.
  static SnackBar _buildSnackBar({
    required String message,
    required SnackBarType type,
    required SnackBarPosition position,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
    Color? closeButtonColor,
    required Duration duration,
    Widget? customIcon,
    required bool showProgressIndicator,
    required bool slideAnimation,
  }) {
    final typeConfig = _getTypeConfig(type);
    final closeColor = closeButtonColor ?? Colors.white70;

    final content = Builder(
      builder: (snackBarContext) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: typeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: typeConfig.backgroundColor.withValues(alpha: 0.3),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Icon Container
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child:
                              customIcon ??
                              Icon(
                                typeConfig.icon,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),

                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (actionLabel != null && onActionPressed != null) ...[
                    SizedBox(width: 8.w),
                    TextButton(
                      onPressed: () {
                        onActionPressed();
                        ScaffoldMessenger.of(
                          snackBarContext,
                        ).hideCurrentSnackBar();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        actionLabel.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],

                  if (showCloseButton) ...[
                    SizedBox(width: 4.w),
                    IconButton(
                      icon: Icon(Icons.close, size: 20.sp),
                      color: closeColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        ScaffoldMessenger.of(
                          snackBarContext,
                        ).hideCurrentSnackBar();
                      },
                    ),
                  ],
                ],
              ),

              // Optional Progress Indicator
              if (showProgressIndicator) ...[
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: duration,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 3.h,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );

    // Position-based margin configuration
    final EdgeInsets margin = switch (position) {
      SnackBarPosition.top => EdgeInsets.only(
        top:
            MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first,
            ).padding.top +
            8.h,
        left: 16.w,
        right: 16.w,
        bottom: 0,
      ),
      SnackBarPosition.bottom => EdgeInsets.only(
        bottom: 24.h,
        left: 16.w,
        right: 16.w,
      ),
      SnackBarPosition.floating => EdgeInsets.only(
        bottom: 24.h,
        left: 16.w,
        right: 16.w,
      ),
    };

    return SnackBar(
      content: content,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: position == SnackBarPosition.floating
          ? SnackBarBehavior.floating
          : SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      duration: duration,
      margin: position == SnackBarPosition.top ? null : margin,
      padding: EdgeInsets.zero,
      dismissDirection: position == SnackBarPosition.top
          ? DismissDirection.up
          : DismissDirection.horizontal,
    );
  }

  /// Helper to map SnackBarType to specific colors and icons.
  static _SnackBarTypeConfig _getTypeConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFFEF4444),
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFFF59E0B),
          icon: Icons.warning_amber_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarTypeConfig(
          backgroundColor: Color(0xFF3B82F6),
          icon: Icons.info_rounded,
        );
      case SnackBarType.primary:
        return _SnackBarTypeConfig(
          backgroundColor: AppTheme.primary,
          icon: Icons.info_rounded,
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
