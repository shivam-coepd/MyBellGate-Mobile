import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool _flashApprovalsEnabled = true;
  String _selectedLanguage = 'English';
  final double _profileCompletion = 0.85;

  final TextEditingController _searchController = TextEditingController();
  List<FamilyMember> _filteredFamilyMembers = [];

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
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 24.w, left: 20.w, right: 20.w),
              child: Text(
                'Add to Household',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 8.h),
            _buildAddOption(
              theme,
              Icons.family_restroom,
              'Family Member',
              'Add adult or kid',
              () {
                Navigator.pop(context);
                _showAddFamilySheet();
              },
            ),
            _buildAddOption(
              theme,
              Icons.support_agent,
              'Daily Help',
              'Maid, cook, driver, etc.',
              () {
                Navigator.pop(context);
                _showAddDailyHelpSheet();
              },
            ),
            _buildAddOption(
              theme,
              Icons.directions_car,
              'Vehicle',
              'Car, bike, scooter',
              () {
                Navigator.pop(context);
                _showAddVehicleSheet();
              },
            ),
            _buildAddOption(
              theme,
              Icons.pets,
              'Pet',
              'Dog, cat, or other pets',
              () {
                Navigator.pop(context);
                _showAddPetSheet();
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface),
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

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger logout event in AuthBloc
                context.read<AuthBloc>().add(LogoutRequested());
                // Navigate to login screen
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _filterFamilyMembers() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final allMembers = state.user.familyMembers ?? [];
      final searchTerm = _searchController.text.toLowerCase();
      setState(() {
        _filteredFamilyMembers = allMembers.where((member) {
          return searchTerm.isEmpty ||
              member.name.toLowerCase().contains(searchTerm) ||
              member.relationship.toLowerCase().contains(searchTerm);
        }).toList();
      });
    }
  }

  Future<void> _refreshProfile() async {
    context.read<ProfileBloc>().add(FetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // Update the search lists when profile loads
          _filterFamilyMembers();
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _refreshProfile,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Use the user from ProfileLoaded, or fallback to current repository user
        final user = (state is ProfileLoaded)
            ? state.user
            : context.read<UserRepository>().getCurrentUser();

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(
              child: Text('No user profile found. Please login again.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.colorScheme.onSurface,
            surfaceTintColor: Colors.transparent,
            // leading: IconButton(
            //   onPressed: () => Navigator.pop(context),
            //   icon: Icon(Icons.arrow_back_ios_new_rounded),
            // ),
            title: Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: _showHelpDialog,
                icon: Icon(Icons.help_outline),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshProfile,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildProfileHeader(theme, user)),
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
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Purchases', theme),
                ),
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
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Manage Flats', theme),
                ),
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
                // const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeData theme, User user) {
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
                      user.profileImage ?? "",
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
                    user.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      height: 32 / 24,
                      letterSpacing: -0.01 * 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${user.appUserId}',
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
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, "/profile-details"),
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
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
                        // color: theme.colorScheme.surfaceContainerLow,
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['icon'],
                        size: 28,
                        // color: theme.colorScheme.onSurfaceVariant,
                        color: theme.primaryColor,
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
                  inactiveTrackColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
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
          onTap: _showLogoutConfirmation,
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
      padding: EdgeInsets.only(top: 30.h, bottom: 30.h),
      child: Column(
        spacing: 10.h,
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
    final theme = Theme.of(context);
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
                                    ? theme.primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 3,
                              color: _selectedTab == 0
                                  ? theme.primaryColor
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
                                    ? theme.primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 3,
                              color: _selectedTab == 1
                                  ? theme.primaryColor
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
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      if (status == PermissionStatus.granted) {
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                trailing: _selectedCategory == cat
                    ? const Icon(Icons.check, color: Color(0xFF1B5E20))
                    : null,
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
    );
  }

  void _showDropdown(
    String title,
    List<String> items,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.h),
              child: Text(
                title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
            ...items.map(
              (item) => ListTile(
                title: Text(item, style: TextStyle(fontSize: 16.sp)),
                trailing:
                    items.indexOf(item) ==
                        items.indexOf(title) // Simplified check
                    ? const Icon(Icons.check, color: Color(0xFF1B5E20))
                    : null,
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
    final theme = Theme.of(context);
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Add Daily Help',
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
                // Tabs matching Add Family style
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
                                      ? theme.primaryColor
                                      : Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                height: 3,
                                color: _selectedTab == 0
                                    ? theme.primaryColor
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
                                      ? theme.primaryColor
                                      : Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                height: 3,
                                color: _selectedTab == 1
                                    ? theme.primaryColor
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
                // Category selector matching input style
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
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
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
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.primaryColor),
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
                              color: Theme.of(context).primaryColor,
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
                // Duration dropdown matching input style
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
                        borderRadius: BorderRadius.circular(12),
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
                // Date and Duration row
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
                              borderRadius: BorderRadius.circular(12),
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
                                  color: Theme.of(context).primaryColor,
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
                              borderRadius: BorderRadius.circular(12),
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
                                  color: Theme.of(context).primaryColor,
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
                // Company dropdown
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
                        borderRadius: BorderRadius.circular(12),
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
                // Name field with contact picker - matching Add Family style
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
                          icon: Icon(
                            Icons.contacts,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: _pickContact,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Mobile field matching Add Family style
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
                          '+91',
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
                // Action button matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: GestureDetector(
                    onTap: _addDailyHelp,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
    final theme = Theme.of(context);
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
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
                // Photo picker matching Add Family style
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
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                // Name field matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter Name eg. My Car',
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
                SizedBox(height: 16.h),
                // Number field matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _numberController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter Vehicle Number',
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
                SizedBox(height: 24.h),
                // Vehicle type section
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
                                    ? theme.primaryColor
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
                                    ? theme.primaryColor
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
                // Electric section
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
                                    ? theme.primaryColor
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
                                    ? theme.primaryColor
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
                // Action button matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: GestureDetector(
                    onTap: _addVehicle,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
    final theme = Theme.of(context);
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
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
                // Photo picker matching Add Family style
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
                                Icons.pets,
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
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                // Name field matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Pet's Name",
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
                SizedBox(height: 16.h),
                // Breed field matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _breedController,
                      decoration: InputDecoration(
                        hintText: 'Breed (Optional)',
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
                SizedBox(height: 24.h),
                // Pet type section
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
                                    ? theme.primaryColor
                                    : Colors.grey.shade300,
                                width: _petType == 'dog' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: _petType == 'dog'
                                  ? theme.primaryColor.withValues(alpha: 0.1)
                                  : Colors.white,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: _petType == 'dog'
                                      ? theme.primaryColor
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
                                    ? theme.primaryColor
                                    : Colors.grey.shade300,
                                width: _petType == 'cat' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: _petType == 'cat'
                                  ? theme.primaryColor.withValues(alpha: 0.1)
                                  : Colors.white,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: _petType == 'cat'
                                      ? theme.primaryColor
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
                                    ? theme.primaryColor
                                    : Colors.grey.shade300,
                                width: _petType == 'other' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: _petType == 'other'
                                  ? theme.primaryColor.withValues(alpha: 0.1)
                                  : Colors.white,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: _petType == 'other'
                                      ? theme.primaryColor
                                      : Colors.grey,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Other',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                // Action button matching Add Family style
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: GestureDetector(
                    onTap: _addPet,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
      ),
    );
  }
}

// ============================================
// SUB SCREEN
// ============================================
class SubScreen extends StatefulWidget {
  final String title;
  const SubScreen({super.key, required this.title});

  @override
  State<SubScreen> createState() => _SubScreenState();
}

class _SubScreenState extends State<SubScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 28 / 20,
            letterSpacing: -0.01 * 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(1),
        //   child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
        // ),
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
              widget.title,
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
