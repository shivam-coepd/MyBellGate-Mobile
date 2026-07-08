import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = _buildSections();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: Column(
        children: [
          // Header notice
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Privacy Matters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'We are committed to protecting your personal information and being transparent about how we use it.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Last updated
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.update,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Last updated: January 15, 2026',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: sections.length,
              itemBuilder: (ctx, i) =>
                  _sectionCard(theme, '${i + 1}', sections[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(ThemeData theme, String number, _Section section) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    section.icon,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '$number of $_totalSections',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...section.paragraphs.map(
              (p) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.65,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (section.bullets.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.05,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: section.bullets
                      .map(
                        (b) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  b,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const String _totalSections = '10';

  List<_Section> _buildSections() {
    return [
      _Section(
        icon: Icons.info_outline,
        title: 'Information We Collect',
        paragraphs: [
          'We collect information you provide directly to us when you register, use our services, or communicate with us. This includes:',
        ],
        bullets: [
          'Personal details: Name, email, phone number, profile photo',
          'Residential details: Society name, building, flat number, ownership type',
          'Household data: Family members, vehicles, pets, domestic help',
          'Device information: Device ID, OS version, IP address, app usage data',
          'Visitor data: Photos, phone numbers, and vehicle details captured at gate entry',
        ],
      ),
      _Section(
        icon: Icons.settings_outlined,
        title: 'How We Use Your Information',
        paragraphs: [
          'We use the collected information to provide, maintain, and improve our services. Specifically, we use your data to:',
        ],
        bullets: [
          'Verify your identity and provide secure access to your account',
          'Process visitor entries and send approval notifications',
          'Generate and process society maintenance invoices and payments',
          'Send security alerts, emergency notifications, and community updates',
          'Facilitate amenity bookings and service request management',
          'Improve our app performance, fix bugs, and develop new features',
          'Comply with legal obligations and enforce our terms of service',
        ],
      ),
      _Section(
        icon: Icons.share_outlined,
        title: 'Information Sharing',
        paragraphs: [
          'We do not sell your personal data to third parties. We share information only in the following circumstances:',
        ],
        bullets: [
          'With your society administrators for verification and management purposes',
          'With security guards at the gate for visitor entry processing',
          'With payment processors to facilitate transactions',
          'With law enforcement when required by law or to protect safety',
          'With service providers who help us operate our platform (under strict confidentiality agreements)',
        ],
      ),
      _Section(
        icon: Icons.storage_outlined,
        title: 'Data Storage & Security',
        paragraphs: [
          'Your data is stored on secure servers hosted in India. We implement industry-standard security measures to protect your information, including:',
        ],
        bullets: [
          'End-to-end encryption for sensitive data in transit (TLS 1.3)',
          'AES-256 encryption for data at rest',
          'Regular security audits and penetration testing',
          'Role-based access controls for society data',
          'Secure authentication with JWT tokens and optional biometric login',
        ],
      ),
      _Section(
        icon: Icons.timer_outlined,
        title: 'Data Retention',
        paragraphs: [
          'We retain your personal data for as long as your account is active or as needed to provide you services. Visitor entry logs are retained for a maximum of 12 months for security purposes.',
          'When you delete your account, your personal data is permanently deleted within 90 days, except where we are required to retain it for legal or regulatory compliance.',
        ],
        bullets: [],
      ),
      _Section(
        icon: Icons.person_outline,
        title: 'Your Rights & Choices',
        paragraphs: [
          'You have the following rights regarding your personal data:',
        ],
        bullets: [
          'Access: Request a copy of all personal data we hold about you',
          'Correction: Update or correct inaccurate personal information',
          'Deletion: Request deletion of your account and associated data',
          'Portability: Export your data in a machine-readable format',
          'Opt-out: Control which notifications you receive and how your data is used',
          'Consent withdrawal: Withdraw consent for optional data processing at any time',
        ],
      ),
      _Section(
        icon: Icons.child_care_outlined,
        title: "Children's Privacy",
        paragraphs: [
          'MyGateBell is not intended for use by children under the age of 13. We do not knowingly collect personal information from children. If we discover that a child has provided us with personal data, we will delete it immediately.',
          'Parents or guardians who register family members under 13 do so at their own discretion and are responsible for managing their minor children\'s data.',
        ],
        bullets: [],
      ),
      _Section(
        icon: Icons.link_outlined,
        title: 'Third-Party Links & Services',
        paragraphs: [
          'Our app may contain links to third-party websites or services (such as payment gateways). We are not responsible for the privacy practices of these external services. We encourage you to read their privacy policies before providing any personal information.',
        ],
        bullets: [],
      ),
      _Section(
        icon: Icons.notifications_outlined,
        title: 'Push Notifications & Communications',
        paragraphs: [
          'By using MyGateBell, you agree to receive push notifications, SMS, and emails related to security alerts, visitor entries, billing reminders, and society announcements.',
          'You can manage your notification preferences at any time from the app\'s Notification Settings screen. Critical security alerts cannot be disabled as they are essential for community safety.',
        ],
        bullets: [],
      ),
      _Section(
        icon: Icons.contact_mail_outlined,
        title: 'Contact Us',
        paragraphs: [
          'If you have questions or concerns about this Privacy Policy or your data, please reach out to us:',
          'Email: privacy@mygatebell.com',
          'Data Protection Officer: dpo@mygatebell.com',
          'Address: COEPD Technologies, Pune, Maharashtra, India',
        ],
        bullets: [],
      ),
    ];
  }
}

class _Section {
  final IconData icon;
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  _Section({
    required this.icon,
    required this.title,
    required this.paragraphs,
    this.bullets = const [],
  });
}
