import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/screens/resident/edit_profile_screen.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  final TextEditingController _searchController = TextEditingController();
  List<FamilyMember> _filteredFamilyMembers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _settings = [
    {
      'title': 'Biometric Authentication',
      'subtitle': 'Use fingerprint or face recognition to login',
      'icon': Icons.fingerprint,
    },
    {
      'title': 'Notifications',
      'subtitle': 'Receive alerts and updates',
      'icon': Icons.notifications,
    },
    {
      'title': 'Privacy Settings',
      'subtitle': 'Manage your privacy preferences',
      'icon': Icons.privacy_tip,
    },
    {
      'title': 'Language',
      'subtitle': 'Change app language',
      'icon': Icons.language,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Dispatch FetchProfile to get latest profile from backend
    context.read<ProfileBloc>().add(FetchProfile());

    _searchController.addListener(_filterFamilyMembers);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
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

  @override
  void dispose() {
    _searchController.removeListener(_filterFamilyMembers);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    context.read<ProfileBloc>().add(FetchProfile());
  }

  @override
  Widget build(BuildContext context) {
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
          appBar: AppBar(
            title: Text('Profile', style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: user),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(user),
                  SizedBox(height: 20.h),
                  // About Me/Bio Card if present
                  if (user.bio != null && user.bio!.isNotEmpty)
                    _buildBioCard(user),
                  // Profile Details Sections
                  _buildProfileSections(user),
                  SizedBox(height: 20.h),
                  // Settings
                  _buildSettingsCard(),
                  SizedBox(height: 20.h),
                  // Logout Button
                  _buildLogoutButton(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User user) {
    // return Container(
    //   padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
    //   decoration: BoxDecoration(
    //     color: Theme.of(context).primaryColor,
    //     borderRadius: BorderRadius.only(
    //       bottomLeft: Radius.circular(20.r),
    //       bottomRight: Radius.circular(20.r),
    //     ),
    //   ),
    //   child: Row(
    //     children: [
    //       ScaleTransition(
    //         scale: Tween<double>(begin: 0.8, end: 1.0).animate(
    //           CurvedAnimation(
    //             parent: _animationController,
    //             curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    //           ),
    //         ),
    //         child: Container(
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(50.r),
    //             border: Border.all(color: Colors.white, width: 3.w),
    //           ),
    //           child: CircleAvatar(
    //             radius: 40.r,
    //             backgroundImage: NetworkImage(
    //               user.profileImage ??
    //                   'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
    //             ),
    //           ),
    //         ),
    //       ),
    //       SizedBox(width: 20.w),
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             FadeTransition(
    //               opacity: _fadeAnimation,
    //               child: Text(
    //                 user.name,
    //                 style: TextStyle(
    //                   fontSize: 22.sp,
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.white,
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: 5.h),
    //             FadeTransition(
    //               opacity: _fadeAnimation,
    //               child: Text(
    //                 user.unit != null ? 'Resident • ${user.unit}' : 'Resident',
    //                 style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    //               ),
    //             ),
    //             SizedBox(height: 10.h),
    //             FadeTransition(
    //               opacity: _fadeAnimation,
    //               child: Container(
    //                 padding: EdgeInsets.symmetric(
    //                   horizontal: 12.w,
    //                   vertical: 6.h,
    //                 ),
    //                 decoration: BoxDecoration(
    //                   color: Colors.white.withOpacity(0.2),
    //                   borderRadius: BorderRadius.circular(20.r),
    //                   border: Border.all(color: Colors.white.withOpacity(0.3)),
    //                 ),
    //                 child: Text(
    //                   user.isApproved == true
    //                       ? 'Verified Resident'
    //                       : 'Pending Approval',
    //                   style: TextStyle(fontSize: 12.sp, color: Colors.white),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final surfaceColor = isDarkMode
        ? AppTheme.surfaceDark
        : AppTheme.surfaceLight;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Cover photo banner
        Container(
          height: 170.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: NetworkImage(
                user.coverImageUrl ??
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
              ),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
        ),
        // Avatar profile photo
        Positioned(
          bottom: -50.h,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: surfaceColor,
                  backgroundImage: NetworkImage(user.profileImage ?? ""),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioCard(User user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              user.bio ?? '',
              style: TextStyle(fontSize: 14.sp, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSections(User user) {
    final personalItems = [
      {'label': 'Name', 'value': user.name},
      {'label': 'Email', 'value': user.email.isEmpty ? 'N/A' : user.email},
      {'label': 'Phone', 'value': user.phone},
      {'label': 'Unit', 'value': user.unit ?? 'N/A'},
      {'label': 'Society ID', 'value': user.societyId ?? 'N/A'},
      if (user.residentType != null)
        {'label': 'Resident Type', 'value': user.residentType!},
      if (user.profession != null && user.profession!.isNotEmpty)
        {'label': 'Profession', 'value': user.profession!},
      if (user.hometown != null && user.hometown!.isNotEmpty)
        {'label': 'Hometown', 'value': user.hometown!},
    ];

    final familyMembersList = user.familyMembers ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Info Section
        Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 8.h,
            top: 40.h,
          ),
          child: Text(
            'Personal Information',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: personalItems.map((item) {
              return ListTile(
                title: Text(
                  item['label']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                  ),
                ),
                trailing: Text(
                  item['value']!,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              );
            }).toList(),
          ),
        ),

        // Family Members Section
        Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 24.h,
            bottom: 8.h,
          ),
          child: Text(
            'Family Members',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              if (familyMembersList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'No family members listed.',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                )
              else
                ...familyMembersList.map((member) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundImage: NetworkImage(
                        member.profileImage ??
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
                      ),
                    ),
                    title: Text(member.name, style: TextStyle(fontSize: 15.sp)),
                    subtitle: Text(
                      member.relationship,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.6, 0.9, curve: Curves.elasticOut),
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            ..._settings.asMap().entries.map((entry) {
              final index = entry.key;
              final setting = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        setting['icon'],
                        color: Theme.of(context).primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    title: Text(
                      setting['title'],
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    subtitle: Text(
                      setting['subtitle'],
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                    trailing: index < 2
                        ? Switch(
                            value: index == 0
                                ? _biometricEnabled
                                : _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                if (index == 0) {
                                  _biometricEnabled = value;
                                } else {
                                  _notificationsEnabled = value;
                                }
                              });
                            },
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                    onTap: () {
                      if (index >= 2) {
                        switch (index) {
                          case 2:
                            // _showPrivacyDialog();
                            Navigator.of(context).pushNamed('/settings');
                            break;
                          case 3:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Language settings coming soon!'),
                              ),
                            );
                            break;
                        }
                      }
                    },
                  ),
                  if (index < _settings.length - 1)
                    Divider(
                      height: 1.h,
                      thickness: 0.5,
                      color: Colors.grey.withOpacity(0.2),
                      indent: 16.w,
                      endIndent: 16.w,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showLogoutConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy Settings'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy is important to us. We collect and use your information to provide and improve our services.',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 16),
                Text(
                  'Information We Collect:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Personal information (name, email, phone number)\n• Usage data\n• Device information',
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 16),
                Text(
                  'How We Use Your Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• To provide and maintain our service\n• To notify you about changes\n• To provide customer support',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
}
