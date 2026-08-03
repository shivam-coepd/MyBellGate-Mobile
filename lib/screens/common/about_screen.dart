import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'contact@mygatebell.com',
      query: 'subject=MyGateBell App Inquiry',
    );
    if (await canLaunchUrl(uri)) launchUrl(uri);
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
        title: const Text('About MyGateBell'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // ── Logo & Brand ──────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    // borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      height: 80.w,
                      width: 80.w,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(
                        height: 80.w,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.home_work,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'MyGateBell',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Smart Society Management Platform',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Version 1.0.2',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Description ──────────────────────────────────────────────
            SizedBox(height: 24.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is MyGateBell?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'MyGateBell is a comprehensive society and community management platform '
                      'designed to simplify everyday living. From visitor management and security '
                      'alerts to billing, amenity bookings, and community engagement — everything '
                      'your society needs is in one app.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.6,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Key Features',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ..._featureItems(theme),
                  ],
                ),
              ),
            ),

            // ── Developer Info ────────────────────────────────────────────
            SizedBox(height: 16.h),
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
                      'Developed By',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.business,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COEPD Technologies',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Pune, Maharashtra, India',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Contact ───────────────────────────────────────────────────
            SizedBox(height: 16.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.email_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('contact@mygatebell.com'),
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: _launchEmail,
                  ),
                  Divider(
                    height: 0,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.language_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      'Website',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('www.mygatebell.com'),
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () => _launchUrl('https://www.mygatebell.com'),
                  ),
                  Divider(
                    height: 0,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      'Helpline',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('1800-123-456 (Toll Free)'),
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () => _launchUrl('tel:1800123456'),
                  ),
                ],
              ),
            ),

            // ── Social Links ─────────────────────────────────────────────
            SizedBox(height: 16.h),
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
                      'Follow Us',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _socialBtn(
                          theme,
                          Icons.facebook,
                          'Facebook',
                          () => _launchUrl('https://facebook.com/mygatebell'),
                        ),
                        _socialBtn(
                          theme,
                          Icons.camera_alt,
                          'Instagram',
                          () => _launchUrl('https://instagram.com/mygatebell'),
                        ),
                        _socialBtn(
                          theme,
                          Icons.smart_display,
                          'YouTube',
                          () => _launchUrl('https://youtube.com/@mygatebell'),
                        ),
                        _socialBtn(
                          theme,
                          Icons.alternate_email,
                          'Twitter',
                          () => _launchUrl('https://twitter.com/mygatebell'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Open Source ──────────────────────────────────────────────
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'MyGateBell',
                applicationVersion: '4.12.0',
                applicationIcon: Image.asset(
                  'assets/images/app_logo.png',
                  height: 48,
                  width: 48,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.home_work,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              icon: Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                'Open Source Licenses',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),

            SizedBox(height: 8.h),
            Text(
              '© ${DateTime.now().year} COEPD Technologies. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _featureItems(ThemeData theme) {
    final items = [
      {
        'icon': Icons.shield_outlined,
        'text': 'Secure visitor management with OTP & photo capture',
      },
      {
        'icon': Icons.notifications_active_outlined,
        'text': 'Real-time security alerts and emergency notifications',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'text': 'Automated billing, invoicing and online payments',
      },
      {
        'icon': Icons.sports_tennis_outlined,
        'text': 'Amenity booking and scheduling system',
      },
      {
        'icon': Icons.people_outline,
        'text': 'Community engagement with polls, events and announcements',
      },
      {
        'icon': Icons.build_outlined,
        'text': 'Service requests and helpdesk ticket management',
      },
      {
        'icon': Icons.family_restroom_outlined,
        'text':
            'Complete household management — family, vehicles, pets, daily help',
      },
      {
        'icon': Icons.qr_code_scanner,
        'text': 'QR-based quick entry for pre-approved visitors',
      },
    ];
    return items.map((item) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item['icon'] as IconData,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                item['text'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _socialBtn(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
