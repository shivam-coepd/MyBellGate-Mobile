import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.mygatebell.app';
  // static const String _appStoreUrl =
  //     'https://apps.apple.com/app/mygatebell/id123456789';

  String get _shareText =>
      'Hey! I\'ve been using MyGateBell for my society management and it\'s amazing! 🏠\n\n'
      'It handles visitor entries, billing, amenities, security alerts and more — all in one app.\n\n'
      'Download it now: $_playStoreUrl\n\n';

  Future<void> _shareApp(BuildContext context) async {
    try {
      await Share.share(_shareText);
    } catch (_) {
      AppSnackbar.show(
        context: context,
        message: 'Unable to open sharing options. Please try again later.',
        type: SnackBarType.error,
      );
    }
  }

  Future<bool> _tryLaunchUrl(Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    final nativeUri = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(_shareText)}',
    );
    if (await _tryLaunchUrl(nativeUri, mode: LaunchMode.externalApplication)) {
      return;
    }

    final fallbackUri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(_shareText)}',
    );
    if (await _tryLaunchUrl(fallbackUri, mode: LaunchMode.externalApplication)) {
      return;
    }

    AppSnackbar.show(
      context: context,
      message: 'WhatsApp is unavailable. Opening general share options instead.',
      type: SnackBarType.warning,
    );
    await Share.share(_shareText, subject: 'Check out MyGateBell App');
  }

  Future<void> _shareViaEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'Check out MyGateBell App',
        'body': _shareText,
      },
    );
    if (await _tryLaunchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }

    AppSnackbar.show(
      context: context,
      message: 'No email client was found. Opening general share options instead.',
      type: SnackBarType.warning,
    );
    await Share.share(_shareText, subject: 'Check out MyGateBell App');
  }

  Future<void> _shareViaSms(BuildContext context) async {
    final uri = Uri(
      scheme: 'sms',
      queryParameters: {
        'body': _shareText,
      },
    );
    if (await _tryLaunchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }

    AppSnackbar.show(
      context: context,
      message: 'Unable to open SMS. Opening general share options instead.',
      type: SnackBarType.warning,
    );
    await Share.share(_shareText, subject: 'Check out MyGateBell App');
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _playStoreUrl));
    AppSnackbar.show(
      context: context,
      message: 'Link copied to clipboard!',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Share the App'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ── QR Code Card ──────────────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _playStoreUrl,
                        version: QrVersions.auto,
                        size: 180.w,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Scan to Download',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Point your camera at the QR code to download MyGateBell',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
 
            // ── Share Options ────────────────────────────────────────────
            SizedBox(height: 12.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Via',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _shareBtn(
                          theme,
                          Icons.message,
                          'WhatsApp',
                          const Color(0xFF25D366),
                          () => _shareViaWhatsApp(context),
                        ),
                        _shareBtn(
                          theme,
                          Icons.email_outlined,
                          'Email',
                          theme.colorScheme.primary,
                          () => _shareViaEmail(context),
                        ),
                        _shareBtn(
                          theme,
                          Icons.sms_outlined,
                          'SMS',
                          Colors.orange,
                          () => _shareViaSms(context),
                        ),
                        _shareBtn(
                          theme,
                          Icons.link,
                          'Copy Link',
                          Colors.purple,
                          () => _copyLink(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Big Share Button ─────────────────────────────────────────
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareApp(context),
                icon: const Icon(Icons.share, size: 20),
                label: const Text(
                  'Share MyGateBell',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            // ── Store Links ──────────────────────────────────────────────
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(_playStoreUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.android, size: 18),
                    label: const Text('Play Store'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                // SizedBox(width: 12.w),
                // Expanded(
                //   child: OutlinedButton.icon(
                //     onPressed: () => launchUrl(
                //       Uri.parse(_appStoreUrl),
                //       mode: LaunchMode.externalApplication,
                //     ),
                //     icon: const Icon(Icons.apple, size: 18),
                //     label: const Text('App Store'),
                //     style: OutlinedButton.styleFrom(
                //       padding: EdgeInsets.symmetric(vertical: 12.h),
                //     ),
                //   ),
                // ),
              ],
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _shareBtn(
    ThemeData theme,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
