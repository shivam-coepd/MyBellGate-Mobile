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
      'https://play.google.com/store/apps/details?id=com.coepd.mygatebell';
  static const String _appStoreUrl =
      'https://apps.apple.com/app/mygatebell/id123456789';
  static const String _referralCode = 'MGB2026X';

  String get _shareText =>
      'Hey! I\'ve been using MyGateBell for my society management and it\'s amazing! 🏠\n\n'
      'It handles visitor entries, billing, amenities, security alerts and more — all in one app.\n\n'
      'Download it now: $_playStoreUrl\n\n'
      'Use my referral code: $_referralCode to get started!';

  void _shareApp() async {
    await Share.share(_shareText);
  }

  void _shareViaWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(_shareText)}',
    );
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareViaEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      query:
          'subject=Check out MyGateBell App&body=${Uri.encodeComponent(_shareText)}',
    );
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _shareViaSms() async {
    final uri = Uri(
      scheme: 'sms',
      query: 'body=${Uri.encodeComponent(_shareText)}',
    );
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _playStoreUrl));
    AppSnackbar.show(
      context: context,
      message: 'Link copied to clipboard!',
      type: SnackBarType.info,
    );
  }

  void _copyReferral(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _referralCode));
    AppSnackbar.show(
      context: context,
      message: 'Referral code copied!',
      type: SnackBarType.info,
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

            // ── Referral Code ────────────────────────────────────────────
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
                    Row(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Your Referral Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () => _copyReferral(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _referralCode,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.copy,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        'Tap to copy · Share with friends & earn rewards',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _shareBtn(
                          theme,
                          Icons.message,
                          'WhatsApp',
                          const Color(0xFF25D366),
                          _shareViaWhatsApp,
                        ),
                        _shareBtn(
                          theme,
                          Icons.email_outlined,
                          'Email',
                          theme.colorScheme.primary,
                          _shareViaEmail,
                        ),
                        _shareBtn(
                          theme,
                          Icons.sms_outlined,
                          'SMS',
                          Colors.orange,
                          _shareViaSms,
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
                onPressed: _shareApp,
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
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(_appStoreUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.apple, size: 18),
                    label: const Text('App Store'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
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
