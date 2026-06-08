import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
        title: const Text('Terms & Conditions'),
      ),
      body: Column(
        children: [
          // Table of contents
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt_outlined, size: 18, color: theme.colorScheme.primary),
                    SizedBox(width: 8.w),
                    Text('Table of Contents',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  ],
                ),
                SizedBox(height: 8.h),
                ...sections.asMap().entries.map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    '${e.key + 1}. ${e.value.title}',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                  ),
                )),
              ],
            ),
          ),

          // Last updated
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.update, size: 14, color: theme.colorScheme.onSurfaceVariant),
                SizedBox(width: 6.w),
                Text(
                  'Last updated: January 15, 2026',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Content
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: sections.length,
              itemBuilder: (ctx, i) => _sectionCard(theme, '${i + 1}', sections[i]),
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
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    number,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...section.paragraphs.map((p) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                p,
                style: TextStyle(fontSize: 13.5, height: 1.65, color: theme.colorScheme.onSurfaceVariant),
              ),
            )),
            if (section.bullets.isNotEmpty) ...[
              SizedBox(height: 4.h),
              ...section.bullets.map((b) => Padding(
                padding: EdgeInsets.only(bottom: 6.h, left: 8.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(b, style: TextStyle(fontSize: 13.5, height: 1.6, color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  List<_Section> _buildSections() {
    return [
      _Section(
        title: 'Acceptance of Terms',
        paragraphs: [
          'By downloading, installing, or using the MyGateBell application ("Service"), you agree to be bound by these Terms & Conditions ("Terms"). If you do not agree to these Terms, do not use the Service.',
          'These Terms apply to all users of the app, including residents, society administrators, security guards, and any other parties who access or use the Service.',
        ],
        bullets: [],
      ),
      _Section(
        title: 'Description of Service',
        paragraphs: [
          'MyGateBell is a society management platform that provides tools and features for residential communities to manage their daily operations, including but not limited to:',
        ],
        bullets: [
          'Visitor management and gate security',
          'Household member and vehicle registration',
          'Billing, invoicing, and payment processing',
          'Amenity booking and community announcements',
          'Service requests and helpdesk management',
          'Security alerts and emergency notifications',
        ],
      ),
      _Section(
        title: 'User Accounts & Registration',
        paragraphs: [
          'You must register with accurate and complete information. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
          'You must be a legitimate resident, authorized society administrator, or assigned security personnel of a registered society to use this Service.',
        ],
        bullets: [
          'You must provide a valid phone number and email address',
          'Society admin verification may be required for full access',
          'You may not create multiple accounts or share credentials',
          'We reserve the right to suspend accounts that violate these Terms',
        ],
      ),
      _Section(
        title: 'Acceptable Use',
        paragraphs: [
          'You agree not to use the Service for any unlawful purpose or in any way that could damage, disable, or impair the Service. Specifically, you agree not to:',
        ],
        bullets: [
          'Submit false or misleading visitor information',
          'Harass, threaten, or abuse other users through the platform',
          'Attempt to gain unauthorized access to other accounts or systems',
          'Reverse engineer, decompile, or disassemble the application',
          'Use automated tools, bots, or scrapers to access the Service',
          'Upload malicious content, spam, or inappropriate material',
        ],
      ),
      _Section(
        title: 'Payments & Billing',
        paragraphs: [
          'Society maintenance fees and other charges may be invoiced through the platform. All payments processed through MyGateBell are subject to the payment processor\'s terms.',
          'Refunds for payments made through the platform must be requested through your society administrator. MyGateBell acts as a facilitator and is not responsible for refund processing.',
        ],
        bullets: [
          'All fees are charged in Indian Rupees (INR) unless otherwise stated',
          'Payment confirmations are sent via push notification and email',
          'Transaction records are stored digitally and accessible within the app',
        ],
      ),
      _Section(
        title: 'Data Collection & Privacy',
        paragraphs: [
          'We collect and process personal data in accordance with our Privacy Policy. By using the Service, you consent to the collection, storage, and processing of your data as described in our Privacy Policy.',
          'Visitor data including photos, phone numbers, and vehicle details collected during gate entry is stored securely and used solely for security purposes.',
        ],
        bullets: [],
      ),
      _Section(
        title: 'Intellectual Property',
        paragraphs: [
          'All content, logos, graphics, and software associated with MyGateBell are the intellectual property of COEPD Technologies and are protected by applicable copyright, trademark, and other intellectual property laws.',
          'You may not reproduce, distribute, or create derivative works from our content without explicit written permission.',
        ],
        bullets: [],
      ),
      _Section(
        title: 'Limitation of Liability',
        paragraphs: [
          'MyGateBell is provided on an "as is" basis without warranties of any kind. We do not guarantee that the Service will be uninterrupted, secure, or error-free.',
          'To the maximum extent permitted by law, COEPD Technologies shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the Service.',
        ],
        bullets: [],
      ),
      _Section(
        title: 'Termination',
        paragraphs: [
          'We reserve the right to suspend or terminate your access to the Service at any time for violations of these Terms. You may also terminate your account at any time through the app settings or by contacting support.',
          'Upon termination, your data may be retained for up to 90 days for legal and administrative purposes before permanent deletion.',
        ],
        bullets: [],
      ),
      _Section(
        title: 'Changes to Terms',
        paragraphs: [
          'We may update these Terms from time to time. We will notify you of significant changes via in-app notification or email. Your continued use of the Service after such changes constitutes acceptance of the updated Terms.',
        ],
        bullets: [],
      ),
      _Section(
        title: 'Governing Law',
        paragraphs: [
          'These Terms are governed by the laws of India. Any disputes arising from these Terms or use of the Service shall be subject to the exclusive jurisdiction of the courts in Pune, Maharashtra.',
        ],
        bullets: [],
      ),
      _Section(
        title: 'Contact Information',
        paragraphs: [
          'For questions or concerns regarding these Terms, please contact us at:',
          'Email: legal@mygatebell.com',
          'Address: COEPD Technologies, Pune, Maharashtra, India',
        ],
        bullets: [],
      ),
    ];
  }
}

class _Section {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  _Section({required this.title, required this.paragraphs, this.bullets = const []});
}
