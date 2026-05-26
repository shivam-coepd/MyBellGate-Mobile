import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/screens/resident/edit_profile_screen.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with TickerProviderStateMixin {
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  final TextEditingController _searchController = TextEditingController();
  List<FamilyMember> _filteredFamilyMembers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _dailyHelpers = [];
  bool _isLoadingHelpers = true;

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
    _loadDailyHelpers();

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

  Future<void> _loadDailyHelpers() async {
    try {
      final helpers = await context
          .read<HouseholdRepository>()
          .getDailyHelpers();
      if (mounted) {
        setState(() {
          _dailyHelpers = helpers;
          _isLoadingHelpers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHelpers = false);
      }
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

  @override
  void dispose() {
    _searchController.removeListener(_filterFamilyMembers);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    context.read<ProfileBloc>().add(FetchProfile());
    await _loadDailyHelpers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // Update the search lists when profile loads
          _filterFamilyMembers();
        } else if (state is HouseholdUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadDailyHelpers();
        } else if (state is HouseholdError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
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
            appBar: AppBar(title: const Text('Profile Details')),
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
            appBar: AppBar(title: const Text('Profile Details')),
            body: const Center(
              child: Text('No user profile found. Please login again.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.colorScheme.onSurface,
            surfaceTintColor: Colors.transparent,
            // leading: IconButton(
            //   onPressed: () => Navigator.pop(context),
            //   icon: Icon(Icons.arrow_back_ios_new_rounded),
            // ),
            title: Text(
              "Profile Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                child: const Text('Edit'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileDetailsScreen(user: user),
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
                  _buildProfileSections(user, theme),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User user) {
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

  Widget _buildProfileSections(User user, ThemeData theme) {
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmDialog(
                          title: 'Remove Family Member',
                          content:
                              'Are you sure you want to remove ${member.name}?',
                          onDelete: () {
                            context.read<ProfileBloc>().add(
                              DeleteFamilyMember(member.id),
                            );
                          },
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),

        // Vehicles Section
        Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 24.h,
            bottom: 8.h,
          ),
          child: Text(
            'Vehicles',
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
              if ((user.vehicles ?? []).isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'No vehicles listed.',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                )
              else
                ...(user.vehicles ?? []).map((vehicle) {
                  return ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car_outlined,
                        color: theme.primaryColor,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          vehicle.registrationNumber,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (vehicle.isElectric == 1) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              'EV',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      vehicle.typeName ?? 'Vehicle',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmDialog(
                          title: 'Remove Vehicle',
                          content:
                              'Are you sure you want to remove ${vehicle.registrationNumber}?',
                          onDelete: () {
                            context.read<ProfileBloc>().add(
                              DeleteVehicle(vehicle.id),
                            );
                          },
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),

        // Pets Section
        Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 24.h,
            bottom: 8.h,
          ),
          child: Text(
            'Pets',
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
              if ((user.pets ?? []).isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'No pets listed.',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                )
              else
                ...(user.pets ?? []).map((pet) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundImage:
                          pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                          ? NetworkImage(pet.imageUrl!)
                          : null,
                      child: pet.imageUrl == null || pet.imageUrl!.isEmpty
                          ? const Icon(Icons.pets, color: Colors.grey)
                          : null,
                    ),
                    title: Text(pet.name, style: TextStyle(fontSize: 15.sp)),
                    subtitle: Text(
                      '${pet.petTypeName ?? "Pet"}${pet.breed != null ? " · ${pet.breed}" : ""}',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmDialog(
                          title: 'Remove Pet',
                          content:
                              'Are you sure you want to remove ${pet.name}?',
                          onDelete: () {
                            context.read<ProfileBloc>().add(DeletePet(pet.id));
                          },
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),

        // Daily Helpers Section
        Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 24.h,
            bottom: 8.h,
          ),
          child: Text(
            'Daily Help / Service Providers',
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
              if (_isLoadingHelpers)
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: const CircularProgressIndicator(),
                )
              else if (_dailyHelpers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'No daily helpers listed.',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                )
              else
                ..._dailyHelpers.map((helper) {
                  return ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.support_agent_outlined,
                        color: theme.primaryColor,
                      ),
                    ),
                    title: Text(
                      helper['name'] ?? '',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${helper['purpose'] ?? "Service"}${helper['phone'] != null ? " · ${helper['phone']}" : ""}',
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

  Future<void> _showDeleteConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onDelete,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
