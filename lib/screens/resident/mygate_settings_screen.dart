import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for functionality
  bool _flashApprovalsEnabled = true;
  String _selectedLanguage = 'English';
  double _profileCompletion = 0.85;
  bool _isLoading = false;

  // Household items data
  final List<Map<String, dynamic>> _householdItems = [
    {'icon': Icons.family_restroom_outlined, 'label': 'Family'},
    {'icon': Icons.support_agent_outlined, 'label': 'Daily Help'},
    {'icon': Icons.directions_car_outlined, 'label': 'Vehicles'},
    {'icon': Icons.pets_outlined, 'label': 'Pets'},
  ];

  // Show snackbar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show bottom sheet for language selection
  void _showLanguagePicker() {
    final theme = Theme.of(context);
    final languages = [
      'English',
      'Hindi',
      'Marathi',
      'Gujarati',
      'Tamil',
      'Telugu',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.onSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 28 / 20,
                  letterSpacing: -0.01 * 20,
                ),
              ),
            ),
            ...languages.map(
              (lang) => ListTile(
                title: Text(
                  lang,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    letterSpacing: 0,
                  ),
                ),
                trailing: _selectedLanguage == lang
                    ? Icon(Icons.check, color: theme.primaryColor, size: 20)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                  _showSnackBar('Language changed to $lang');
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Show display mode picker
  void _showDisplayModePicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.onSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Display Mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 28 / 20,
                  letterSpacing: -0.01 * 20,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.light_mode_outlined,
                color: theme.colorScheme.outlineVariant,
              ),
              title: Text(
                'Light',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  letterSpacing: 0,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Light mode enabled');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.dark_mode_outlined,
                color: theme.colorScheme.outlineVariant,
              ),
              title: Text(
                'Dark',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  letterSpacing: 0,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Dark mode enabled');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings_suggest_outlined,
                color: theme.colorScheme.outlineVariant,
              ),
              title: Text(
                'System Default',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  letterSpacing: 0,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('System default mode enabled');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Show logout confirmation
  void _showLogoutDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 28 / 20,
            letterSpacing: -0.01 * 20,
            color: theme.colorScheme.error,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            letterSpacing: 0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Logged out successfully');
              // Navigate to login screen
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show add household item dialog
  void _showAddHouseholdDialog() {
    final theme = Theme.of(context);
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Add to Household',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 28 / 20,
            letterSpacing: -0.01 * 20,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            hintText: 'Enter item name',
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 24 / 16,
              letterSpacing: 0,
              color: theme.colorScheme.outline,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _showSnackBar('\'${controller.text}\' added to household');
              }
            },
            child: Text(
              'Add',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show help dialog
  void _showHelpDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Help',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 28 / 20,
            letterSpacing: -0.01 * 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings Help',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your profile, household members, security preferences, and app settings from this screen.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to screen with loading simulation
  void _navigateTo(String title) {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SubScreen(title: title)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          IconButton(
            onPressed: () => _showHelpDialog(),
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: CustomScrollView(
        // physics: const BouncingScrollPhysics(),
        slivers: [
          // Profile Header
          SliverToBoxAdapter(child: _buildProfileHeader(theme)),

          // Household Section
          SliverToBoxAdapter(child: _buildHouseholdSection(theme)),

          // Security & Notifications
          SliverToBoxAdapter(
            child: _buildSectionHeader('Security & Notifications', theme),
          ),
          SliverToBoxAdapter(
            child: _buildToggleItem(
              icon: Icons.bolt_outlined,
              title: 'Flash Approvals',
              value: _flashApprovalsEnabled,
              onChanged: (value) {
                setState(() => _flashApprovalsEnabled = value);
                _showSnackBar(
                  'Flash Approvals \\${value ? 'enabled' : 'disabled'}',
                );
              },
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              onTap: () => _navigateTo('Notification Settings'),
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.lock_outlined,
              title: 'Security & Privacy',
              onTap: () => _navigateTo('Security & Privacy'),
              theme: theme,
            ),
          ),

          // Purchases
          SliverToBoxAdapter(child: _buildSectionHeader('Purchases', theme)),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.receipt_long_outlined,
              title: 'Order History',
              onTap: () => _navigateTo('Order History'),
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.credit_card_outlined,
              title: 'Saved Payments',
              onTap: () => _navigateTo('Saved Payments'),
              theme: theme,
            ),
          ),

          // Manage Flats
          SliverToBoxAdapter(child: _buildSectionHeader('Manage Flats', theme)),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.apartment_outlined,
              title: 'Unit 402 - Wing A',
              subtitle: 'PRIMARY ADDRESS',
              onTap: () => _navigateTo('Unit 402 - Wing A'),
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.domain_add_outlined,
              title: 'Add New Property',
              onTap: () => _navigateTo('Add New Property'),
              theme: theme,
            ),
          ),

          // General Settings
          SliverToBoxAdapter(
            child: _buildSectionHeader('General Settings', theme),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.language_outlined,
              title: 'App Language',
              trailing: _selectedLanguage,
              onTap: _showLanguagePicker,
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.dark_mode_outlined,
              title: 'Display Mode',
              onTap: _showDisplayModePicker,
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.support_agent_outlined,
              title: 'Support and Feedback',
              onTap: () => _navigateTo('Support and Feedback'),
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNavItem(
              icon: Icons.share_outlined,
              title: 'Share the App',
              onTap: () => _navigateTo('Share the App'),
              theme: theme,
            ),
          ),
          SliverToBoxAdapter(child: _buildLogoutItem(theme)),

          // Footer
          SliverToBoxAdapter(child: _buildFooter(theme)),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // Loading overlay
      // if (_isLoading)
      //   Container(
      //     color: Colors.black.withOpacity(0.1),
      //     child: const Center(
      //       child: CircularProgressIndicator(
      //         color: AppColors.secondary,
      //         strokeWidth: 2,
      //       ),
      //     ),
      //   ),
    );
  }

  // App Bar Widget
  Widget _buildAppBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: MediaQuery.of(context).padding.top + 16.h,
        bottom: 16.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showSnackBar('Back pressed'),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 28 / 20,
                  letterSpacing: -0.01 * 20,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showHelpDialog,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.help_outline,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Profile Header Widget
  Widget _buildProfileHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Row(
            children: [
              // Profile Image
              GestureDetector(
                onTap: () => _showSnackBar('Edit profile photo'),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.onSurface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.onSurface,
                        child: Icon(
                          Icons.person,
                          color: theme.primaryColor,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Name and ID
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nilesh',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      height: 32 / 24,
                      letterSpacing: -0.01 * 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID - 383 553',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      letterSpacing: 0.05 * 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Profile Completion
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completion',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        letterSpacing: 0.05 * 12,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '85%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 16 / 12,
                        letterSpacing: 0.05 * 12,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _profileCompletion,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // Household Section Widget
  Widget _buildHouseholdSection(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HOUSEHOLD',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                  letterSpacing: 0.05 * 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: _showAddHouseholdDialog,
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        letterSpacing: 0.05 * 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _householdItems.map((item) {
              return GestureDetector(
                onTap: () => _navigateTo(item['label']),
                child: Column(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['icon'],
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        letterSpacing: 0.05 * 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 32.h,
        bottom: 16.h,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          letterSpacing: 0.05 * 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // Toggle Item Widget
  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          splashColor: theme.colorScheme.surfaceContainer.withOpacity(0.3),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 24 / 16,
                        letterSpacing: 0.01 * 16,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: theme.colorScheme.onPrimary,
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveThumbColor: theme.colorScheme.primaryContainer,
                  inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  trackOutlineWidth: WidgetStateProperty.all(0),
                  thumbIcon: WidgetStateProperty.all(null),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation Item Widget
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: theme.colorScheme.surfaceContainer.withOpacity(0.3),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 24 / 16,
                            letterSpacing: 0.01 * 16,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                              letterSpacing: 0.05 * 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (trailing != null)
                      Text(
                        trailing,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                          letterSpacing: 0.05 * 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Logout Item Widget
  Widget _buildLogoutItem(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutDialog,
          splashColor: theme.colorScheme.errorContainer.withOpacity(0.3),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: theme.colorScheme.error),
                SizedBox(width: 12.w),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    letterSpacing: 0.01 * 16,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Footer Widget
  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          // Icon(Icons.hub, size: 36, color: theme.colorScheme.outlineVariant),
          GestureDetector(
            onTap: () => _navigateTo('About MyGateBell'),
            child: Row(
              spacing: 8.w,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 30.w,
                  width: 30.w,
                  fit: BoxFit.contain,
                ),
                Text(
                  "MyGateBell",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _navigateTo('Terms & Conditions'),
                child: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    letterSpacing: 0.05 * 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '|',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    letterSpacing: 0.05 * 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _navigateTo('Privacy Policy'),
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    letterSpacing: 0.05 * 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Version 4.12.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              letterSpacing: 0.05 * 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// SUB SCREEN (for navigation destinations)
// ============================================
class SubScreen extends StatelessWidget {
  final String title;

  const SubScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 28 / 20,
            letterSpacing: -0.01 * 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 32 / 24,
                letterSpacing: -0.02 * 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This screen is under development',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                letterSpacing: 0.01 * 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // ============================================
// // DESIGN SYSTEM - Colors
// // ============================================
// class AppColors {
//   static const Color surface = Color(0xFFF7F9FB);
//   static const Color surfaceDim = Color(0xFFD8DADC);
//   static const Color surfaceBright = Color(0xFFF7F9FB);
//   static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
//   static const Color surfaceContainerLow = Color(0xFFF2F4F6);
//   static const Color surfaceContainer = Color(0xFFECEEF0);
//   static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
//   static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
//   static const Color onSurface = Color(0xFF191C1E);
//   static const Color onSurfaceVariant = Color(0xFF45464D);
//   static const Color inverseSurface = Color(0xFF2D3133);
//   static const Color inverseOnSurface = Color(0xFFEFF1F3);
//   static const Color outline = Color(0xFF76777D);
//   static const Color outlineVariant = Color(0xFFC6C6CD);
//   static const Color surfaceTint = Color(0xFF565E74);
//   static const Color primary = Color(0xFF000000);
//   static const Color onPrimary = Color(0xFFFFFFFF);
//   static const Color primaryContainer = Color(0xFF131B2E);
//   static const Color onPrimaryContainer = Color(0xFF7C839B);
//   static const Color inversePrimary = Color(0xFFBEC6E0);
//   static const Color secondary = Color(0xFF526069);
//   static const Color onSecondary = Color(0xFFFFFFFF);
//   static const Color secondaryContainer = Color(0xFFD3E2ED);
//   static const Color onSecondaryContainer = Color(0xFF56656E);
//   static const Color tertiary = Color(0xFF000000);
//   static const Color onTertiary = Color(0xFFFFFFFF);
//   static const Color tertiaryContainer = Color(0xFF271901);
//   static const Color onTertiaryContainer = Color(0xFF98805D);
//   static const Color error = Color(0xFFBA1A1A);
//   static const Color onError = Color(0xFFFFFFFF);
//   static const Color errorContainer = Color(0xFFFFDAD6);
//   static const Color onErrorContainer = Color(0xFF93000A);
//   static const Color primaryFixed = Color(0xFFDAE2FD);
//   static const Color primaryFixedDim = Color(0xFFBEC6E0);
//   static const Color onPrimaryFixed = Color(0xFF131B2E);
//   static const Color onPrimaryFixedVariant = Color(0xFF3F465C);
//   static const Color secondaryFixed = Color(0xFFD6E5EF);
//   static const Color secondaryFixedDim = Color(0xFFBAC9D3);
//   static const Color onSecondaryFixed = Color(0xFF0F1D25);
//   static const Color onSecondaryFixedVariant = Color(0xFF3B4951);
//   static const Color tertiaryFixed = Color(0xFFFCDEB5);
//   static const Color tertiaryFixedDim = Color(0xFFDEC29A);
//   static const Color onTertiaryFixed = Color(0xFF271901);
//   static const Color onTertiaryFixedVariant = Color(0xFF574425);
//   static const Color background = Color(0xFFF7F9FB);
//   static const Color onBackground = Color(0xFF191C1E);
//   static const Color surfaceVariant = Color(0xFFE0E3E5);
// }

// // ============================================
// // DESIGN SYSTEM - Typography
// // ============================================
// class AppTypography {
//   static const String fontFamily = 'Geist';

//   static TextStyle displayLg = const TextStyle(
//     fontFamily: fontFamily,
//     fontSize: 32,
//     fontWeight: FontWeight.w600,
//     height: 40 / 32,
//     letterSpacing: -0.02 * 32,
//     color: AppColors.onSurface,
//   );

//   static TextStyle displayLgMobile = const TextStyle(
//     fontFamily: fontFamily,
//     fontSize: 24,
//     fontWeight: FontWeight.w600,
//     height: 32 / 24,
//     letterSpacing: -0.02 * 24,
//     color: AppColors.onSurface,
//   );

//   static TextStyle headlineMd = const TextStyle(
//     fontFamily: fontFamily,
//     fontSize: 20,
//     fontWeight: FontWeight.w500,
//     height: 28 / 20,
//     letterSpacing: -0.01 * 20,
//     color: AppColors.onSurface,
//   );

//   static TextStyle bodyLg = const TextStyle(
//     fontFamily: fontFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w400,
//     height: 24 / 16,
//     letterSpacing: 0,
//     color: AppColors.onSurface,
//   );

//   static TextStyle bodyMd = const TextStyle(
//     fontFamily: fontFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     height: 20 / 14,
//     letterSpacing: 0,
//     color: AppColors.onSurface,
//   );

//   static TextStyle labelSm = const TextStyle(
//     fontFamily: fontFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     height: 16 / 12,
//     letterSpacing: 0.05 * 12,
//     color: AppColors.onSurfaceVariant,
//   );
// }

// // ============================================
// // DESIGN SYSTEM - Spacing
// // ============================================
// class AppSpacing {
//   static const double unit = 4;
//   static const double marginMobile = 24;
//   static const double marginDesktop = 40;
//   static const double gutter = 16;
//   static const double stackSm = 8;
//   static const double stackMd = 16;
//   static const double stackLg = 32;
// }

// // ============================================
// // MAIN APP
// // ============================================
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Settings',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         fontFamily: AppTypography.fontFamily,
// //         scaffoldBackgroundColor: AppColors.background,
// //         useMaterial3: true,
// //       ),
// //       home: const SettingsScreen(),
// //     );
// //   }
// // }

// // ============================================
// // SETTINGS SCREEN
// // ============================================
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   // State variables for functionality
//   bool _flashApprovalsEnabled = true;
//   String _selectedLanguage = 'English';
//   int _selectedNavIndex = 3; // Settings tab selected
//   double _profileCompletion = 0.85;
//   bool _isLoading = false;

//   // Household items data
//   final List<Map<String, dynamic>> _householdItems = [
//     {'icon': Icons.family_restroom_outlined, 'label': 'Family'},
//     {'icon': Icons.support_agent_outlined, 'label': 'Daily Help'},
//     {'icon': Icons.directions_car_outlined, 'label': 'Vehicles'},
//     {'icon': Icons.pets_outlined, 'label': 'Pets'},
//   ];

//   // Bottom nav items
//   final List<Map<String, dynamic>> _navItems = [
//     {'icon': Icons.home_outlined, 'label': 'Home', 'filledIcon': Icons.home},
//     {
//       'icon': Icons.groups_outlined,
//       'label': 'Community',
//       'filledIcon': Icons.groups,
//     },
//     {'icon': Icons.hub_outlined, 'label': 'Services', 'filledIcon': Icons.hub},
//     {
//       'icon': Icons.settings_outlined,
//       'label': 'Settings',
//       'filledIcon': Icons.settings,
//     },
//   ];

//   // Show snackbar helper
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: AppTypography.bodyMd),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   // Show bottom sheet for language selection
//   void _showLanguagePicker() {
//     final languages = [
//       'English',
//       'Hindi',
//       'Marathi',
//       'Gujarati',
//       'Tamil',
//       'Telugu',
//     ];
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.surfaceContainerLowest,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.outlineVariant,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Text('Select Language', style: AppTypography.headlineMd),
//             ),
//             ...languages.map(
//               (lang) => ListTile(
//                 title: Text(lang, style: AppTypography.bodyLg),
//                 trailing: _selectedLanguage == lang
//                     ? Icon(Icons.check, color: AppColors.secondary, size: 20)
//                     : null,
//                 onTap: () {
//                   setState(() => _selectedLanguage = lang);
//                   Navigator.pop(context);
//                   _showSnackBar('Language changed to $lang');
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   // Show display mode picker
//   void _showDisplayModePicker() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.surfaceContainerLowest,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.outlineVariant,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Text('Display Mode', style: AppTypography.headlineMd),
//             ),
//             ListTile(
//               leading: Icon(
//                 Icons.light_mode_outlined,
//                 color: AppColors.onSurfaceVariant,
//               ),
//               title: Text('Light', style: AppTypography.bodyLg),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showSnackBar('Light mode enabled');
//               },
//             ),
//             ListTile(
//               leading: Icon(
//                 Icons.dark_mode_outlined,
//                 color: AppColors.onSurfaceVariant,
//               ),
//               title: Text('Dark', style: AppTypography.bodyLg),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showSnackBar('Dark mode enabled');
//               },
//             ),
//             ListTile(
//               leading: Icon(
//                 Icons.settings_suggest_outlined,
//                 color: AppColors.onSurfaceVariant,
//               ),
//               title: Text('System Default', style: AppTypography.bodyLg),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showSnackBar('System default mode enabled');
//               },
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   // Show logout confirmation
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.surfaceContainerLowest,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text(
//           'Log Out',
//           style: AppTypography.headlineMd.copyWith(color: AppColors.error),
//         ),
//         content: Text(
//           'Are you sure you want to log out?',
//           style: AppTypography.bodyLg,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: AppTypography.bodyMd.copyWith(
//                 color: AppColors.onSurfaceVariant,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _showSnackBar('Logged out successfully');
//               // Navigate to login screen
//             },
//             child: Text(
//               'Log Out',
//               style: AppTypography.bodyMd.copyWith(color: AppColors.error),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show add household item dialog
//   void _showAddHouseholdDialog() {
//     final TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.surfaceContainerLowest,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text('Add to Household', style: AppTypography.headlineMd),
//         content: TextField(
//           controller: controller,
//           style: AppTypography.bodyLg,
//           decoration: InputDecoration(
//             hintText: 'Enter item name',
//             hintStyle: AppTypography.bodyLg.copyWith(color: AppColors.outline),
//             border: UnderlineInputBorder(
//               borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
//             ),
//             focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: AppColors.primary),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: AppTypography.bodyMd.copyWith(
//                 color: AppColors.onSurfaceVariant,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               if (controller.text.isNotEmpty) {
//                 Navigator.pop(context);
//                 _showSnackBar('\'${controller.text}\' added to household');
//               }
//             },
//             child: Text(
//               'Add',
//               style: AppTypography.bodyMd.copyWith(color: AppColors.primary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show help dialog
//   void _showHelpDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.surfaceContainerLowest,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text('Help', style: AppTypography.headlineMd),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Settings Help',
//               style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Manage your profile, household members, security preferences, and app settings from this screen.',
//               style: AppTypography.bodyMd.copyWith(
//                 color: AppColors.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Got it',
//               style: AppTypography.bodyMd.copyWith(color: AppColors.primary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Navigate to screen with loading simulation
//   void _navigateTo(String title) {
//     setState(() => _isLoading = true);
//     Future.delayed(const Duration(milliseconds: 300), () {
//       setState(() => _isLoading = false);
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => SubScreen(title: title)),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text("Settings"),
//         actions: [
//           IconButton(
//             onPressed: () => _showHelpDialog(),
//             icon: Icon(Icons.help_outline),
//           ),
//         ],
//       ),
//       body: CustomScrollView(
//         // physics: const BouncingScrollPhysics(),
//         slivers: [
//           // Profile Header
//           SliverToBoxAdapter(child: _buildProfileHeader()),

//           // Household Section
//           SliverToBoxAdapter(child: _buildHouseholdSection()),

//           // Security & Notifications
//           SliverToBoxAdapter(
//             child: _buildSectionHeader('Security & Notifications'),
//           ),
//           SliverToBoxAdapter(
//             child: _buildToggleItem(
//               icon: Icons.bolt_outlined,
//               title: 'Flash Approvals',
//               value: _flashApprovalsEnabled,
//               onChanged: (value) {
//                 setState(() => _flashApprovalsEnabled = value);
//                 _showSnackBar(
//                   'Flash Approvals \\${value ? 'enabled' : 'disabled'}',
//                 );
//               },
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.notifications_outlined,
//               title: 'Notification Settings',
//               onTap: () => _navigateTo('Notification Settings'),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.lock_outlined,
//               title: 'Security & Privacy',
//               onTap: () => _navigateTo('Security & Privacy'),
//             ),
//           ),

//           // Purchases
//           SliverToBoxAdapter(child: _buildSectionHeader('Purchases')),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.receipt_long_outlined,
//               title: 'Order History',
//               onTap: () => _navigateTo('Order History'),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.credit_card_outlined,
//               title: 'Saved Payments',
//               onTap: () => _navigateTo('Saved Payments'),
//             ),
//           ),

//           // Manage Flats
//           SliverToBoxAdapter(child: _buildSectionHeader('Manage Flats')),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.apartment_outlined,
//               title: 'Unit 402 - Wing A',
//               subtitle: 'PRIMARY ADDRESS',
//               onTap: () => _navigateTo('Unit 402 - Wing A'),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.domain_add_outlined,
//               title: 'Add New Property',
//               onTap: () => _navigateTo('Add New Property'),
//             ),
//           ),

//           // General Settings
//           SliverToBoxAdapter(child: _buildSectionHeader('General Settings')),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.language_outlined,
//               title: 'App Language',
//               trailing: _selectedLanguage,
//               onTap: _showLanguagePicker,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.dark_mode_outlined,
//               title: 'Display Mode',
//               onTap: _showDisplayModePicker,
//             ),
//           ),
//           SliverToBoxAdapter(child: _buildLogoutItem()),

//           // Footer
//           SliverToBoxAdapter(child: _buildFooter()),

//           // Bottom padding for nav bar
//           const SliverToBoxAdapter(child: SizedBox(height: 80)),
//         ],
//       ),

//       // Loading overlay
//       // if (_isLoading)
//       //   Container(
//       //     color: Colors.black.withOpacity(0.1),
//       //     child: const Center(
//       //       child: CircularProgressIndicator(
//       //         color: AppColors.secondary,
//       //         strokeWidth: 2,
//       //       ),
//       //     ),
//       //   ),
//     );
//   }

//   // App Bar Widget
//   Widget _buildAppBar() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: AppColors.background,
//         border: Border(
//           bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
//         ),
//       ),
//       padding: EdgeInsets.only(
//         left: AppSpacing.marginMobile,
//         right: AppSpacing.marginMobile,
//         top: MediaQuery.of(context).padding.top + AppSpacing.stackMd,
//         bottom: AppSpacing.stackMd,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => _showSnackBar('Back pressed'),
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   child: Icon(
//                     Icons.arrow_back,
//                     color: AppColors.primary,
//                     size: 24,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text('Settings', style: AppTypography.headlineMd),
//             ],
//           ),
//           GestureDetector(
//             onTap: _showHelpDialog,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               child: Icon(
//                 Icons.help_outline,
//                 color: AppColors.primary,
//                 size: 24,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Profile Header Widget
//   Widget _buildProfileHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 32.h),
//           Row(
//             children: [
//               // Profile Image
//               GestureDetector(
//                 onTap: () => _showSnackBar('Edit profile photo'),
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: AppColors.surfaceContainer,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         color: AppColors.surfaceContainer,
//                         child: Icon(
//                           Icons.person,
//                           color: AppColors.onSurfaceVariant,
//                           size: 40,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.stackMd),
//               // Name and ID
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Nilesh',
//                     style: AppTypography.displayLgMobile.copyWith(
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'ID - 383 553',
//                     style: AppTypography.labelSm.copyWith(
//                       letterSpacing: 2,
//                       color: AppColors.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           // Profile Completion
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Profile Completion',
//                       style: AppTypography.labelSm.copyWith(
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                     Text(
//                       '85%',
//                       style: AppTypography.labelSm.copyWith(
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceContainerHigh,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//                 child: FractionallySizedBox(
//                   alignment: Alignment.centerLeft,
//                   widthFactor: _profileCompletion,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.secondary,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//         ],
//       ),
//     );
//   }

//   // Household Section Widget
//   Widget _buildHouseholdSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 32.h),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 24.w,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'HOUSEHOLD',
//                 style: AppTypography.labelSm.copyWith(
//                   letterSpacing: 1.2,
//                   color: AppColors.onSurfaceVariant,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: _showAddHouseholdDialog,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.add,
//                       size: 16,
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Add',
//                       style: AppTypography.labelSm.copyWith(
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 16.h),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.symmetric(
//             horizontal: 24.w,
//           ),
//           child: Row(
//             children: _householdItems.map((item) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 32),
//                 child: GestureDetector(
//                   onTap: () => _navigateTo(item['label']),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: AppColors.surfaceContainerLow,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           item['icon'],
//                           size: 28,
//                           color: AppColors.onSurfaceVariant,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         item['label'],
//                         style: AppTypography.labelSm.copyWith(
//                           color: AppColors.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         const SizedBox(height: AppSpacing.stackSm),
//       ],
//     );
//   }

//   // Section Header Widget
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(
//         left: AppSpacing.marginMobile,
//         right: AppSpacing.marginMobile,
//         top: 32,
//         bottom: AppSpacing.stackSm,
//       ),
//       child: Text(
//         title.toUpperCase(),
//         style: AppTypography.labelSm.copyWith(
//           letterSpacing: 1.2,
//           color: AppColors.onSurfaceVariant,
//         ),
//       ),
//     );
//   }

//   // Toggle Item Widget
//   Widget _buildToggleItem({
//     required IconData icon,
//     required String title,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//   }) {
//     return Container(
//       decoration: const BoxDecoration(
//         border: Border(
//           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => onChanged(!value),
//           splashColor: AppColors.surfaceContainer.withOpacity(0.3),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.w,
//               vertical: AppSpacing.stackMd,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
//                     const SizedBox(width: AppSpacing.stackMd),
//                     Text(title, style: AppTypography.bodyMd),
//                   ],
//                 ),
//                 Switch(
//                   value: value,
//                   onChanged: onChanged,
//                   activeColor: AppColors.onSecondary,
//                   activeTrackColor: AppColors.secondary,
//                   inactiveThumbColor: AppColors.surfaceContainerLowest,
//                   inactiveTrackColor: AppColors.surfaceContainerHighest,
//                   trackOutlineColor: WidgetStateProperty.all(
//                     Colors.transparent,
//                   ),
//                   trackOutlineWidth: WidgetStateProperty.all(0),
//                   thumbIcon: WidgetStateProperty.all(null),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Navigation Item Widget
//   Widget _buildNavItem({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     String? trailing,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       decoration: const BoxDecoration(
//         border: Border(
//           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           splashColor: AppColors.surfaceContainer.withOpacity(0.3),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.w,
//               vertical: AppSpacing.stackMd,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
//                     const SizedBox(width: AppSpacing.stackMd),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(title, style: AppTypography.bodyMd),
//                         if (subtitle != null)
//                           Text(
//                             subtitle,
//                             style: AppTypography.labelSm.copyWith(
//                               fontSize: 10,
//                               color: theme.colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     if (trailing != null)
//                       Text(
//                         trailing,
//                         style: AppTypography.labelSm.copyWith(
//                           color: theme.colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     const SizedBox(width: 8),
//                     Icon(
//                       Icons.chevron_right,
//                       size: 20,
//                       color: theme.colorScheme.outlineVariant,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Logout Item Widget
//   Widget _buildLogoutItem() {
//     return Container(
//       decoration: const BoxDecoration(
//         border: Border(
//           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _showLogoutDialog,
//           splashColor: AppColors.errorContainer.withOpacity(0.3),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.w,
//               vertical: AppSpacing.stackMd,
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.logout, size: 20, color: AppColors.error),
//                 const SizedBox(width: AppSpacing.stackMd),
//                 Text(
//                   'Log Out',
//                   style: AppTypography.bodyMd.copyWith(color: AppColors.error),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Footer Widget
//   Widget _buildFooter() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 40),
//       child: Column(
//         children: [
//           Icon(Icons.hub, size: 36, color: theme.colorScheme.outlineVariant),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () => _navigateTo('Terms & Conditions'),
//                 child: Text(
//                   'Terms & Conditions',
//                   style: AppTypography.labelSm.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Text(
//                   '|',
//                   style: AppTypography.labelSm.copyWith(
//                     color: theme.colorScheme.outlineVariant,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => _navigateTo('Privacy Policy'),
//                 child: Text(
//                   'Privacy Policy',
//                   style: AppTypography.labelSm.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Version 4.12.0',
//             style: AppTypography.labelSm.copyWith(
//               fontSize: 10,
//               color: theme.colorScheme.outlineVariant,
//               letterSpacing: 2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ============================================
// // SUB SCREEN (for navigation destinations)
// // ============================================
// class SubScreen extends StatelessWidget {
//   final String title;

//   const SubScreen({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.primary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(title, style: AppTypography.headlineMd),
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(1),
//           child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.construction_outlined,
//               size: 48,
//               color: theme.colorScheme.outlineVariant,
//             ),
//             const SizedBox(height: 16),
//             Text(title, style: AppTypography.displayLgMobile),
//             const SizedBox(height: 8),
//             Text(
//               'This screen is under development',
//               style: AppTypography.bodyMd.copyWith(
//                 color: AppColors.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// Kimi exact matching code

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             // App Bar
//             SliverToBoxAdapter(child: _buildAppBar()),
//             // Ad-Supported Banner
//             SliverToBoxAdapter(child: _buildAdBanner()),
//             // Profile Section
//             SliverToBoxAdapter(child: _buildProfileSection()),
//             // Profile Completion
//             SliverToBoxAdapter(child: _buildProfileCompletion()),
//             // Household Section
//             SliverToBoxAdapter(child: _buildHouseholdSection()),
//             // Address Card
//             SliverToBoxAdapter(child: _buildAddressCard()),
//             // Security & Notifications Section
//             SliverToBoxAdapter(
//               child: _buildSectionHeader('Security & Notifications'),
//             ),
//             SliverToBoxAdapter(child: _buildNotificationTestCard()),
//             SliverToBoxAdapter(child: _buildFlashApprovalsCard()),
//             SliverToBoxAdapter(
//               child: _buildMenuItem(
//                 icon: Icons.notifications_outlined,
//                 title: 'Notification Preferences',
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: _buildMenuItem(
//                 icon: Icons.crisis_alert_outlined,
//                 title: 'Security Alert List',
//               ),
//             ),
//             // Purchases Section
//             SliverToBoxAdapter(child: _buildSectionHeader('Purchases')),
//             SliverToBoxAdapter(
//               child: _buildMenuItem(
//                 icon: Icons.receipt_outlined,
//                 title: 'My Orders',
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: _buildMenuItemWithBadge(
//                 icon: Icons.card_membership_outlined,
//                 title: 'My Plans',
//                 badge: 'Ad-Supported',
//               ),
//             ),
//             // Manage Flats Section
//             SliverToBoxAdapter(child: _buildSectionHeader('Manage Flats')),
//             SliverToBoxAdapter(child: _buildFlatItem()),
//             SliverToBoxAdapter(child: _buildAddFlatItem()),
//             // General Settings Section
//             SliverToBoxAdapter(child: _buildSectionHeader('General Settings')),
//             SliverToBoxAdapter(
//               child: _buildMenuItem(
//                 icon: Icons.headset_mic_outlined,
//                 title: 'Support & Feedback',
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: _buildMenuItem(
//                 icon: Icons.share_outlined,
//                 title: 'Tell a friend about mygate',
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: _buildMenuItem(
//                 icon: Icons.person_outline,
//                 title: 'Account Information',
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: _buildMenuItem(icon: Icons.logout, title: 'Logout'),
//             ),
//             // Footer
//             SliverToBoxAdapter(child: _buildFooter()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       child: Row(
//         children: [
//           Icon(Icons.arrow_back, size: 24.sp, color: Colors.black87),
//           SizedBox(width: 16.w),
//           Text(
//             'Settings',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const Spacer(),
//           Icon(Icons.help_outline, size: 24.sp, color: Colors.black54),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdBanner() {
//     return Container(
//       color: const Color(0xFFF0F0F0),
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//       child: Row(
//         children: [
//           Text(
//             'Your society is on Ad-Supported plan',
//             style: TextStyle(fontSize: 12.sp, color: Colors.black54),
//           ),
//           SizedBox(width: 4.w),
//           Text(
//             'Learn more',
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: Colors.black87,
//               fontWeight: FontWeight.w500,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileSection() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.all(16.w),
//       child: Row(
//         children: [
//           Container(
//             width: 56.w,
//             height: 56.w,
//             decoration: const BoxDecoration(
//               color: Color(0xFF7A9E5C),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 'N',
//                 style: TextStyle(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Nilesh',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               SizedBox(height: 6.h),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF0F0F0),
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'mygate ID',
//                       style: TextStyle(fontSize: 12.sp, color: Colors.black54),
//                     ),
//                     SizedBox(width: 4.w),
//                     Text(
//                       '383 553',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(width: 4.w),
//                     Icon(
//                       Icons.info_outline,
//                       size: 14.sp,
//                       color: Colors.black54,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           Container(
//             width: 36.w,
//             height: 36.w,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF0F0F0),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Icon(Icons.qr_code, size: 20.sp, color: Colors.black54),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileCompletion() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       child: Row(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 width: 44.w,
//                 height: 44.w,
//                 child: CircularProgressIndicator(
//                   value: 0.67,
//                   strokeWidth: 3.w,
//                   backgroundColor: const Color(0xFFE8F5E9),
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     Color(0xFF7A9E5C),
//                   ),
//                 ),
//               ),
//               Text(
//                 '67%',
//                 style: TextStyle(
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF7A9E5C),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Let neighbours discover you!',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   'Complete your profile',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               Text(
//                 'View Profile',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               SizedBox(width: 4.w),
//               Icon(Icons.chevron_right, size: 18.sp, color: Colors.black54),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHouseholdSection() {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(top: 8.h),
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.people_outline,
//                     size: 20.sp,
//                     color: Colors.black87,
//                   ),
//                   SizedBox(width: 8.w),
//                   Text(
//                     'Household',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Text(
//                     'Manage',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Icon(Icons.chevron_right, size: 18.sp, color: Colors.black54),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildHouseholdCard(
//                   title: 'Family',
//                   icon: Icons.people_outline,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: _buildHouseholdCard(
//                   title: 'Daily Help',
//                   icon: Icons.cleaning_services_outlined,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildHouseholdCard(
//                   title: 'Vehicles',
//                   icon: Icons.directions_car_outlined,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: _buildHouseholdCard(
//                   title: 'Pets',
//                   icon: Icons.pets_outlined,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHouseholdCard({required String title, required IconData icon}) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 13.sp, color: Colors.black87),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 '+ Add',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           Stack(
//             alignment: Alignment.bottomRight,
//             children: [
//               Icon(icon, size: 28.sp, color: Colors.black38),
//               Container(
//                 width: 14.w,
//                 height: 14.w,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFFFD700),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.add, size: 10.sp, color: Colors.black87),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddressCard() {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(top: 8.h),
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'My Address',
//                 style: TextStyle(
//                   fontSize: 15.sp,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Text(
//                     'Share',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(width: 4.w),
//                   Icon(Icons.arrow_outward, size: 16.sp, color: Colors.black54),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             '1st Floor, A1 1, Shivneri A wing, Tulaja Bhawani Nagar, Kharadi, Pune, Maharashtra 411014, Pune-411014',
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: Colors.black54,
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Container(
//       color: const Color(0xFFF5F5F5),
//       padding: EdgeInsets.only(left: 16.w, top: 20.h, bottom: 8.h),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w500,
//           color: Colors.black45,
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationTestCard() {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(bottom: 1.h),
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Not Getting Notifications ?',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.black87,
//             ),
//           ),
//           Row(
//             children: [
//               Text(
//                 'Test Now',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               Icon(Icons.chevron_right, size: 18.sp, color: Colors.black54),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFlashApprovalsCard() {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(bottom: 8.h),
//       padding: EdgeInsets.all(16.w),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'Flash Approvals',
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(width: 6.w),
//                     Icon(
//                       Icons.info_outline,
//                       size: 16.sp,
//                       color: Colors.black54,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   'Ensure you never miss approvals again',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Container(
//             width: 48.w,
//             height: 28.h,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(14.r),
//               color: Colors.grey.shade300,
//             ),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Container(
//                 width: 24.w,
//                 height: 24.w,
//                 margin: EdgeInsets.all(2.w),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuItem({required IconData icon, required String title}) {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(bottom: 1.h),
//       child: ListTile(
//         leading: Container(
//           width: 36.w,
//           height: 36.w,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF0F0F0),
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Icon(icon, size: 20.sp, color: Colors.black54),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         trailing: Icon(Icons.chevron_right, size: 20.sp, color: Colors.black38),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//         minLeadingWidth: 0,
//       ),
//     );
//   }

//   Widget _buildMenuItemWithBadge({
//     required IconData icon,
//     required String title,
//     required String badge,
//   }) {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(bottom: 8.h),
//       child: ListTile(
//         leading: Container(
//           width: 36.w,
//           height: 36.w,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF0F0F0),
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Icon(icon, size: 20.sp, color: Colors.black54),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF0F0F0),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Text(
//                 badge,
//                 style: TextStyle(fontSize: 12.sp, color: Colors.black54),
//               ),
//             ),
//             SizedBox(width: 8.w),
//             Icon(Icons.chevron_right, size: 20.sp, color: Colors.black38),
//           ],
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//         minLeadingWidth: 0,
//       ),
//     );
//   }

//   Widget _buildFlatItem() {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(bottom: 1.h),
//       child: ListTile(
//         leading: Container(
//           width: 36.w,
//           height: 36.w,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF0F0F0),
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Icon(Icons.home_outlined, size: 20.sp, color: Colors.black54),
//         ),
//         title: Text(
//           'A1 1, Shivneri A Wing',
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         trailing: Container(
//           padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//           decoration: BoxDecoration(
//             color: const Color(0xFFE8F5E9),
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Text(
//             'Active',
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: const Color(0xFF4CAF50),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//         minLeadingWidth: 0,
//       ),
//     );
//   }

//   Widget _buildAddFlatItem() {
//     return Container(
//       color: Colors.white,
//       margin: EdgeInsets.only(bottom: 8.h),
//       child: ListTile(
//         leading: Container(
//           width: 36.w,
//           height: 36.w,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black54),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(Icons.add, size: 20.sp, color: Colors.black54),
//         ),
//         title: Text(
//           'Add Flat/Villa/Office',
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//         minLeadingWidth: 0,
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return Container(
//       color: const Color(0xFFF5F5F5),
//       padding: EdgeInsets.symmetric(vertical: 24.h),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.grid_view, size: 24.sp, color: Colors.black87),
//               SizedBox(width: 8.w),
//               Text(
//                 'mygate',
//                 style: TextStyle(
//                   fontSize: 22.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Terms & Conditions',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Colors.black54,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//               Text(
//                 '  |  ',
//                 style: TextStyle(fontSize: 12.sp, color: Colors.black38),
//               ),
//               Text(
//                 'Privacy Policy',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Colors.black54,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Version 7.27.1',
//             style: TextStyle(fontSize: 12.sp, color: Colors.black38),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Claude Code

// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';

// // class SettingsScreen extends StatefulWidget {
// //   const SettingsScreen({super.key});

// //   @override
// //   State<SettingsScreen> createState() => _SettingsScreenState();
// // }

// // class _SettingsScreenState extends State<SettingsScreen> {
// //   bool _flashApprovalsEnabled = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF2F2F7),
// //       body: Column(
// //         children: [
// //           _buildAppBar(),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   _buildAdBanner(),
// //                   _buildProfileCard(),
// //                   SizedBox(height: 16.h),
// //                   _buildHouseholdSection(),
// //                   SizedBox(height: 16.h),
// //                   _buildSecuritySection(),
// //                   SizedBox(height: 16.h),
// //                   _buildPurchasesSection(),
// //                   SizedBox(height: 16.h),
// //                   _buildManageFlatsSection(),
// //                   SizedBox(height: 16.h),
// //                   _buildGeneralSection(),
// //                   SizedBox(height: 20.h),
// //                   _buildFooter(),
// //                   SizedBox(height: 20.h),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildAppBar() {
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
// //         child: Row(
// //           children: [
// //             IconButton(
// //               onPressed: () {},
// //               icon: Icon(Icons.arrow_back, size: 24.sp, color: Colors.black87),
// //             ),
// //             Text(
// //               'Settings',
// //               style: TextStyle(
// //                 fontSize: 18.sp,
// //                 fontWeight: FontWeight.w600,
// //                 color: Colors.black87,
// //               ),
// //             ),
// //             const Spacer(),
// //             IconButton(
// //               onPressed: () {},
// //               icon: Icon(
// //                 Icons.help_outline,
// //                 size: 24.sp,
// //                 color: Colors.black54,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildAdBanner() {
// //     return Container(
// //       width: double.infinity,
// //       color: const Color(0xFFFFF8E1),
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
// //       child: Row(
// //         children: [
// //           Text(
// //             'Your society is on Ad-Supported plan  ',
// //             style: TextStyle(fontSize: 13.sp, color: Colors.black87),
// //           ),
// //           GestureDetector(
// //             onTap: () {},
// //             child: Text(
// //               'Learn more',
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 color: const Color(0xFF1A73E8),
// //                 decoration: TextDecoration.underline,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildProfileCard() {
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.all(16.w),
// //       child: Column(
// //         children: [
// //           Row(
// //             children: [
// //               CircleAvatar(
// //                 radius: 28.r,
// //                 backgroundColor: const Color(0xFF4CAF50),
// //                 child: Text(
// //                   'N',
// //                   style: TextStyle(
// //                     fontSize: 22.sp,
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(width: 14.w),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Nilesh',
// //                     style: TextStyle(
// //                       fontSize: 18.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                   SizedBox(height: 4.h),
// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: EdgeInsets.symmetric(
// //                           horizontal: 10.w,
// //                           vertical: 4.h,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFFF0F4FF),
// //                           borderRadius: BorderRadius.circular(20.r),
// //                           border: Border.all(
// //                             color: const Color(0xFFDDE6FF),
// //                             width: 1,
// //                           ),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             Text(
// //                               'mygate ID  383 553',
// //                               style: TextStyle(
// //                                 fontSize: 12.sp,
// //                                 color: Colors.black87,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                             SizedBox(width: 4.w),
// //                             Icon(
// //                               Icons.info_outline,
// //                               size: 14.sp,
// //                               color: Colors.black54,
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       SizedBox(width: 8.w),
// //                       Icon(Icons.qr_code_2, size: 28.sp, color: Colors.black87),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 14.h),
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF9F9FF),
// //               borderRadius: BorderRadius.circular(10.r),
// //               border: Border.all(color: const Color(0xFFE0E0E0)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     SizedBox(
// //                       width: 38.w,
// //                       height: 38.w,
// //                       child: CircularProgressIndicator(
// //                         value: 0.67,
// //                         strokeWidth: 3.5,
// //                         backgroundColor: const Color(0xFFE0E0E0),
// //                         valueColor: const AlwaysStoppedAnimation<Color>(
// //                           Color(0xFF4CAF50),
// //                         ),
// //                       ),
// //                     ),
// //                     Text(
// //                       '67%',
// //                       style: TextStyle(
// //                         fontSize: 9.sp,
// //                         fontWeight: FontWeight.w700,
// //                         color: const Color(0xFF4CAF50),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(width: 12.w),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Let neighbours discover you!',
// //                         style: TextStyle(
// //                           fontSize: 13.sp,
// //                           fontWeight: FontWeight.w600,
// //                           color: Colors.black87,
// //                         ),
// //                       ),
// //                       Text(
// //                         'Complete your profile',
// //                         style: TextStyle(
// //                           fontSize: 12.sp,
// //                           color: Colors.black54,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Row(
// //                   children: [
// //                     Text(
// //                       'View Profile',
// //                       style: TextStyle(
// //                         fontSize: 13.sp,
// //                         color: const Color(0xFF1A73E8),
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                     Icon(
// //                       Icons.chevron_right,
// //                       size: 18.sp,
// //                       color: const Color(0xFF1A73E8),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildHouseholdSection() {
// //     return Container(
// //       color: Colors.white,
// //       child: Column(
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Icon(
// //                       Icons.people_outline,
// //                       size: 20.sp,
// //                       color: Colors.black87,
// //                     ),
// //                     SizedBox(width: 8.w),
// //                     Text(
// //                       'Household',
// //                       style: TextStyle(
// //                         fontSize: 15.sp,
// //                         fontWeight: FontWeight.w700,
// //                         color: Colors.black87,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 GestureDetector(
// //                   onTap: () {},
// //                   child: Row(
// //                     children: [
// //                       Text(
// //                         'Manage',
// //                         style: TextStyle(
// //                           fontSize: 13.sp,
// //                           color: const Color(0xFF1A73E8),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                       Icon(
// //                         Icons.chevron_right,
// //                         size: 18.sp,
// //                         color: const Color(0xFF1A73E8),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w),
// //             child: Column(
// //               children: [
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: _buildHouseholdTile(
// //                         label: 'Family',
// //                         icon: Icons.people_alt_outlined,
// //                       ),
// //                     ),
// //                     SizedBox(width: 12.w),
// //                     Expanded(
// //                       child: _buildHouseholdTile(
// //                         label: 'Daily Help',
// //                         icon: Icons.cleaning_services_outlined,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 12.h),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: _buildHouseholdTile(
// //                         label: 'Vehicles',
// //                         icon: Icons.directions_car_outlined,
// //                       ),
// //                     ),
// //                     SizedBox(width: 12.w),
// //                     Expanded(
// //                       child: _buildHouseholdTile(
// //                         label: 'Pets',
// //                         icon: Icons.pets_outlined,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 14.h),
// //                 _buildAddressCard(),
// //                 SizedBox(height: 14.h),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildHouseholdTile({required String label, required IconData icon}) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
// //       decoration: BoxDecoration(
// //         border: Border.all(color: const Color(0xFFE0E0E0)),
// //         borderRadius: BorderRadius.circular(10.r),
// //       ),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   label,
// //                   style: TextStyle(
// //                     fontSize: 13.sp,
// //                     color: Colors.black87,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //                 SizedBox(height: 2.h),
// //                 Text(
// //                   '+ Add',
// //                   style: TextStyle(
// //                     fontSize: 12.sp,
// //                     color: const Color(0xFF1A73E8),
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Stack(
// //             clipBehavior: Clip.none,
// //             children: [
// //               Icon(icon, size: 28.sp, color: Colors.black54),
// //               Positioned(
// //                 bottom: -2,
// //                 right: -2,
// //                 child: Container(
// //                   width: 14.w,
// //                   height: 14.w,
// //                   decoration: const BoxDecoration(
// //                     color: Color(0xFF1A73E8),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: Icon(Icons.add, size: 10.sp, color: Colors.white),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildAddressCard() {
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.all(14.w),
// //       decoration: BoxDecoration(
// //         border: Border.all(color: const Color(0xFFE0E0E0)),
// //         borderRadius: BorderRadius.circular(10.r),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'My Address',
// //                 style: TextStyle(
// //                   fontSize: 13.sp,
// //                   fontWeight: FontWeight.w600,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               Row(
// //                 children: [
// //                   Text(
// //                     'Share',
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       color: Colors.black54,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   SizedBox(width: 4.w),
// //                   Icon(
// //                     Icons.share_outlined,
// //                     size: 16.sp,
// //                     color: Colors.black54,
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 8.h),
// //           Text(
// //             '1st Floor, A1 1, Shivneri A wing, Tulaja Bhawani Nagar,\nKharadi, Pune, Maharashtra 411014, Pune-411014',
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               color: Colors.black54,
// //               height: 1.5,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSecuritySection() {
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.symmetric(vertical: 6.h),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //             child: Text(
// //               'Security & Notifications',
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 color: Colors.black45,
// //                 fontWeight: FontWeight.w500,
// //                 letterSpacing: 0.3,
// //               ),
// //             ),
// //           ),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w),
// //             child: Container(
// //               padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF9F9F9),
// //                 borderRadius: BorderRadius.circular(10.r),
// //                 border: Border.all(color: const Color(0xFFE5E5E5)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Text(
// //                       'Not Getting Notifications ?',
// //                       style: TextStyle(
// //                         fontSize: 14.sp,
// //                         color: Colors.black87,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //                   GestureDetector(
// //                     onTap: () {},
// //                     child: Row(
// //                       children: [
// //                         Text(
// //                           'Test Now',
// //                           style: TextStyle(
// //                             fontSize: 13.sp,
// //                             color: const Color(0xFF1A73E8),
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         Icon(
// //                           Icons.chevron_right,
// //                           size: 18.sp,
// //                           color: const Color(0xFF1A73E8),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 8.h),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w),
// //             child: Container(
// //               padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFFFFDE7),
// //                 borderRadius: BorderRadius.circular(10.r),
// //                 border: Border.all(color: const Color(0xFFFFEE82)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Text(
// //                               'Flash Approvals',
// //                               style: TextStyle(
// //                                 fontSize: 14.sp,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: Colors.black87,
// //                               ),
// //                             ),
// //                             SizedBox(width: 4.w),
// //                             Icon(
// //                               Icons.info_outline,
// //                               size: 15.sp,
// //                               color: Colors.black54,
// //                             ),
// //                           ],
// //                         ),
// //                         SizedBox(height: 3.h),
// //                         Text(
// //                           'Ensure you never miss approvals again',
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             color: Colors.black54,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   Transform.scale(
// //                     scale: 0.85,
// //                     child: Switch(
// //                       value: _flashApprovalsEnabled,
// //                       onChanged: (value) {
// //                         setState(() {
// //                           _flashApprovalsEnabled = value;
// //                         });
// //                       },
// //                       activeColor: const Color(0xFF1A73E8),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 4.h),
// //           _buildListTile(
// //             icon: Icons.notifications_outlined,
// //             title: 'Notification Preferences',
// //             onTap: () {},
// //           ),
// //           const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
// //           _buildListTile(
// //             icon: Icons.settings_input_antenna_outlined,
// //             title: 'Security Alert List',
// //             onTap: () {},
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPurchasesSection() {
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.symmetric(vertical: 6.h),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //             child: Text(
// //               'Purchases',
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 color: Colors.black45,
// //                 fontWeight: FontWeight.w500,
// //                 letterSpacing: 0.3,
// //               ),
// //             ),
// //           ),
// //           _buildListTile(
// //             icon: Icons.receipt_long_outlined,
// //             title: 'My Orders',
// //             onTap: () {},
// //           ),
// //           const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
// //           _buildListTileWithBadge(
// //             icon: Icons.shopping_bag_outlined,
// //             title: 'My Plans',
// //             badge: 'Ad-Supported',
// //             onTap: () {},
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildManageFlatsSection() {
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.symmetric(vertical: 6.h),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //             child: Text(
// //               'Manage Flats',
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 color: Colors.black45,
// //                 fontWeight: FontWeight.w500,
// //                 letterSpacing: 0.3,
// //               ),
// //             ),
// //           ),
// //           _buildListTileWithStatus(
// //             icon: Icons.home_outlined,
// //             title: 'A1 1, Shivneri A Wing',
// //             status: 'Active',
// //             onTap: () {},
// //           ),
// //           const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
// //             child: GestureDetector(
// //               onTap: () {},
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 28.w,
// //                     height: 28.w,
// //                     decoration: BoxDecoration(
// //                       border: Border.all(
// //                         color: const Color(0xFF1A73E8),
// //                         width: 1.5,
// //                       ),
// //                       shape: BoxShape.circle,
// //                     ),
// //                     child: Icon(
// //                       Icons.add,
// //                       size: 16.sp,
// //                       color: const Color(0xFF1A73E8),
// //                     ),
// //                   ),
// //                   SizedBox(width: 16.w),
// //                   Text(
// //                     'Add Flat/Villa/Office',
// //                     style: TextStyle(
// //                       fontSize: 14.sp,
// //                       color: Colors.black87,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildGeneralSection() {
// //     return Container(
// //       color: Colors.white,
// //       padding: EdgeInsets.symmetric(vertical: 6.h),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //             child: Text(
// //               'General Settings',
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 color: Colors.black45,
// //                 fontWeight: FontWeight.w500,
// //                 letterSpacing: 0.3,
// //               ),
// //             ),
// //           ),
// //           _buildListTile(
// //             icon: Icons.help_outline,
// //             title: 'Support & Feedback',
// //             onTap: () {},
// //           ),
// //           const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
// //           _buildListTile(
// //             icon: Icons.share_outlined,
// //             title: 'Tell a friend about mygate',
// //             onTap: () {},
// //           ),
// //           const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
// //           _buildListTile(
// //             icon: Icons.person_outline,
// //             title: 'Account Information',
// //             onTap: () {},
// //           ),
// //           const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
// //           _buildListTile(icon: Icons.logout, title: 'Logout', onTap: () {}),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildListTile({
// //     required IconData icon,
// //     required String title,
// //     required VoidCallback onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
// //         child: Row(
// //           children: [
// //             Icon(icon, size: 22.sp, color: Colors.black54),
// //             SizedBox(width: 16.w),
// //             Expanded(
// //               child: Text(
// //                 title,
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   color: Colors.black87,
// //                   fontWeight: FontWeight.w400,
// //                 ),
// //               ),
// //             ),
// //             Icon(Icons.chevron_right, size: 20.sp, color: Colors.black38),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildListTileWithBadge({
// //     required IconData icon,
// //     required String title,
// //     required String badge,
// //     required VoidCallback onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
// //         child: Row(
// //           children: [
// //             Icon(icon, size: 22.sp, color: Colors.black54),
// //             SizedBox(width: 16.w),
// //             Expanded(
// //               child: Text(
// //                 title,
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   color: Colors.black87,
// //                   fontWeight: FontWeight.w400,
// //                 ),
// //               ),
// //             ),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF0F0F0),
// //                 borderRadius: BorderRadius.circular(20.r),
// //               ),
// //               child: Text(
// //                 badge,
// //                 style: TextStyle(
// //                   fontSize: 11.sp,
// //                   color: Colors.black54,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ),
// //             SizedBox(width: 4.w),
// //             Icon(Icons.chevron_right, size: 20.sp, color: Colors.black38),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildListTileWithStatus({
// //     required IconData icon,
// //     required String title,
// //     required String status,
// //     required VoidCallback onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
// //         child: Row(
// //           children: [
// //             Icon(icon, size: 22.sp, color: Colors.black54),
// //             SizedBox(width: 16.w),
// //             Expanded(
// //               child: Text(
// //                 title,
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   color: Colors.black87,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFE8F5E9),
// //                 borderRadius: BorderRadius.circular(20.r),
// //                 border: Border.all(color: const Color(0xFF4CAF50), width: 0.8),
// //               ),
// //               child: Text(
// //                 status,
// //                 style: TextStyle(
// //                   fontSize: 12.sp,
// //                   color: const Color(0xFF2E7D32),
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFooter() {
// //     return Column(
// //       children: [
// //         Center(
// //           child: Column(
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Container(
// //                     width: 28.w,
// //                     height: 28.w,
// //                     decoration: BoxDecoration(
// //                       color: Colors.black87,
// //                       borderRadius: BorderRadius.circular(6.r),
// //                     ),
// //                     child: Center(
// //                       child: Icon(
// //                         Icons.grid_view_rounded,
// //                         size: 16.sp,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(width: 8.w),
// //                   Text(
// //                     'mygate',
// //                     style: TextStyle(
// //                       fontSize: 20.sp,
// //                       fontWeight: FontWeight.w800,
// //                       color: Colors.black87,
// //                       letterSpacing: -0.5,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 10.h),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   GestureDetector(
// //                     onTap: () {},
// //                     child: Text(
// //                       'Terms & Conditions',
// //                       style: TextStyle(
// //                         fontSize: 12.sp,
// //                         color: const Color(0xFF1A73E8),
// //                         decoration: TextDecoration.underline,
// //                       ),
// //                     ),
// //                   ),
// //                   Padding(
// //                     padding: EdgeInsets.symmetric(horizontal: 8.w),
// //                     child: Text(
// //                       '|',
// //                       style: TextStyle(fontSize: 12.sp, color: Colors.black38),
// //                     ),
// //                   ),
// //                   GestureDetector(
// //                     onTap: () {},
// //                     child: Text(
// //                       'Privacy Policy',
// //                       style: TextStyle(
// //                         fontSize: 12.sp,
// //                         color: const Color(0xFF1A73E8),
// //                         decoration: TextDecoration.underline,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 6.h),
// //               Text(
// //                 'Version 7.27.1',
// //                 style: TextStyle(fontSize: 11.sp, color: Colors.black38),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
