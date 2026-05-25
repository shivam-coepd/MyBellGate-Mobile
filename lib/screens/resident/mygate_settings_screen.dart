import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _flashApprovalsEnabled = true;
  String _selectedLanguage = 'English';
  final double _profileCompletion = 0.85;

  final List<Map<String, dynamic>> _householdItems = [
    {'icon': Icons.family_restroom_outlined, 'label': 'Family'},
    {'icon': Icons.support_agent_outlined, 'label': 'Daily Help'},
    {'icon': Icons.directions_car_outlined, 'label': 'Vehicles'},
    {'icon': Icons.pets_outlined, 'label': 'Pets'},
  ];

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

  void _showAddFamilySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddFamilyBottomSheet(),
    );
  }

  void _showAddDailyHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddDailyHelpBottomSheet(),
    );
  }

  void _showAddVehicleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddVehicleBottomSheet(),
    );
  }

  void _showAddPetSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPetBottomSheet(),
    );
  }

  void _showAddHouseholdDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Household',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20.h),
              _buildAddOption(
                Icons.family_restroom,
                'Family Member',
                'Add adult or kid',
                () {
                  Navigator.pop(context);
                  _showAddFamilySheet();
                },
              ),
              _buildAddOption(
                Icons.support_agent,
                'Daily Help',
                'Maid, cook, driver, etc.',
                () {
                  Navigator.pop(context);
                  _showAddDailyHelpSheet();
                },
              ),
              _buildAddOption(
                Icons.directions_car,
                'Vehicle',
                'Car, bike, scooter',
                () {
                  Navigator.pop(context);
                  _showAddVehicleSheet();
                },
              ),
              _buildAddOption(Icons.pets, 'Pet', 'Dog, cat, or other pets', () {
                Navigator.pop(context);
                _showAddPetSheet();
              }),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1B5E20)),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

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

  void _navigateTo(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader(theme)),
          SliverToBoxAdapter(child: _buildHouseholdSection(theme)),
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
                  'Flash Approvals ${value ? "enabled" : "disabled"}',
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
          SliverToBoxAdapter(child: _buildFooter(theme)),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Row(
            children: [
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
                onTap: () {
                  switch (item['label']) {
                    case 'Family':
                      _showAddFamilySheet();
                      break;
                    case 'Daily Help':
                      _showAddDailyHelpSheet();
                      break;
                    case 'Vehicles':
                      _showAddVehicleSheet();
                      break;
                    case 'Pets':
                      _showAddPetSheet();
                      break;
                  }
                },
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
          splashColor: theme.colorScheme.surfaceContainer.withValues(
            alpha: 0.3,
          ),
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
                  activeThumbColor: theme.colorScheme.onPrimary,
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
          splashColor: theme.colorScheme.surfaceContainer.withValues(
            alpha: 0.3,
          ),
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
          splashColor: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
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

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
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
// ADD FAMILY BOTTOM SHEET (with Contacts Integration)
// ============================================
class AddFamilyBottomSheet extends StatefulWidget {
  const AddFamilyBottomSheet({super.key});

  @override
  State<AddFamilyBottomSheet> createState() => _AddFamilyBottomSheetState();
}

class _AddFamilyBottomSheetState extends State<AddFamilyBottomSheet> {
  int _selectedTab = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final String _selectedCountryCode = '+91';
  XFile? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    try {
      // Request permission using v2 API
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      if (status == PermissionStatus.granted) {
        final Contact? contact = await FlutterContacts.native.showPicker(
          properties: {ContactProperty.name, ContactProperty.phone},
        );
        if (contact != null) {
          setState(() {
            _nameController.text = contact.displayName ?? '';
            if (contact.phones.isNotEmpty) {
              String phone = contact.phones.first.number.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );
              if (phone.startsWith('91') && phone.length > 10) {
                phone = phone.substring(2);
              }
              _mobileController.text = phone;
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacts permission denied')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking contact: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  void _addFamily() {
    if (_nameController.text.isEmpty || _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nameController.text} added to family')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Add Family',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Column(
                          children: [
                            Text(
                              'Adult',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: _selectedTab == 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _selectedTab == 0
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 3,
                              color: _selectedTab == 0
                                  ? const Color(0xFF1B5E20)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Column(
                          children: [
                            Text(
                              'Kid',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: _selectedTab == 1
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _selectedTab == 1
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 3,
                              color: _selectedTab == 1
                                  ? const Color(0xFF1B5E20)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        image: _pickedImage != null
                            ? DecorationImage(
                                image: FileImage(File(_pickedImage!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _pickedImage == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 48.h,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      IconButton(
                        icon: Icon(Icons.contacts, color: Colors.grey.shade600),
                        onPressed: _pickContact,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedCountryCode,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Mobile Number',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: GestureDetector(
                  onTap: _addFamily,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD600),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: const Color(0xFF1B5E20)),
                        SizedBox(width: 8.w),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// ADD DAILY HELP BOTTOM SHEET
// ============================================
class AddDailyHelpBottomSheet extends StatefulWidget {
  const AddDailyHelpBottomSheet({super.key});

  @override
  State<AddDailyHelpBottomSheet> createState() =>
      _AddDailyHelpBottomSheetState();
}

class _AddDailyHelpBottomSheetState extends State<AddDailyHelpBottomSheet> {
  int _selectedTab = 0;
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String _selectedDate = 'Today';
  String _selectedDuration = '1 Hour';
  String _selectedCompany = 'Select Company';

  final List<String> _categories = [
    'Home repair',
    'Appliance repair',
    'Internet repair',
    'Beautician',
    'Tutor',
    'Others',
  ];
  final List<String> _durations = [
    '30 min',
    '1 Hour',
    '2 Hours',
    '4 Hours',
    '8 Hours',
  ];
  final List<String> _companies = [
    'Urban Company',
    'Housejoy',
    'Local Service',
    'Others',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    try {
      // 1. Request permission using built-in v2 API
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      if (status == PermissionStatus.granted) {
        // 2. Show native picker - returns Contact?
        final contact = await FlutterContacts.native.showPicker(
          properties: {ContactProperty.name, ContactProperty.phone},
        );

        if (contact != null) {
          setState(() {
            _nameController.text = contact.displayName ?? '';
            if (contact.phones.isNotEmpty) {
              String phone = contact.phones.first.number.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );
              // if (phone.startsWith('91') && phone.length > 10) {
              //   phone = phone.substring(2);
              // }
              _mobileController.text = phone;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.h),
                child: Text(
                  'VISITING HELP CATEGORY',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ),
              ..._categories.map(
                (cat) => ListTile(
                  title: Text(cat, style: TextStyle(fontSize: 16.sp)),
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showDropdown(
    String title,
    List<String> items,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.h),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...items.map(
                (item) => ListTile(
                  title: Text(item, style: TextStyle(fontSize: 16.sp)),
                  onTap: () {
                    onSelect(item);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _addDailyHelp() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_nameController.text.isEmpty ? "Daily Help" : _nameController.text} added',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 16.h),
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD600),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.build,
                  color: const Color(0xFF1B5E20),
                  size: 28,
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Column(
                          children: [
                            Text(
                              'Once',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: _selectedTab == 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _selectedTab == 0
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 3,
                              color: _selectedTab == 0
                                  ? const Color(0xFF1B5E20)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Column(
                          children: [
                            Text(
                              'Frequently',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: _selectedTab == 1
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _selectedTab == 1
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 3,
                              color: _selectedTab == 1
                                  ? const Color(0xFF1B5E20)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              if (_selectedCategory == null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: GestureDetector(
                    onTap: _showCategoryPicker,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allow my visiting help',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        Text(
                          _selectedCategory!,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                        Text(
                          'to enter today once in next',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: GestureDetector(
                  onTap: () => _showDropdown(
                    'Valid for',
                    _durations,
                    (val) => setState(() => _selectedDuration = val),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDuration,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF1B5E20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showDropdown(
                          'Select Date',
                          ['Today', 'Tomorrow', 'Custom'],
                          (val) => setState(() => _selectedDate = val),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: const Color(0xFF1B5E20),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showDropdown(
                          'Valid for',
                          _durations,
                          (val) => setState(() => _selectedDuration = val),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDuration,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: const Color(0xFF1B5E20),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: GestureDetector(
                  onTap: () => _showDropdown(
                    'Company Name',
                    _companies,
                    (val) => setState(() => _selectedCompany = val),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCompany,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _selectedCompany == 'Select Company'
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF1B5E20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.contacts),
                      onPressed: _pickContact,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: _addDailyHelp,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD600),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: const Color(0xFF1B5E20),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// ADD VEHICLE BOTTOM SHEET
// ============================================
class AddVehicleBottomSheet extends StatefulWidget {
  const AddVehicleBottomSheet({super.key});

  @override
  State<AddVehicleBottomSheet> createState() => _AddVehicleBottomSheetState();
}

class _AddVehicleBottomSheetState extends State<AddVehicleBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  String _vehicleType = '';
  String _isElectric = '';
  XFile? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  void _addVehicle() {
    if (_nameController.text.isEmpty ||
        _numberController.text.isEmpty ||
        _vehicleType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nameController.text} added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Add Vehicle',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        image: _pickedImage != null
                            ? DecorationImage(
                                image: FileImage(File(_pickedImage!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _pickedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            )
                          : null,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Name eg. My Car',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TextField(
                  controller: _numberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter Vehicle Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vehicle type',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _vehicleType = '2'),
                        child: Row(
                          children: [
                            Icon(
                              _vehicleType == '2'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _vehicleType == '2'
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '2 Wheeler',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _vehicleType = '4'),
                        child: Row(
                          children: [
                            Icon(
                              _vehicleType == '4'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _vehicleType == '4'
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '4 Wheeler',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Is it an electric vehicle?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isElectric = 'yes'),
                        child: Row(
                          children: [
                            Icon(
                              _isElectric == 'yes'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _isElectric == 'yes'
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Text('Yes', style: TextStyle(fontSize: 15.sp)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isElectric = 'no'),
                        child: Row(
                          children: [
                            Icon(
                              _isElectric == 'no'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _isElectric == 'no'
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Text('No', style: TextStyle(fontSize: 15.sp)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              GestureDetector(
                onTap: _addVehicle,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD600),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: const Color(0xFF1B5E20)),
                        SizedBox(width: 8.w),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// ADD PET BOTTOM SHEET
// ============================================
class AddPetBottomSheet extends StatefulWidget {
  const AddPetBottomSheet({super.key});

  @override
  State<AddPetBottomSheet> createState() => _AddPetBottomSheetState();
}

class _AddPetBottomSheetState extends State<AddPetBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  String _petType = '';
  XFile? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  void _addPet() {
    if (_nameController.text.isEmpty || _petType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nameController.text} added to pets')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Add Pet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        image: _pickedImage != null
                            ? DecorationImage(
                                image: FileImage(File(_pickedImage!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _pickedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            )
                          : null,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Pet's Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TextField(
                  controller: _breedController,
                  decoration: InputDecoration(
                    hintText: 'Breed (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pet Type',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _petType = 'dog'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _petType == 'dog'
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey.shade300,
                              width: _petType == 'dog' ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _petType == 'dog'
                                ? const Color(0xFFFFF9C4)
                                : Colors.white,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets,
                                color: _petType == 'dog'
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey,
                              ),
                              SizedBox(height: 4.h),
                              Text('Dog', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _petType = 'cat'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _petType == 'cat'
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey.shade300,
                              width: _petType == 'cat' ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _petType == 'cat'
                                ? const Color(0xFFFFF9C4)
                                : Colors.white,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets,
                                color: _petType == 'cat'
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey,
                              ),
                              SizedBox(height: 4.h),
                              Text('Cat', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _petType = 'other'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _petType == 'other'
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey.shade300,
                              width: _petType == 'other' ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _petType == 'other'
                                ? const Color(0xFFFFF9C4)
                                : Colors.white,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets,
                                color: _petType == 'other'
                                    ? const Color(0xFF1B5E20)
                                    : Colors.grey,
                              ),
                              SizedBox(height: 4.h),
                              Text('Other', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              GestureDetector(
                onTap: _addPet,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD600),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: const Color(0xFF1B5E20)),
                        SizedBox(width: 8.w),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// SUB SCREEN
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
          preferredSize: const Size.fromHeight(1),
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






// # Let me write the complete code to a file directly in parts
// part1 = """import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:contacts_service/contacts_service.dart';

// // ============================================
// // CONTACT MODEL
// // ============================================
// class ContactInfo {
//   final String name;
//   final String phoneNumber;
//   final String? photoUri;

//   ContactInfo({required this.name, required this.phoneNumber, this.photoUri});
// }

// // ============================================
// // SETTINGS SCREEN
// // ============================================
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   // State variables
//   bool _flashApprovalsEnabled = true;
//   String _selectedLanguage = 'English';
//   double _profileCompletion = 0.85;
//   bool _isLoading = false;

//   // Household items data with specific add actions
//   final List<Map<String, dynamic>> _householdItems = [
//     {
//       'icon': Icons.family_restroom_outlined,
//       'label': 'Family',
//       'onTap': 'family',
//       'color': const Color(0xFFFFD700),
//     },
//     {
//       'icon': Icons.support_agent_outlined,
//       'label': 'Daily Help',
//       'onTap': 'dailyHelp',
//       'color': const Color(0xFFFFD700),
//     },
//     {
//       'icon': Icons.directions_car_outlined,
//       'label': 'Vehicles',
//       'onTap': 'vehicles',
//       'color': const Color(0xFFFFD700),
//     },
//     {
//       'icon': Icons.pets_outlined,
//       'label': 'Pets',
//       'onTap': 'pets',
//       'color': const Color(0xFFFFD700),
//     },
//   ];

//   // Show snackbar helper
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   // ============================================
//   // CONTACTS INTEGRATION
//   // ============================================
//   Future<void> _requestContactsPermission() async {
//     final status = await Permission.contacts.request();
//     if (status.isGranted) {
//       _showSnackBar('Contacts permission granted');
//     } else {
//       _showSnackBar('Contacts permission denied');
//     }
//   }

//   Future<List<ContactInfo>> _fetchContacts() async {
//     final contacts = await ContactsService.getContacts();
//     return contacts
//         .where((c) => c.displayName != null && c.phones != null && c.phones!.isNotEmpty)
//         .map((c) => ContactInfo(
//               name: c.displayName!,
//               phoneNumber: c.phones!.first.value ?? '',
//               photoUri: c.avatar != null && c.avatar!.isNotEmpty ? 'has_photo' : null,
//             ))
//         .toList();
//   }

//   void _showContactPicker({required Function(ContactInfo) onContactSelected}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Text(
//                 'Select Contact',
//                 style: TextStyle(
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: FutureBuilder<List<ContactInfo>>(
//                 future: _fetchContacts(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(child: Text('No contacts found'));
//                   }
//                   final contacts = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: contacts.length,
//                     itemBuilder: (context, index) {
//                       final contact = contacts[index];
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
//                           child: Text(
//                             contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
//                             style: const TextStyle(color: Color(0xFFB8860B)),
//                           ),
//                         ),
//                         title: Text(contact.name, style: TextStyle(fontSize: 16.sp)),
//                         subtitle: Text(contact.phoneNumber, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
//                         onTap: () {
//                           Navigator.pop(context);
//                           onContactSelected(contact);
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// """

// with open('/mnt/agents/output/settings_screen_part1.dart', 'w') as f:
//     f.write(part1)

// print("Part 1 written successfully")


// part2 = """
//   // ============================================
//   // ADD FAMILY BOTTOM SHEET
//   // ============================================
//   void _showAddFamilySheet() {
//     final nameController = TextEditingController();
//     final mobileController = TextEditingController();
//     String selectedType = 'Adult';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setSheetState) {
//           return Container(
//             margin: EdgeInsets.only(top: 60.h),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header with close button
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.close, color: Colors.white),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                       Expanded(
//                         child: Text(
//                           'Add Family',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20.sp,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 48.w),
//                     ],
//                   ),
//                 ),
//                 // Tab selector
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 24.w),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => setSheetState(() => selectedType = 'Adult'),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Adult',
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: selectedType == 'Adult' ? FontWeight.w600 : FontWeight.w400,
//                                   color: selectedType == 'Adult' ? const Color(0xFF1A3C40) : Colors.grey,
//                                 ),
//                               ),
//                               SizedBox(height: 8.h),
//                               Container(
//                                 height: 3,
//                                 color: selectedType == 'Adult' ? const Color(0xFF1A3C40) : Colors.transparent,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => setSheetState(() => selectedType = 'Kid'),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Kid',
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: selectedType == 'Kid' ? FontWeight.w600 : FontWeight.w400,
//                                   color: selectedType == 'Kid' ? const Color(0xFF1A3C40) : Colors.grey,
//                                 ),
//                               ),
//                               SizedBox(height: 8.h),
//                               Container(
//                                 height: 3,
//                                 color: selectedType == 'Kid' ? const Color(0xFF1A3C40) : Colors.transparent,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//                 // Photo placeholder
//                 Container(
//                   width: 100.w,
//                   height: 100.w,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
//                 ),
//                 SizedBox(height: 8.h),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFD700),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     'ADD',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xFF1A3C40),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//                 // Name field with contacts icon
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.w),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey[300]!),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: nameController,
//                             decoration: InputDecoration(
//                               hintText: 'Name',
//                               hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.contacts, color: Colors.grey[600]),
//                           onPressed: () async {
//                             await _requestContactsPermission();
//                             _showContactPicker(
//                               onContactSelected: (contact) {
//                                 setSheetState(() {
//                                   nameController.text = contact.name;
//                                   mobileController.text = contact.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
//                                 });
//                               },
//                             );
//                           },
//                         ),
//                         SizedBox(width: 8.w),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 // Mobile field
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.w),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey[300]!),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           '+91',
//                           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey[300]!),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: TextField(
//                             controller: mobileController,
//                             keyboardType: TextInputType.phone,
//                             decoration: InputDecoration(
//                               hintText: 'Mobile Number',
//                               hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 32.h),
//                 // Add button
//                 GestureDetector(
//                   onTap: () {
//                     if (nameController.text.isNotEmpty && mobileController.text.isNotEmpty) {
//                       Navigator.pop(context);
//                       _showSnackBar('Family member added: ' + nameController.text);
//                     } else {
//                       _showSnackBar('Please fill all fields');
//                     }
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     margin: EdgeInsets.symmetric(horizontal: 24.w),
//                     padding: EdgeInsets.symmetric(vertical: 16.h),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFD700),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add, color: const Color(0xFF1A3C40)),
//                         SizedBox(width: 8.w),
//                         Text(
//                           'Add',
//                           style: TextStyle(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xFF1A3C40),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// """


// part3 = """
//   // ============================================
//   // ADD VEHICLE BOTTOM SHEET
//   // ============================================
//   void _showAddVehicleSheet() {
//     final nameController = TextEditingController();
//     final numberController = TextEditingController();
//     String vehicleType = '';
//     String isElectric = '';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setSheetState) {
//           return Container(
//             margin: EdgeInsets.only(top: 60.h),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.close, color: Colors.white),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         Expanded(
//                           child: Text(
//                             'Add Vehicle',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 20.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 48.w),
//                       ],
//                     ),
//                   ),
//                   // Photo placeholder
//                   Container(
//                     width: 100.w,
//                     height: 100.w,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
//                   ),
//                   SizedBox(height: 8.h),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFD700),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       'Add',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF1A3C40),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Name field
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: nameController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter Name eg. My Car',
//                           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   // Vehicle number field
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: numberController,
//                         textCapitalization: TextCapitalization.characters,
//                         decoration: InputDecoration(
//                           hintText: 'Enter Vehicle Number',
//                           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Vehicle type
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Vehicle type',
//                         style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => vehicleType = '2'),
//                             child: Row(
//                               children: [
//                                 Radio(
//                                   value: '2',
//                                   groupValue: vehicleType,
//                                   onChanged: (v) => setSheetState(() => vehicleType = v.toString()),
//                                   activeColor: const Color(0xFF1A3C40),
//                                 ),
//                                 Text('2 Wheeler', style: TextStyle(fontSize: 14.sp)),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => vehicleType = '4'),
//                             child: Row(
//                               children: [
//                                 Radio(
//                                   value: '4',
//                                   groupValue: vehicleType,
//                                   onChanged: (v) => setSheetState(() => vehicleType = v.toString()),
//                                   activeColor: const Color(0xFF1A3C40),
//                                 ),
//                                 Text('4 Wheeler', style: TextStyle(fontSize: 14.sp)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Electric vehicle
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Is it an electric vehicle?',
//                         style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => isElectric = 'yes'),
//                             child: Row(
//                               children: [
//                                 Radio(
//                                   value: 'yes',
//                                   groupValue: isElectric,
//                                   onChanged: (v) => setSheetState(() => isElectric = v.toString()),
//                                   activeColor: const Color(0xFF1A3C40),
//                                 ),
//                                 Text('Yes', style: TextStyle(fontSize: 14.sp)),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => isElectric = 'no'),
//                             child: Row(
//                               children: [
//                                 Radio(
//                                   value: 'no',
//                                   groupValue: isElectric,
//                                   onChanged: (v) => setSheetState(() => isElectric = v.toString()),
//                                   activeColor: const Color(0xFF1A3C40),
//                                 ),
//                                 Text('No', style: TextStyle(fontSize: 14.sp)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 32.h),
//                   // Add button
//                   GestureDetector(
//                     onTap: () {
//                       if (nameController.text.isNotEmpty && numberController.text.isNotEmpty && vehicleType.isNotEmpty) {
//                         Navigator.pop(context);
//                         _showSnackBar('Vehicle added: ' + nameController.text);
//                       } else {
//                         _showSnackBar('Please fill all required fields');
//                       }
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       margin: EdgeInsets.symmetric(horizontal: 24.w),
//                       padding: EdgeInsets.symmetric(vertical: 16.h),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFD700),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add, color: const Color(0xFF1A3C40)),
//                           SizedBox(width: 8.w),
//                           Text(
//                             'Add',
//                             style: TextStyle(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xFF1A3C40),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// """

// with open('/mnt/agents/output/settings_screen_part3.dart', 'w') as f:
//     f.write(part3)

// print("Part 3 written successfully")



// part4 = """
//   // ============================================
//   // ADD DAILY HELP BOTTOM SHEET
//   // ============================================
//   void _showAddDailyHelpSheet() {
//     final categories = [
//       'Home repair',
//       'Appliance repair',
//       'Internet repair',
//       'Beautician',
//       'Tutor',
//       'Others',
//     ];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         margin: EdgeInsets.only(top: 100.h),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Floating icon
//             Transform.translate(
//               offset: Offset(0, -30.h),
//               child: Container(
//                 width: 60.w,
//                 height: 60.w,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFFFD700),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.build, color: const Color(0xFF1A3C40), size: 28),
//               ),
//             ),
//             Text(
//               'VISITING HELP CATEGORY',
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[500],
//                 letterSpacing: 1.2,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             // Category list
//             ...categories.map((category) => Column(
//               children: [
//                 ListTile(
//                   title: Text(
//                     category,
//                     style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _showDailyHelpEntrySheet(category: category);
//                   },
//                 ),
//                 Divider(height: 1, color: Colors.grey[200]),
//               ],
//             )),
//             SizedBox(height: 24.h),
//           ],
//         ),
//       ),
//     );
//   }

//   // Daily Help Entry Sheet (Once/Frequently)
//   void _showDailyHelpEntrySheet({required String category}) {
//     String selectedTab = 'Once';
//     String selectedDuration = '1 Hour';
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setSheetState) {
//           return Container(
//             margin: EdgeInsets.only(top: 80.h),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Floating icon
//                   Transform.translate(
//                     offset: Offset(0, -30.h),
//                     child: Container(
//                       width: 60.w,
//                       height: 60.w,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFFFD700),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(Icons.build, color: const Color(0xFF1A3C40), size: 28),
//                     ),
//                   ),
//                   // Tabs
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => selectedTab = 'Once'),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Once',
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: selectedTab == 'Once' ? FontWeight.w600 : FontWeight.w400,
//                                     color: selectedTab == 'Once' ? const Color(0xFF1A3C40) : Colors.grey,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Container(
//                                   height: 3,
//                                   color: selectedTab == 'Once' ? const Color(0xFF1A3C40) : Colors.transparent,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => selectedTab = 'Frequently'),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Frequently',
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: selectedTab == 'Frequently' ? FontWeight.w600 : FontWeight.w400,
//                                     color: selectedTab == 'Frequently' ? const Color(0xFF1A3C40) : Colors.grey,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Container(
//                                   height: 3,
//                                   color: selectedTab == 'Frequently' ? const Color(0xFF1A3C40) : Colors.transparent,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Description text
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: RichText(
//                       text: TextSpan(
//                         style: TextStyle(fontSize: 18.sp, color: Colors.black87, height: 1.5),
//                         children: [
//                           const TextSpan(text: 'Allow my visiting help '),
//                           TextSpan(
//                             text: category,
//                             style: const TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
//                           ),
//                           const TextSpan(text: ' to enter '),
//                           const TextSpan(
//                             text: 'today',
//                             style: TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
//                           ),
//                           const TextSpan(text: ' once in next'),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   // Duration dropdown
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: selectedDuration,
//                           isExpanded: true,
//                           icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF1A3C40)),
//                           items: ['1 Hour', '2 Hours', '4 Hours', '8 Hours', '12 Hours', '24 Hours']
//                               .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 16.sp))))
//                               .toList(),
//                           onChanged: (v) => setSheetState(() => selectedDuration = v!),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   // Advanced Options
//                   GestureDetector(
//                     onTap: () => _showAdvancedOptionsSheet(
//                       category: category,
//                       selectedTab: selectedTab,
//                       onSave: (data) {
//                         Navigator.pop(context);
//                         _showSnackBar('Daily help entry approved for $category');
//                       },
//                     ),
//                     child: Text(
//                       'Advanced Options >>',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w500,
//                         color: const Color(0xFF1A3C40),
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Confirm button
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                       _showSnackBar('Entry approved for $category');
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       margin: EdgeInsets.symmetric(horizontal: 24.w),
//                       padding: EdgeInsets.symmetric(vertical: 16.h),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFD700),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Icon(Icons.check, color: const Color(0xFF1A3C40), size: 28),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Advanced Options Sheet
//   void _showAdvancedOptionsSheet({
//     required String category,
//     required String selectedTab,
//     required Function(Map<String, dynamic>) onSave,
//   }) {
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();
//     String selectedDate = 'Today';
//     String startTime = '05:33 pm';
//     String validFor = '1 Hour';
//     String company = 'Select Company';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setSheetState) {
//           return Container(
//             margin: EdgeInsets.only(top: 60.h),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Floating icon
//                   Transform.translate(
//                     offset: Offset(0, -30.h),
//                     child: Container(
//                       width: 60.w,
//                       height: 60.w,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFFFD700),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(Icons.build, color: const Color(0xFF1A3C40), size: 28),
//                     ),
//                   ),
//                   // Tabs
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() {}),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Once',
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: const Color(0xFF1A3C40),
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Container(height: 3, color: const Color(0xFF1A3C40)),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {},
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Frequently',
//                                   style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Container(height: 3, color: Colors.transparent),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Select Date
//                   _buildLabel('Select Date'),
//                   SizedBox(height: 8.h),
//                   _buildDropdown(
//                     value: selectedDate,
//                     items: ['Today', 'Tomorrow', 'Custom'],
//                     onChanged: (v) => setSheetState(() => selectedDate = v!),
//                   ),
//                   SizedBox(height: 16.h),
//                   // Starting from & Valid for
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildLabel('Starting from'),
//                               SizedBox(height: 8.h),
//                               _buildDropdown(
//                                 value: startTime,
//                                 items: ['05:33 pm', '06:00 pm', '07:00 pm', '08:00 pm'],
//                                 onChanged: (v) => setSheetState(() => startTime = v!),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: 16.w),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildLabel('Valid for'),
//                               SizedBox(height: 8.h),
//                               _buildDropdown(
//                                 value: validFor,
//                                 items: ['1 Hour', '2 Hours', '4 Hours', '8 Hours'],
//                                 onChanged: (v) => setSheetState(() => validFor = v!),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   // Company Name
//                   _buildLabel('Company Name'),
//                   SizedBox(height: 8.h),
//                   _buildDropdown(
//                     value: company,
//                     items: ['Select Company', 'Urban Company', 'Local Service', 'Other'],
//                     onChanged: (v) => setSheetState(() => company = v!),
//                   ),
//                   SizedBox(height: 32.h),
//                   // Confirm button
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                       onSave({
//                         'category': category,
//                         'date': selectedDate,
//                         'time': startTime,
//                         'duration': validFor,
//                         'company': company,
//                       });
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       margin: EdgeInsets.symmetric(horizontal: 24.w),
//                       padding: EdgeInsets.symmetric(vertical: 16.h),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFD700),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Icon(Icons.check, color: const Color(0xFF1A3C40), size: 28),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           text,
//           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.grey[700]),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown({
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: value,
//             isExpanded: true,
//             icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF1A3C40)),
//             items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 16.sp)))).toList(),
//             onChanged: onChanged,
//           ),
//         ),
//       ),
//     );
//   }
// """

// with open('/mnt/agents/output/settings_screen_part4.dart', 'w') as f:
//     f.write(part4)

// print("Part 4 written successfully")



// part5 = """
//   // ============================================
//   // ADD PET BOTTOM SHEET
//   // ============================================
//   void _showAddPetSheet() {
//     final nameController = TextEditingController();
//     final breedController = TextEditingController();
//     String petType = '';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setSheetState) {
//           return Container(
//             margin: EdgeInsets.only(top: 60.h),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.close, color: Colors.white),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         Expanded(
//                           child: Text(
//                             'Add Pet',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 20.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 48.w),
//                       ],
//                     ),
//                   ),
//                   // Photo placeholder
//                   Container(
//                     width: 100.w,
//                     height: 100.w,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.pets, size: 40, color: Colors.grey[400]),
//                   ),
//                   SizedBox(height: 8.h),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFD700),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       'Add Photo',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF1A3C40),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Pet type selection
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => petType = 'dog'),
//                             child: Container(
//                               padding: EdgeInsets.all(16.w),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: petType == 'dog' ? const Color(0xFF1A3C40) : Colors.grey[300]!,
//                                   width: petType == 'dog' ? 2 : 1,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                                 color: petType == 'dog' ? const Color(0xFF1A3C40).withOpacity(0.05) : null,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Icon(Icons.pets, size: 32, color: petType == 'dog' ? const Color(0xFF1A3C40) : Colors.grey),
//                                   SizedBox(height: 8.h),
//                                   Text('Dog', style: TextStyle(fontSize: 14.sp)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 16.w),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => setSheetState(() => petType = 'cat'),
//                             child: Container(
//                               padding: EdgeInsets.all(16.w),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: petType == 'cat' ? const Color(0xFF1A3C40) : Colors.grey[300]!,
//                                   width: petType == 'cat' ? 2 : 1,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                                 color: petType == 'cat' ? const Color(0xFF1A3C40).withOpacity(0.05) : null,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Icon(Icons.pets, size: 32, color: petType == 'cat' ? const Color(0xFF1A3C40) : Colors.grey),
//                                   SizedBox(height: 8.h),
//                                   Text('Cat', style: TextStyle(fontSize: 14.sp)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   // Name field
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: nameController,
//                         decoration: InputDecoration(
//                           hintText: 'Pet Name',
//                           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   // Breed field
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: breedController,
//                         decoration: InputDecoration(
//                           hintText: 'Breed (Optional)',
//                           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 32.h),
//                   // Add button
//                   GestureDetector(
//                     onTap: () {
//                       if (nameController.text.isNotEmpty && petType.isNotEmpty) {
//                         Navigator.pop(context);
//                         _showSnackBar('Pet added: ' + nameController.text);
//                       } else {
//                         _showSnackBar('Please fill required fields');
//                       }
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       margin: EdgeInsets.symmetric(horizontal: 24.w),
//                       padding: EdgeInsets.symmetric(vertical: 16.h),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFD700),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add, color: const Color(0xFF1A3C40)),
//                           SizedBox(width: 8.w),
//                           Text(
//                             'Add',
//                             style: TextStyle(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xFF1A3C40),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ============================================
//   // HOUSEHOLD ITEM TAP HANDLER
//   // ============================================
//   void _handleHouseholdTap(String type) {
//     switch (type) {
//       case 'family':
//         _showAddFamilySheet();
//         break;
//       case 'dailyHelp':
//         _showAddDailyHelpSheet();
//         break;
//       case 'vehicles':
//         _showAddVehicleSheet();
//         break;
//       case 'pets':
//         _showAddPetSheet();
//         break;
//     }
//   }

//   // ============================================
//   // EXISTING METHODS (Language, Display, Logout, Help)
//   // ============================================
//   void _showLanguagePicker() {
//     final theme = Theme.of(context);
//     final languages = ['English', 'Hindi', 'Marathi', 'Gujarati', 'Tamil', 'Telugu'];
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: theme.colorScheme.onSurface,
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
//                 color: theme.colorScheme.onSurface,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Text(
//                 'Select Language',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   height: 28 / 20,
//                   letterSpacing: -0.01 * 20,
//                 ),
//               ),
//             ),
//             ...languages.map(
//               (lang) => ListTile(
//                 title: Text(
//                   lang,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                     height: 24 / 16,
//                     letterSpacing: 0,
//                   ),
//                 ),
//                 trailing: _selectedLanguage == lang
//                     ? Icon(Icons.check, color: theme.primaryColor, size: 20)
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

//   void _showDisplayModePicker() {
//     final theme = Theme.of(context);
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: theme.colorScheme.onSurface,
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
//               child: Text(
//                 'Display Mode',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   height: 28 / 20,
//                   letterSpacing: -0.01 * 20,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.light_mode_outlined, color: theme.colorScheme.outlineVariant),
//               title: Text('Light', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0)),
//               onTap: () { Navigator.pop(context); _showSnackBar('Light mode enabled'); },
//             ),
//             ListTile(
//               leading: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.outlineVariant),
//               title: Text('Dark', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0)),
//               onTap: () { Navigator.pop(context); _showSnackBar('Dark mode enabled'); },
//             ),
//             ListTile(
//               leading: Icon(Icons.settings_suggest_outlined, color: theme.colorScheme.outlineVariant),
//               title: Text('System Default', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0)),
//               onTap: () { Navigator.pop(context); _showSnackBar('System default mode enabled'); },
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog() {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.onSurface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text('Log Out', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 28 / 20, letterSpacing: -0.01 * 20, color: theme.colorScheme.error)),
//         content: Text('Are you sure you want to log out?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0, color: theme.colorScheme.outlineVariant)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _showSnackBar('Logged out successfully');
//             },
//             child: Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0, color: theme.colorScheme.error)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showHelpDialog() {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.onSurface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text('Help', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 28 / 20, letterSpacing: -0.01 * 20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Settings Help', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0, color: theme.colorScheme.onSurface)),
//             const SizedBox(height: 8),
//             Text('Manage your profile, household members, security preferences, and app settings from this screen.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0, color: theme.colorScheme.outlineVariant)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, letterSpacing: 0, color: theme.colorScheme.primary)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateTo(String title) {
//     setState(() => _isLoading = true);
//     Future.delayed(const Duration(milliseconds: 300), () {
//       setState(() => _isLoading = false);
//       Navigator.push(context, MaterialPageRoute(builder: (context) => SubScreen(title: title)));
//     });
//   }
// """

// with open('/mnt/agents/output/settings_screen_part5.dart', 'w') as f:
//     f.write(part5)

// print("Part 5 written successfully")









// with open('/mnt/agents/output/settings_screen_part2.dart', 'w') as f:
//     f.write(part2)

// print("Part 2 written successfully")


// complete_code_part2 = '''
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
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
//         slivers: [
//           // Profile Header
//           SliverToBoxAdapter(child: _buildProfileHeader(theme)),

//           // Household Section - UPDATED WITH BOTTOM SHEETS
//           SliverToBoxAdapter(child: _buildHouseholdSection(theme)),

//           // Security & Notifications
//           SliverToBoxAdapter(
//             child: _buildSectionHeader('Security & Notifications', theme),
//           ),
//           SliverToBoxAdapter(
//             child: _buildToggleItem(
//               icon: Icons.bolt_outlined,
//               title: 'Flash Approvals',
//               value: _flashApprovalsEnabled,
//               onChanged: (value) {
//                 setState(() => _flashApprovalsEnabled = value);
//                 _showSnackBar(
//                   'Flash Approvals ${value ? 'enabled' : 'disabled'}',
//                 );
//               },
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.notifications_outlined,
//               title: 'Notification Settings',
//               onTap: () => _navigateTo('Notification Settings'),
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.lock_outlined,
//               title: 'Security & Privacy',
//               onTap: () => _navigateTo('Security & Privacy'),
//               theme: theme,
//             ),
//           ),

//           // Purchases
//           SliverToBoxAdapter(child: _buildSectionHeader('Purchases', theme)),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.receipt_long_outlined,
//               title: 'Order History',
//               onTap: () => _navigateTo('Order History'),
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.credit_card_outlined,
//               title: 'Saved Payments',
//               onTap: () => _navigateTo('Saved Payments'),
//               theme: theme,
//             ),
//           ),

//           // Manage Flats
//           SliverToBoxAdapter(child: _buildSectionHeader('Manage Flats', theme)),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.apartment_outlined,
//               title: 'Unit 402 - Wing A',
//               subtitle: 'PRIMARY ADDRESS',
//               onTap: () => _navigateTo('Unit 402 - Wing A'),
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.domain_add_outlined,
//               title: 'Add New Property',
//               onTap: () => _navigateTo('Add New Property'),
//               theme: theme,
//             ),
//           ),

//           // General Settings
//           SliverToBoxAdapter(
//             child: _buildSectionHeader('General Settings', theme),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.language_outlined,
//               title: 'App Language',
//               trailing: _selectedLanguage,
//               onTap: _showLanguagePicker,
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.dark_mode_outlined,
//               title: 'Display Mode',
//               onTap: _showDisplayModePicker,
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.support_agent_outlined,
//               title: 'Support and Feedback',
//               onTap: () => _navigateTo('Support and Feedback'),
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildNavItem(
//               icon: Icons.share_outlined,
//               title: 'Share the App',
//               onTap: () => _navigateTo('Share the App'),
//               theme: theme,
//             ),
//           ),
//           SliverToBoxAdapter(child: _buildLogoutItem(theme)),

//           // Footer
//           SliverToBoxAdapter(child: _buildFooter(theme)),

//           // Bottom padding for nav bar
//           const SliverToBoxAdapter(child: SizedBox(height: 80)),
//         ],
//       ),
//     );
//   }

//   // UPDATED Household Section with bottom sheets
//   Widget _buildHouseholdSection(ThemeData theme) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 32.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'HOUSEHOLD',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w500,
//                   height: 16 / 12,
//                   letterSpacing: 0.05 * 12,
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   // Show a menu to choose what to add
//                   _showAddHouseholdMenu();
//                 },
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
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         height: 16 / 12,
//                         letterSpacing: 0.05 * 12,
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: _householdItems.map((item) {
//               return GestureDetector(
//                 onTap: () {
//                   // Open specific bottom sheet based on item type
//                   switch (item['label']) {
//                     case 'Family':
//                       _showAddFamilyBottomSheet();
//                       break;
//                     case 'Daily Help':
//                       _showAddDailyHelpBottomSheet();
//                       break;
//                     case 'Vehicles':
//                       _showAddVehicleBottomSheet();
//                       break;
//                     case 'Pets':
//                       _showAddPetBottomSheet();
//                       break;
//                   }
//                 },
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 52.w,
//                       height: 52.w,
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surfaceContainerLow,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         item['icon'],
//                         size: 28,
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       item['label'],
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         height: 16 / 12,
//                         letterSpacing: 0.05 * 12,
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 8.h),
//         ],
//       ),
//     );
//   }

//   // Add Household Menu (when tapping the + Add button)
//   void _showAddHouseholdMenu() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: EdgeInsets.only(top: 12.h),
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(24.w),
//               child: Text(
//                 'Add to Household',
//                 style: TextStyle(
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             _buildMenuItem(
//               icon: Icons.family_restroom_outlined,
//               label: 'Add Family Member',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showAddFamilyBottomSheet();
//               },
//             ),
//             _buildMenuItem(
//               icon: Icons.support_agent_outlined,
//               label: 'Add Daily Help',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showAddDailyHelpBottomSheet();
//               },
//             ),
//             _buildMenuItem(
//               icon: Icons.directions_car_outlined,
//               label: 'Add Vehicle',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showAddVehicleBottomSheet();
//               },
//             ),
//             _buildMenuItem(
//               icon: Icons.pets_outlined,
//               label: 'Add Pet',
//               onTap: () {
//                 Navigator.pop(context);
//                 _showAddPetBottomSheet();
//               },
//             ),
//             SizedBox(height: 24.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Container(
//         width: 40.w,
//         height: 40.w,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(icon, color: Colors.black87),
//       ),
//       title: Text(
//         label,
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       trailing: Icon(Icons.chevron_right, color: Colors.grey),
//       onTap: onTap,
//     );
//   }

//   // Profile Header Widget
//   Widget _buildProfileHeader(ThemeData theme) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 16.h),
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
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         color: theme.colorScheme.onSurface,
//                         child: Icon(
//                           Icons.person,
//                           color: theme.primaryColor,
//                           size: 40,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               // Name and ID
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Nilesh',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w400,
//                       height: 32 / 24,
//                       letterSpacing: -0.01 * 24,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'ID - 383 553',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       height: 16 / 12,
//                       letterSpacing: 0.05 * 12,
//                       color: theme.colorScheme.onSurfaceVariant,
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
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         height: 16 / 12,
//                         letterSpacing: 0.05 * 12,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                     Text(
//                       '85%',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         height: 16 / 12,
//                         letterSpacing: 0.05 * 12,
//                         color: theme.primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.onSurface,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//                 child: FractionallySizedBox(
//                   alignment: Alignment.centerLeft,
//                   widthFactor: _profileCompletion,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: theme.primaryColor,
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

//   // Section Header Widget
//   Widget _buildSectionHeader(String title, ThemeData theme) {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: 24.w,
//         right: 24.w,
//         top: 32.h,
//         bottom: 16.h,
//       ),
//       child: Text(
//         title.toUpperCase(),
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w500,
//           height: 16 / 12,
//           letterSpacing: 0.05 * 12,
//           color: theme.colorScheme.onSurfaceVariant,
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
//     required ThemeData theme,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => onChanged(!value),
//           splashColor: theme.colorScheme.surfaceContainer.withOpacity(0.3),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       icon,
//                       size: 20,
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                     SizedBox(width: 16.w),
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                         height: 24 / 16,
//                         letterSpacing: 0.01 * 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Switch(
//                   value: value,
//                   onChanged: onChanged,
//                   activeColor: theme.colorScheme.onPrimary,
//                   activeTrackColor: theme.colorScheme.primary,
//                   inactiveThumbColor: theme.colorScheme.primaryContainer,
//                   inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
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
//     required ThemeData theme,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           splashColor: theme.colorScheme.surfaceContainer.withOpacity(0.3),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       icon,
//                       size: 20,
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                     SizedBox(width: 16.w),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                             height: 24 / 16,
//                             letterSpacing: 0.01 * 16,
//                           ),
//                         ),
//                         if (subtitle != null)
//                           Text(
//                             subtitle,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               height: 16 / 12,
//                               letterSpacing: 0.05 * 12,
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
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           height: 16 / 12,
//                           letterSpacing: 0.05 * 12,
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
//   Widget _buildLogoutItem(ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _showLogoutDialog,
//           splashColor: theme.colorScheme.errorContainer.withOpacity(0.3),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//             child: Row(
//               children: [
//                 Icon(Icons.logout, size: 20, color: theme.colorScheme.error),
//                 SizedBox(width: 12.w),
//                 Text(
//                   'Log Out',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                     height: 24 / 16,
//                     letterSpacing: 0.01 * 16,
//                     color: theme.colorScheme.error,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Footer Widget
//   Widget _buildFooter(ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 40),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () => _navigateTo('About MyGateBell'),
//             child: Row(
//               spacing: 8.w,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/app_logo.png',
//                   height: 30.w,
//                   width: 30.w,
//                   fit: BoxFit.contain,
//                 ),
//                 Text(
//                   "MyGateBell",
//                   style: TextStyle(
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () => _navigateTo('Terms & Conditions'),
//                 child: Text(
//                   'Terms & Conditions',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     height: 16 / 12,
//                     letterSpacing: 0.05 * 12,
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Text(
//                   '|',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     height: 16 / 12,
//                     letterSpacing: 0.05 * 12,
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => _navigateTo('Privacy Policy'),
//                 child: Text(
//                   'Privacy Policy',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     height: 16 / 12,
//                     letterSpacing: 0.05 * 12,
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Version 4.12.0',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               height: 16 / 12,
//               letterSpacing: 0.05 * 12,
//               color: theme.colorScheme.onSurfaceVariant,
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
//     final theme = Theme.of(context);
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: theme.primaryColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w500,
//             height: 28 / 20,
//             letterSpacing: -0.01 * 20,
//           ),
//         ),
//         bottom: PreferredSize(
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
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//                 height: 32 / 24,
//                 letterSpacing: -0.02 * 24,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'This screen is under development',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//                 height: 24 / 16,
//                 letterSpacing: 0.01 * 16,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';

// // class SettingsScreen extends StatefulWidget {
// //   const SettingsScreen({super.key});

// //   @override
// //   State<SettingsScreen> createState() => _SettingsScreenState();
// // }

// // class _SettingsScreenState extends State<SettingsScreen> {
// //   // State variables for functionality
// //   bool _flashApprovalsEnabled = true;
// //   String _selectedLanguage = 'English';
// //   double _profileCompletion = 0.85;
// //   bool _isLoading = false;

// //   // Household items data
// //   final List<Map<String, dynamic>> _householdItems = [
// //     {'icon': Icons.family_restroom_outlined, 'label': 'Family'},
// //     {'icon': Icons.support_agent_outlined, 'label': 'Daily Help'},
// //     {'icon': Icons.directions_car_outlined, 'label': 'Vehicles'},
// //     {'icon': Icons.pets_outlined, 'label': 'Pets'},
// //   ];

// //   // Show snackbar helper
// //   void _showSnackBar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //         duration: const Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   // Show bottom sheet for language selection
// //   void _showLanguagePicker() {
// //     final theme = Theme.of(context);
// //     final languages = [
// //       'English',
// //       'Hindi',
// //       'Marathi',
// //       'Gujarati',
// //       'Tamil',
// //       'Telugu',
// //     ];
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: theme.colorScheme.onSurface,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
// //       ),
// //       builder: (context) => SafeArea(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               margin: const EdgeInsets.only(top: 12),
// //               width: 40,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: theme.colorScheme.onSurface,
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(24),
// //               child: Text(
// //                 'Select Language',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w500,
// //                   height: 28 / 20,
// //                   letterSpacing: -0.01 * 20,
// //                 ),
// //               ),
// //             ),
// //             ...languages.map(
// //               (lang) => ListTile(
// //                 title: Text(
// //                   lang,
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w400,
// //                     height: 24 / 16,
// //                     letterSpacing: 0,
// //                   ),
// //                 ),
// //                 trailing: _selectedLanguage == lang
// //                     ? Icon(Icons.check, color: theme.primaryColor, size: 20)
// //                     : null,
// //                 onTap: () {
// //                   setState(() => _selectedLanguage = lang);
// //                   Navigator.pop(context);
// //                   _showSnackBar('Language changed to $lang');
// //                 },
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // Show display mode picker
// //   void _showDisplayModePicker() {
// //     final theme = Theme.of(context);
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: theme.colorScheme.onSurface,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
// //       ),
// //       builder: (context) => SafeArea(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               margin: const EdgeInsets.only(top: 12),
// //               width: 40,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: theme.colorScheme.outlineVariant,
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(24),
// //               child: Text(
// //                 'Display Mode',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w500,
// //                   height: 28 / 20,
// //                   letterSpacing: -0.01 * 20,
// //                 ),
// //               ),
// //             ),
// //             ListTile(
// //               leading: Icon(
// //                 Icons.light_mode_outlined,
// //                 color: theme.colorScheme.outlineVariant,
// //               ),
// //               title: Text(
// //                 'Light',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w400,
// //                   height: 24 / 16,
// //                   letterSpacing: 0,
// //                 ),
// //               ),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 _showSnackBar('Light mode enabled');
// //               },
// //             ),
// //             ListTile(
// //               leading: Icon(
// //                 Icons.dark_mode_outlined,
// //                 color: theme.colorScheme.outlineVariant,
// //               ),
// //               title: Text(
// //                 'Dark',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w400,
// //                   height: 24 / 16,
// //                   letterSpacing: 0,
// //                 ),
// //               ),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 _showSnackBar('Dark mode enabled');
// //               },
// //             ),
// //             ListTile(
// //               leading: Icon(
// //                 Icons.settings_suggest_outlined,
// //                 color: theme.colorScheme.outlineVariant,
// //               ),
// //               title: Text(
// //                 'System Default',
// //                 style: TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w400,
// //                   height: 24 / 16,
// //                   letterSpacing: 0,
// //                 ),
// //               ),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 _showSnackBar('System default mode enabled');
// //               },
// //             ),
// //             const SizedBox(height: 16),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // Show logout confirmation
// //   void _showLogoutDialog() {
// //     final theme = Theme.of(context);
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         backgroundColor: theme.colorScheme.onSurface,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         title: Text(
// //           'Log Out',
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w500,
// //             height: 28 / 20,
// //             letterSpacing: -0.01 * 20,
// //             color: theme.colorScheme.error,
// //           ),
// //         ),
// //         content: Text(
// //           'Are you sure you want to log out?',
// //           style: TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w400,
// //             height: 24 / 16,
// //             letterSpacing: 0,
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text(
// //               'Cancel',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0,
// //                 color: theme.colorScheme.outlineVariant,
// //               ),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               _showSnackBar('Logged out successfully');
// //               // Navigate to login screen
// //             },
// //             child: Text(
// //               'Log Out',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0,
// //                 color: theme.colorScheme.error,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Show add household item dialog
// //   void _showAddHouseholdDialog() {
// //     final theme = Theme.of(context);
// //     final TextEditingController controller = TextEditingController();
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         backgroundColor: theme.colorScheme.onSurface,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         title: Text(
// //           'Add to Household',
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w500,
// //             height: 28 / 20,
// //             letterSpacing: -0.01 * 20,
// //           ),
// //         ),
// //         content: TextField(
// //           controller: controller,
// //           style: TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w400,
// //             height: 24 / 16,
// //             letterSpacing: 0,
// //           ),
// //           decoration: InputDecoration(
// //             hintText: 'Enter item name',
// //             hintStyle: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w400,
// //               height: 24 / 16,
// //               letterSpacing: 0,
// //               color: theme.colorScheme.outline,
// //             ),
// //             border: UnderlineInputBorder(
// //               borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
// //             ),
// //             focusedBorder: UnderlineInputBorder(
// //               borderSide: BorderSide(color: theme.colorScheme.primary),
// //             ),
// //           ),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text(
// //               'Cancel',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0,
// //                 color: theme.colorScheme.outlineVariant,
// //               ),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               if (controller.text.isNotEmpty) {
// //                 Navigator.pop(context);
// //                 _showSnackBar('\'${controller.text}\' added to household');
// //               }
// //             },
// //             child: Text(
// //               'Add',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0,
// //                 color: theme.colorScheme.primary,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Show help dialog
// //   void _showHelpDialog() {
// //     final theme = Theme.of(context);
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         backgroundColor: theme.colorScheme.onSurface,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         title: Text(
// //           'Help',
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w500,
// //             height: 28 / 20,
// //             letterSpacing: -0.01 * 20,
// //           ),
// //         ),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               'Settings Help',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0,
// //                 color: theme.colorScheme.onSurface,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'Manage your profile, household members, security preferences, and app settings from this screen.',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0,
// //                 color: theme.colorScheme.outlineVariant,
// //               ),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text(
// //               'Got it',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0,
// //                 color: theme.colorScheme.primary,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Navigate to screen with loading simulation
// //   void _navigateTo(String title) {
// //     setState(() => _isLoading = true);
// //     Future.delayed(const Duration(milliseconds: 300), () {
// //       setState(() => _isLoading = false);
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(builder: (context) => SubScreen(title: title)),
// //       );
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     return Scaffold(
// //       backgroundColor: theme.scaffoldBackgroundColor,
// //       appBar: AppBar(
// //         title: Text("Settings"),
// //         actions: [
// //           IconButton(
// //             onPressed: () => _showHelpDialog(),
// //             icon: Icon(Icons.help_outline),
// //           ),
// //         ],
// //       ),
// //       body: CustomScrollView(
// //         // physics: const BouncingScrollPhysics(),
// //         slivers: [
// //           // Profile Header
// //           SliverToBoxAdapter(child: _buildProfileHeader(theme)),

// //           // Household Section
// //           SliverToBoxAdapter(child: _buildHouseholdSection(theme)),

// //           // Security & Notifications
// //           SliverToBoxAdapter(
// //             child: _buildSectionHeader('Security & Notifications', theme),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildToggleItem(
// //               icon: Icons.bolt_outlined,
// //               title: 'Flash Approvals',
// //               value: _flashApprovalsEnabled,
// //               onChanged: (value) {
// //                 setState(() => _flashApprovalsEnabled = value);
// //                 _showSnackBar(
// //                   'Flash Approvals \\${value ? 'enabled' : 'disabled'}',
// //                 );
// //               },
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.notifications_outlined,
// //               title: 'Notification Settings',
// //               onTap: () => _navigateTo('Notification Settings'),
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.lock_outlined,
// //               title: 'Security & Privacy',
// //               onTap: () => _navigateTo('Security & Privacy'),
// //               theme: theme,
// //             ),
// //           ),

// //           // Purchases
// //           SliverToBoxAdapter(child: _buildSectionHeader('Purchases', theme)),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.receipt_long_outlined,
// //               title: 'Order History',
// //               onTap: () => _navigateTo('Order History'),
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.credit_card_outlined,
// //               title: 'Saved Payments',
// //               onTap: () => _navigateTo('Saved Payments'),
// //               theme: theme,
// //             ),
// //           ),

// //           // Manage Flats
// //           SliverToBoxAdapter(child: _buildSectionHeader('Manage Flats', theme)),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.apartment_outlined,
// //               title: 'Unit 402 - Wing A',
// //               subtitle: 'PRIMARY ADDRESS',
// //               onTap: () => _navigateTo('Unit 402 - Wing A'),
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.domain_add_outlined,
// //               title: 'Add New Property',
// //               onTap: () => _navigateTo('Add New Property'),
// //               theme: theme,
// //             ),
// //           ),

// //           // General Settings
// //           SliverToBoxAdapter(
// //             child: _buildSectionHeader('General Settings', theme),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.language_outlined,
// //               title: 'App Language',
// //               trailing: _selectedLanguage,
// //               onTap: _showLanguagePicker,
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.dark_mode_outlined,
// //               title: 'Display Mode',
// //               onTap: _showDisplayModePicker,
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.support_agent_outlined,
// //               title: 'Support and Feedback',
// //               onTap: () => _navigateTo('Support and Feedback'),
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(
// //             child: _buildNavItem(
// //               icon: Icons.share_outlined,
// //               title: 'Share the App',
// //               onTap: () => _navigateTo('Share the App'),
// //               theme: theme,
// //             ),
// //           ),
// //           SliverToBoxAdapter(child: _buildLogoutItem(theme)),

// //           // Footer
// //           SliverToBoxAdapter(child: _buildFooter(theme)),

// //           // Bottom padding for nav bar
// //           const SliverToBoxAdapter(child: SizedBox(height: 80)),
// //         ],
// //       ),

// //       // Loading overlay
// //       // if (_isLoading)
// //       //   Container(
// //       //     color: Colors.black.withOpacity(0.1),
// //       //     child: const Center(
// //       //       child: CircularProgressIndicator(
// //       //         color: AppColors.secondary,
// //       //         strokeWidth: 2,
// //       //       ),
// //       //     ),
// //       //   ),
// //     );
// //   }

// //   // App Bar Widget
// //   Widget _buildAppBar(ThemeData theme) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: theme.scaffoldBackgroundColor,
// //         border: Border(
// //           bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
// //         ),
// //       ),
// //       padding: EdgeInsets.only(
// //         left: 24.w,
// //         right: 24.w,
// //         top: MediaQuery.of(context).padding.top + 16.h,
// //         bottom: 16.h,
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Row(
// //             children: [
// //               GestureDetector(
// //                 onTap: () => _showSnackBar('Back pressed'),
// //                 child: Container(
// //                   padding: const EdgeInsets.all(4),
// //                   child: Icon(
// //                     Icons.arrow_back,
// //                     color: theme.primaryColor,
// //                     size: 24,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 16),
// //               Text(
// //                 'Settings',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w500,
// //                   height: 28 / 20,
// //                   letterSpacing: -0.01 * 20,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           GestureDetector(
// //             onTap: _showHelpDialog,
// //             child: Container(
// //               padding: const EdgeInsets.all(4),
// //               child: Icon(
// //                 Icons.help_outline,
// //                 color: theme.primaryColor,
// //                 size: 24,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Profile Header Widget
// //   Widget _buildProfileHeader(ThemeData theme) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: 24.w),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(height: 16.h),
// //           Row(
// //             children: [
// //               // Profile Image
// //               GestureDetector(
// //                 onTap: () => _showSnackBar('Edit profile photo'),
// //                 child: Container(
// //                   width: 80,
// //                   height: 80,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(8),
// //                     color: theme.colorScheme.onSurface,
// //                   ),
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(8),
// //                     child: Image.network(
// //                       'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
// //                       fit: BoxFit.cover,
// //                       errorBuilder: (context, error, stackTrace) => Container(
// //                         color: theme.colorScheme.onSurface,
// //                         child: Icon(
// //                           Icons.person,
// //                           color: theme.primaryColor,
// //                           size: 40,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(width: 16.w),
// //               // Name and ID
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Nilesh',
// //                     style: TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w400,
// //                       height: 32 / 24,
// //                       letterSpacing: -0.01 * 24,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     'ID - 383 553',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w500,
// //                       height: 16 / 12,
// //                       letterSpacing: 0.05 * 12,
// //                       color: theme.colorScheme.onSurfaceVariant,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 16.h),
// //           // Profile Completion
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 4),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'Profile Completion',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w500,
// //                         height: 16 / 12,
// //                         letterSpacing: 0.05 * 12,
// //                         color: theme.colorScheme.onSurface,
// //                       ),
// //                     ),
// //                     Text(
// //                       '85%',
// //                       style: TextStyle(
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w600,
// //                         height: 16 / 12,
// //                         letterSpacing: 0.05 * 12,
// //                         color: theme.primaryColor,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Container(
// //                 height: 4,
// //                 decoration: BoxDecoration(
// //                   color: theme.colorScheme.onSurface,
// //                   borderRadius: BorderRadius.circular(2),
// //                 ),
// //                 child: FractionallySizedBox(
// //                   alignment: Alignment.centerLeft,
// //                   widthFactor: _profileCompletion,
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       color: theme.primaryColor,
// //                       borderRadius: BorderRadius.circular(2),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 16.h),
// //         ],
// //       ),
// //     );
// //   }

// //   // Household Section Widget
// //   Widget _buildHouseholdSection(ThemeData theme) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: 24.w),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(height: 32.h),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'HOUSEHOLD',
// //                 style: TextStyle(
// //                   fontSize: 16.sp,
// //                   fontWeight: FontWeight.w500,
// //                   height: 16 / 12,
// //                   letterSpacing: 0.05 * 12,
// //                   color: theme.colorScheme.onSurfaceVariant,
// //                 ),
// //               ),
// //               GestureDetector(
// //                 onTap: _showAddHouseholdDialog,
// //                 child: Row(
// //                   children: [
// //                     Icon(
// //                       Icons.add,
// //                       size: 16,
// //                       color: theme.colorScheme.onSurfaceVariant,
// //                     ),
// //                     const SizedBox(width: 4),
// //                     Text(
// //                       'Add',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w500,
// //                         height: 16 / 12,
// //                         letterSpacing: 0.05 * 12,
// //                         color: theme.colorScheme.onSurfaceVariant,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 16.h),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: _householdItems.map((item) {
// //               return GestureDetector(
// //                 onTap: () => _navigateTo(item['label']),
// //                 child: Column(
// //                   children: [
// //                     Container(
// //                       width: 52.w,
// //                       height: 52.w,
// //                       decoration: BoxDecoration(
// //                         color: theme.colorScheme.surfaceContainerLow,
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Icon(
// //                         item['icon'],
// //                         size: 28,
// //                         color: theme.colorScheme.onSurfaceVariant,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Text(
// //                       item['label'],
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w500,
// //                         height: 16 / 12,
// //                         letterSpacing: 0.05 * 12,
// //                         color: theme.colorScheme.onSurfaceVariant,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             }).toList(),
// //           ),
// //           SizedBox(height: 8.h),
// //         ],
// //       ),
// //     );
// //   }

// //   // Section Header Widget
// //   Widget _buildSectionHeader(String title, ThemeData theme) {
// //     return Padding(
// //       padding: EdgeInsets.only(
// //         left: 24.w,
// //         right: 24.w,
// //         top: 32.h,
// //         bottom: 16.h,
// //       ),
// //       child: Text(
// //         title.toUpperCase(),
// //         style: TextStyle(
// //           fontSize: 16.sp,
// //           fontWeight: FontWeight.w500,
// //           height: 16 / 12,
// //           letterSpacing: 0.05 * 12,
// //           color: theme.colorScheme.onSurfaceVariant,
// //         ),
// //       ),
// //     );
// //   }

// //   // Toggle Item Widget
// //   Widget _buildToggleItem({
// //     required IconData icon,
// //     required String title,
// //     required bool value,
// //     required ValueChanged<bool> onChanged,
// //     required ThemeData theme,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         border: Border(
// //           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
// //         ),
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: () => onChanged(!value),
// //           splashColor: theme.colorScheme.surfaceContainer.withOpacity(0.3),
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Icon(
// //                       icon,
// //                       size: 20,
// //                       color: theme.colorScheme.onSurfaceVariant,
// //                     ),
// //                     SizedBox(width: 16.w),
// //                     Text(
// //                       title,
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w400,
// //                         height: 24 / 16,
// //                         letterSpacing: 0.01 * 16,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 Switch(
// //                   value: value,
// //                   onChanged: onChanged,
// //                   activeColor: theme.colorScheme.onPrimary,
// //                   activeTrackColor: theme.colorScheme.primary,
// //                   inactiveThumbColor: theme.colorScheme.primaryContainer,
// //                   inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
// //                   trackOutlineColor: WidgetStateProperty.all(
// //                     Colors.transparent,
// //                   ),
// //                   trackOutlineWidth: WidgetStateProperty.all(0),
// //                   thumbIcon: WidgetStateProperty.all(null),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // Navigation Item Widget
// //   Widget _buildNavItem({
// //     required IconData icon,
// //     required String title,
// //     String? subtitle,
// //     String? trailing,
// //     required VoidCallback onTap,
// //     required ThemeData theme,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         border: Border(
// //           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
// //         ),
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: onTap,
// //           splashColor: theme.colorScheme.surfaceContainer.withOpacity(0.3),
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Icon(
// //                       icon,
// //                       size: 20,
// //                       color: theme.colorScheme.onSurfaceVariant,
// //                     ),
// //                     SizedBox(width: 16.w),
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           title,
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.w400,
// //                             height: 24 / 16,
// //                             letterSpacing: 0.01 * 16,
// //                           ),
// //                         ),
// //                         if (subtitle != null)
// //                           Text(
// //                             subtitle,
// //                             style: TextStyle(
// //                               fontSize: 12,
// //                               fontWeight: FontWeight.w500,
// //                               height: 16 / 12,
// //                               letterSpacing: 0.05 * 12,
// //                               color: theme.colorScheme.onSurfaceVariant,
// //                             ),
// //                           ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //                 Row(
// //                   children: [
// //                     if (trailing != null)
// //                       Text(
// //                         trailing,
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w500,
// //                           height: 16 / 12,
// //                           letterSpacing: 0.05 * 12,
// //                           color: theme.colorScheme.onSurfaceVariant,
// //                         ),
// //                       ),
// //                     const SizedBox(width: 8),
// //                     Icon(
// //                       Icons.chevron_right,
// //                       size: 20,
// //                       color: theme.colorScheme.outlineVariant,
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // Logout Item Widget
// //   Widget _buildLogoutItem(ThemeData theme) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         border: Border(
// //           top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
// //         ),
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: _showLogoutDialog,
// //           splashColor: theme.colorScheme.errorContainer.withOpacity(0.3),
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
// //             child: Row(
// //               children: [
// //                 Icon(Icons.logout, size: 20, color: theme.colorScheme.error),
// //                 SizedBox(width: 12.w),
// //                 Text(
// //                   'Log Out',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w400,
// //                     height: 24 / 16,
// //                     letterSpacing: 0.01 * 16,
// //                     color: theme.colorScheme.error,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // Footer Widget
// //   Widget _buildFooter(ThemeData theme) {
// //     return Padding(
// //       padding: const EdgeInsets.only(top: 40),
// //       child: Column(
// //         children: [
// //           // Icon(Icons.hub, size: 36, color: theme.colorScheme.outlineVariant),
// //           GestureDetector(
// //             onTap: () => _navigateTo('About MyGateBell'),
// //             child: Row(
// //               spacing: 8.w,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Image.asset(
// //                   'assets/images/app_logo.png',
// //                   height: 30.w,
// //                   width: 30.w,
// //                   fit: BoxFit.contain,
// //                 ),
// //                 Text(
// //                   "MyGateBell",
// //                   style: TextStyle(
// //                     fontSize: 20.sp,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           SizedBox(height: 16.h),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               GestureDetector(
// //                 onTap: () => _navigateTo('Terms & Conditions'),
// //                 child: Text(
// //                   'Terms & Conditions',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w500,
// //                     height: 16 / 12,
// //                     letterSpacing: 0.05 * 12,
// //                     color: theme.colorScheme.onSurfaceVariant,
// //                   ),
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 12),
// //                 child: Text(
// //                   '|',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w500,
// //                     height: 16 / 12,
// //                     letterSpacing: 0.05 * 12,
// //                     color: theme.colorScheme.onSurfaceVariant,
// //                   ),
// //                 ),
// //               ),
// //               GestureDetector(
// //                 onTap: () => _navigateTo('Privacy Policy'),
// //                 child: Text(
// //                   'Privacy Policy',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w500,
// //                     height: 16 / 12,
// //                     letterSpacing: 0.05 * 12,
// //                     color: theme.colorScheme.onSurfaceVariant,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //           Text(
// //             'Version 4.12.0',
// //             style: TextStyle(
// //               fontSize: 12,
// //               fontWeight: FontWeight.w500,
// //               height: 16 / 12,
// //               letterSpacing: 0.05 * 12,
// //               color: theme.colorScheme.onSurfaceVariant,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ============================================
// // // SUB SCREEN (for navigation destinations)
// // // ============================================
// // class SubScreen extends StatelessWidget {
// //   final String title;

// //   const SubScreen({super.key, required this.title});

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     return Scaffold(
// //       backgroundColor: theme.scaffoldBackgroundColor,
// //       appBar: AppBar(
// //         backgroundColor: theme.scaffoldBackgroundColor,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back, color: theme.primaryColor),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: Text(
// //           title,
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w500,
// //             height: 28 / 20,
// //             letterSpacing: -0.01 * 20,
// //           ),
// //         ),
// //         bottom: PreferredSize(
// //           preferredSize: Size.fromHeight(1),
// //           child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
// //         ),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               Icons.construction_outlined,
// //               size: 48,
// //               color: theme.colorScheme.outlineVariant,
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               title,
// //               style: TextStyle(
// //                 fontSize: 24,
// //                 fontWeight: FontWeight.w600,
// //                 height: 32 / 24,
// //                 letterSpacing: -0.02 * 24,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'This screen is under development',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w400,
// //                 height: 24 / 16,
// //                 letterSpacing: 0.01 * 16,
// //                 color: theme.colorScheme.onSurfaceVariant,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
