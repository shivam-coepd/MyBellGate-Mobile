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
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/screens/common/security_privacy_screen.dart';
import 'package:mygate_coepd/screens/common/share_app_screen.dart';
import 'package:mygate_coepd/screens/common/support_feedback_screen.dart';
import 'package:mygate_coepd/screens/resident/order_history_screen.dart';
import 'package:mygate_coepd/screens/resident/property_details_screen.dart';
import 'package:mygate_coepd/screens/resident/saved_payments_screen.dart';
import 'package:mygate_coepd/blocs/theme/theme_cubit.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:shimmer/shimmer.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 14.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
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
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
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
                  AppSnackbar.show(
                    context: context,
                    message: 'Language changed to $lang',
                    type: SnackBarType.success,
                    position: SnackBarPosition.top,
                  );
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
    final currentMode = context.read<ThemeCubit>().state;
    showModalBottomSheet(
      context: context,
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
              trailing: currentMode == ThemeMode.light
                  ? Icon(Icons.check, color: theme.primaryColor, size: 20)
                  : null,
              onTap: () {
                context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                Navigator.pop(context);
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
              trailing: currentMode == ThemeMode.dark
                  ? Icon(Icons.check, color: theme.primaryColor, size: 20)
                  : null,
              onTap: () {
                context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                Navigator.pop(context);
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
              trailing: currentMode == ThemeMode.system
                  ? Icon(Icons.check, color: theme.primaryColor, size: 20)
                  : null,
              onTap: () {
                context.read<ThemeCubit>().updateTheme(ThemeMode.system);
                Navigator.pop(context);
                AppSnackbar.show(
                  context: context,
                  message: "System default mode enabled",
                  type: SnackBarType.success,
                  position: SnackBarPosition.top,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    final authBloc = context.read<AuthBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final navigator = Navigator.of(dialogContext);
                navigator.pop();
                authBloc.add(LogoutRequested());
                navigator.pushNamedAndRemoveUntil('/auth', (route) => false);
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
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => SubScreen(title: title)),
    // );
    switch (title) {
      case 'Security & Privacy':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()),
        );
        break;
      case 'Order History':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        );
        break;
      case 'Saved Payments':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedPaymentsScreen()),
        );
        break;
      case 'Unit':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PropertyDetailsScreen()),
        );
        break;
      case 'Support and Feedback':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupportFeedbackScreen()),
        );
        break;
      case 'Share the App':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShareAppScreen()),
        );
        break;
    }
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
    final themeMode = context.watch<ThemeCubit>().state;
    String displayModeText = 'System Default';
    if (themeMode == ThemeMode.light) {
      displayModeText = 'Light';
    } else if (themeMode == ThemeMode.dark) {
      displayModeText = 'Dark';
    }
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _filterFamilyMembers();
        } else if (state is HouseholdUpdateSuccess) {
          AppSnackbar.show(
            context: context,
            message: state.message,
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
        } else if (state is HouseholdError) {
          AppSnackbar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
            position: SnackBarPosition.top,
          );
        }
      },
      builder: (context, state) {
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

        final user = (state is ProfileLoaded)
            ? state.user
            : context.read<UserRepository>().getCurrentUser();

        if (user == null && state is! ProfileLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(
              child: Text('No user profile found. Please login again.'),
            ),
          );
        }

        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text("Profile"),
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
                // Profile header with shimmer when loading, real data when loaded
                SliverToBoxAdapter(
                  child: isLoading
                      ? _buildProfileHeaderShimmer(theme)
                      : _buildProfileHeader(theme, user!),
                ),
                // All other sections remain visible and interactive during loading
                SliverToBoxAdapter(child: _buildHouseholdSection(theme)),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Security', theme),
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
                  child: _buildSectionHeader('Manage Flat', theme),
                ),
                SliverToBoxAdapter(
                  child: _buildNavItem(
                    icon: Icons.apartment_outlined,
                    title: user?.unit ?? 'Unit',
                    subtitle: 'PRIMARY ADDRESS',
                    onTap: () => _navigateTo('Unit'),
                    theme: theme,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('General Settings', theme),
                ),
                SliverToBoxAdapter(
                  child: _buildNavItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Display Mode',
                    trailing: displayModeText,
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
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shimmer loading effect for profile header section only
  Widget _buildProfileHeaderShimmer(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Row(
              children: [
                // Avatar placeholder shimmer
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name placeholder shimmer
                    Container(
                      width: 140.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // ID placeholder shimmer
                    Container(
                      width: 80.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: 80.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
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
                onTap: () => AppSnackbar.show(
                  context: context,
                  message: "Edit profile photo",
                  type: SnackBarType.success,
                  position: SnackBarPosition.top,
                ),
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: theme.colorScheme.onSurface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      user.profileImage ?? "",
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.scaffoldBackgroundColor,
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
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/profile-details"),
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
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['icon'],
                        size: 28,
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
            'Version 1.0.2',
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
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  final _s3 = S3UploadService();

  String _selectedRelation = 'Spouse';
  final List<String> _relationships = [
    'Spouse',
    'Son',
    'Daughter',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Grandfather',
    'Grandmother',
    'Other',
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
          AppSnackbar.show(
            context: context,
            message: "Contacts permission denied",
            type: SnackBarType.error,
            position: SnackBarPosition.top,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          message: "Error picking contact: $e",
          type: SnackBarType.error,
          position: SnackBarPosition.top,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() {
      _pickedImage = image;
      _isUploadingImage = true;
      _uploadedImageUrl = null;
    });
    try {
      final url = await _s3.uploadImage(
        File(image.path),
        folder: S3UploadService.folderProfiles,
      );
      if (mounted) setState(() => _uploadedImageUrl = url);
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          message: "Image upload failed: $e",
          type: SnackBarType.error,
          position: SnackBarPosition.top,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _addFamily() {
    if (_nameController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty) {
      AppSnackbar.show(
        context: context,
        message: "Please fill all fields",
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }
    if (_isUploadingImage) {
      AppSnackbar.show(
        context: context,
        message: "Please wait for image to finish uploading",
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }
    final cleanPhone = _mobileController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length != 10 && cleanPhone.isNotEmpty) {
      AppSnackbar.show(
        context: context,
        message: "Please enter a valid 10-digit mobile number",
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }
    final formattedPhone = cleanPhone.isNotEmpty ? '+91$cleanPhone' : null;
    final memberType = _selectedTab == 0 ? 'Adult' : 'Kid';

    context.read<ProfileBloc>().add(
      AddFamilyMember(
        name: _nameController.text.trim(),
        relation: _selectedRelation,
        memberType: memberType,
        phone: formattedPhone,
        imageUrl: _uploadedImageUrl,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).viewInsets.top + 32.h,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border(top: BorderSide(color: Colors.grey.shade500)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: MediaQuery.of(context).viewInsets.top,
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
                        width: 1.w,
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
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedRelation,
                      items: _relationships.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 16.sp)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          if (newValue != null) _selectedRelation = newValue;
                        });
                      },
                    ),
                  ),
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
                trailing: items.indexOf(item) == items.indexOf(title)
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
    if (_nameController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty) {
      AppSnackbar.show(
        context: context,
        message: 'Please enter name and mobile number',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }
    if (_selectedCategory == null) {
      AppSnackbar.show(
        context: context,
        message: 'Please select a category',
        type: SnackBarType.info,
        position: SnackBarPosition.top,
      );
      return;
    }
    final cleanPhone = _mobileController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length != 10) {
      AppSnackbar.show(
        context: context,
        message: 'Please enter a valid 10-digit mobile number',
        type: SnackBarType.warning,
        position: SnackBarPosition.top,
      );
      return;
    }
    final formattedPhone = '+91$cleanPhone';

    context.read<ProfileBloc>().add(
      AddDailyHelper(
        name: _nameController.text.trim(),
        phone: formattedPhone,
        serviceType: _selectedCategory!,
        visitTime: '$_selectedDate · $_selectedDuration',
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).viewInsets.top + 32.h,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border(top: BorderSide(color: Colors.grey.shade500)),
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
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _parkingSpotController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  XFile? _pickedImage;
  List<Map<String, dynamic>> _vehicleTypes = [];
  int? _selectedVehicleTypeId;
  bool _isLoadingTypes = true;
  String _isElectric = '';
  String _isParked = '';

  @override
  void initState() {
    super.initState();
    _loadVehicleTypes();
  }

  Future<void> _loadVehicleTypes() async {
    try {
      final types = await context.read<HouseholdRepository>().getVehicleTypes();
      if (mounted) {
        setState(() {
          _vehicleTypes = types;
          _isLoadingTypes = false;
          if (types.isNotEmpty) {
            _selectedVehicleTypeId = types.first['id'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTypes = false);
        AppSnackbar.show(
          context: context,
          message: 'Failed to load vehicle types: $e',
          type: SnackBarType.error,
          position: SnackBarPosition.top,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _parkingSpotController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  void _addVehicle() {
    if (_numberController.text.trim().isEmpty) {
      AppSnackbar.show(
        context: context,
        message: 'Please enter a vehicle registration number',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }
    final cleanNumber = _numberController.text.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );
    if (cleanNumber.length < 5 || cleanNumber.length > 15) {
      AppSnackbar.show(
        context: context,
        message: 'Registration number must be 5-15 alphanumeric characters',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }
    if (_selectedVehicleTypeId == null) {
      AppSnackbar.show(
        context: context,
        message: 'Please select a vehicle type',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }

    int? isElectricInt;
    if (_isElectric == 'yes') {
      isElectricInt = 1;
    } else if (_isElectric == 'no') {
      isElectricInt = 0;
    }

    int? isParkedInt;
    if (_isParked == 'yes') {
      isParkedInt = 1;
    } else if (_isParked == 'no') {
      isParkedInt = 0;
    }
    context.read<ProfileBloc>().add(
      AddVehicle(
        registrationNumber: cleanNumber.toUpperCase(),
        vehicleTypeId: _selectedVehicleTypeId!,
        make: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        model: _modelController.text.trim().isNotEmpty
            ? _modelController.text.trim()
            : null,
        color: _colorController.text.trim().isNotEmpty
            ? _colorController.text.trim()
            : null,
        parkingSpot: _parkingSpotController.text.trim().isNotEmpty
            ? _parkingSpotController.text.trim()
            : null,
        isElectric: isElectricInt,
        isParked: isParkedInt,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).viewInsets.top + 32.h,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border(top: BorderSide(color: Colors.grey.shade500)),
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
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter Make eg. Honda, Toyota',
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _modelController,
                            decoration: InputDecoration(
                              hintText: 'Model (e.g. Civic)',
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
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _colorController,
                            decoration: InputDecoration(
                              hintText: 'Color (e.g. Red)',
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
                SizedBox(height: 16.h),
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
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _parkingSpotController,
                      decoration: InputDecoration(
                        hintText: 'Parking Spot (Optional)',
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
                if (_isLoadingTypes)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_vehicleTypes.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'No vehicle types available',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Wrap(
                      spacing: 12.w,
                      runSpacing: 8.h,
                      children: _vehicleTypes.map((type) {
                        final typeId = type['id'] as int;
                        final typeName = (type['name'] ?? '').toString();
                        final isSelected = _selectedVehicleTypeId == typeId;
                        return ChoiceChip(
                          label: Text(typeName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedVehicleTypeId = typeId);
                            }
                          },
                          selectedColor: theme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.primaryColor
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14.sp,
                          ),
                        );
                      }).toList(),
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
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Is the vehicle currently parked?',
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
                          onTap: () => setState(() => _isParked = 'yes'),
                          child: Row(
                            children: [
                              Icon(
                                _isParked == 'yes'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _isParked == 'yes'
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
                          onTap: () => setState(() => _isParked = 'no'),
                          child: Row(
                            children: [
                              Icon(
                                _isParked == 'no'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _isParked == 'no'
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
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Map<String, dynamic>> _petTypes = [];
  int? _selectedPetTypeId;
  bool _isLoadingTypes = true;
  String _vaccinationStatus = 'pending';

  XFile? _pickedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  final _s3 = S3UploadService();

  @override
  void initState() {
    super.initState();
    _loadPetTypes();
  }

  Future<void> _loadPetTypes() async {
    try {
      final types = await context.read<HouseholdRepository>().getPetTypes();
      if (mounted) {
        setState(() {
          _petTypes = types;
          _isLoadingTypes = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTypes = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() {
      _pickedImage = image;
      _isUploadingImage = true;
      _uploadedImageUrl = null;
    });
    try {
      final url = await _s3.uploadImage(
        File(image.path),
        folder: S3UploadService.folderProfiles,
      );
      if (mounted) setState(() => _uploadedImageUrl = url);
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          message: 'Image upload failed: $e',
          type: SnackBarType.error,
          position: SnackBarPosition.top,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _showDropdown(
    String title,
    List<String> items,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

  void _addPet() {
    if (_nameController.text.trim().isEmpty || _selectedPetTypeId == null) {
      AppSnackbar.show(
        context: context,
        message: 'Please fill required fields (Name and Pet Type)',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }
    if (_isUploadingImage) {
      AppSnackbar.show(
        context: context,
        message: 'Please wait for image to finish uploading',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      return;
    }

    int? age;
    if (_ageController.text.trim().isNotEmpty) {
      age = int.tryParse(_ageController.text.trim());
    }

    double? weight;
    if (_weightController.text.trim().isNotEmpty) {
      weight = double.tryParse(_weightController.text.trim());
    }

    context.read<ProfileBloc>().add(
      AddPet(
        name: _nameController.text.trim(),
        petTypeId: _selectedPetTypeId!,
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        age: age,
        weight: weight,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        vaccinationStatus: _vaccinationStatus,
        imageUrl: _uploadedImageUrl,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).viewInsets.top + 32.h,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border(top: BorderSide(color: Colors.grey.shade500)),
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
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Age (Years)',
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
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Weight (kg)',
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
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: GestureDetector(
                    onTap: () {
                      _showDropdown(
                        'Vaccination Status',
                        ['up_to_date', 'pending', 'not_vaccinated'],
                        (val) => setState(() => _vaccinationStatus = val),
                      );
                    },
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
                            _vaccinationStatus
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Notes (Optional)',
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
                if (_isLoadingTypes)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_petTypes.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'No pet types available',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 12.w,
                        runSpacing: 8.h,
                        children: _petTypes.map((type) {
                          final typeId = type['id'] as int;
                          final typeName = (type['name'] ?? '').toString();
                          final isSelected = _selectedPetTypeId == typeId;
                          return ChoiceChip(
                            label: Text(typeName),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedPetTypeId = typeId);
                              }
                            },
                            selectedColor: theme.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            checkmarkColor: theme.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.primaryColor
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                SizedBox(height: 32.h),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
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
