import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// A modern, trending full-screen Profile Image Viewer with:
/// - Frosted glassmorphism blurred backdrop
/// - Hero animation support for smooth expansion from avatar
/// - Interactive pinch-to-zoom (up to 5x) and pan
/// - Double-tap to zoom / reset zoom
/// - Vertical drag / swipe down to dismiss
/// - Floating frosted glass app bar with user info
/// - Network URL and local File image support with modern fallbacks
class ProfileImageViewer extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final String? title;
  final String? subtitle;
  final Object? heroTag;

  const ProfileImageViewer({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.title,
    this.subtitle,
    this.heroTag,
  });

  /// Static helper to display the viewer seamlessly across any screen
  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    File? imageFile,
    String? title,
    String? subtitle,
    Object? heroTag,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ProfileImageViewer(
              imageUrl: imageUrl,
              imageFile: imageFile,
              title: title,
              subtitle: subtitle,
              heroTag: heroTag,
            ),
          );
        },
      ),
    );
  }

  @override
  State<ProfileImageViewer> createState() => _ProfileImageViewerState();
}

class _ProfileImageViewerState extends State<ProfileImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _zoomAnimation;

  double _dragOffsetY = 0;
  bool _isDragging = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details) {
    if (_animController.isAnimating) return;

    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final Matrix4 endMatrix;

    if (currentScale > 1.2) {
      endMatrix = Matrix4.identity();
    } else {
      final position = details.localPosition;
      final zoomed = Matrix4.identity()
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        ..scale(2.5);
      endMatrix = zoomed;
    }

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward(from: 0);
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    // Only drag to dismiss when not zoomed in
    if (scale <= 1.05) {
      setState(() {
        _isDragging = true;
        _dragOffsetY += details.delta.dy;
      });
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    if (_dragOffsetY.abs() > 100 || details.primaryVelocity?.abs() != null && details.primaryVelocity!.abs() > 600) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffsetY = 0;
        _isDragging = false;
      });
    }
  }

  bool get _hasValidImage {
    if (widget.imageFile != null) return true;
    if (widget.imageUrl != null &&
        widget.imageUrl!.trim().isNotEmpty &&
        widget.imageUrl!.startsWith('http')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_dragOffsetY.abs() / 400)).clamp(0.2, 1.0);
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Frosted Glass Blurred Backdrop
            GestureDetector(
              onTap: () {
                setState(() => _showControls = !_showControls);
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.88 * opacity),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // Draggable & Zoomable Image Area
            Center(
              child: Transform.translate(
                offset: Offset(0, _dragOffsetY),
                child: GestureDetector(
                  onDoubleTapDown: _onDoubleTap,
                  onDoubleTap: () {},
                  onVerticalDragUpdate: _handleVerticalDragUpdate,
                  onVerticalDragEnd: _handleVerticalDragEnd,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.8,
                    maxScale: 5.0,
                    clipBehavior: Clip.none,
                    child: _buildImageContent(theme),
                  ),
                ),
              ),
            ),

            // Modern Floating Frosted Top Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _showControls ? 0 : -100.h,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      // Back/Close Button with Frosted Glass Look
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Material(
                            color: Colors.white.withOpacity(0.12),
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(30.r),
                              child: Container(
                                width: 42.w,
                                height: 42.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),

                      // User Info (Name & Subtitle)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.title != null && widget.title!.isNotEmpty)
                              Text(
                                widget.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: theme.primaryColor.withOpacity(0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Reset Zoom Button
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Material(
                            color: Colors.white.withOpacity(0.12),
                            child: InkWell(
                              onTap: () {
                                _zoomAnimation = Matrix4Tween(
                                  begin: _transformationController.value,
                                  end: Matrix4.identity(),
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animController,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                                _animController.forward(from: 0);
                              },
                              borderRadius: BorderRadius.circular(30.r),
                              child: Container(
                                width: 42.w,
                                height: 42.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.center_focus_strong_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Modern Bottom Hint Pill
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: _showControls ? 24.h : -60.h,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pinch_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Pinch to zoom • Swipe down to dismiss",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme) {
    Widget coreImage;

    if (widget.imageFile != null) {
      coreImage = Image.file(
        widget.imageFile!,
        fit: BoxFit.contain,
      );
    } else if (_hasValidImage) {
      coreImage = CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.3),
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackCard(theme),
      );
    } else {
      coreImage = _buildFallbackCard(theme);
    }

    final screenSize = MediaQuery.of(context).size;
    final imageWithContainer = Container(
      constraints: BoxConstraints(
        maxWidth: screenSize.width,
        maxHeight: screenSize.height * 0.85,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: coreImage,
      ),
    );

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: imageWithContainer,
      );
    }

    return imageWithContainer;
  }

  Widget _buildFallbackCard(ThemeData theme) {
    return Container(
      width: 280.w,
      height: 280.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 72.sp,
              color: theme.primaryColor.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            widget.title != null && widget.title!.isNotEmpty
                ? widget.title!
                : "Profile Photo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "No profile photo uploaded",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
