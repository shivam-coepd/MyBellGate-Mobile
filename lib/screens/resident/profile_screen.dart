import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFamilyMembers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _profileSections = [
    {
      'title': 'Personal Information',
      'items': [
        {'label': 'Name', 'value': 'John Doe'},
        {'label': 'Email', 'value': 'john.doe@example.com'},
        {'label': 'Phone', 'value': '+91 9876543210'},
        {'label': 'Unit', 'value': 'A-101'},
        {'label': 'Society', 'value': 'Green Valley Apartments'},
      ],
    },
    {
      'title': 'Family Members',
      'items': [
        {
          'name': 'Jane Doe',
          'relationship': 'Spouse',
          'image':
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
        },
        {
          'name': 'Jimmy Doe',
          'relationship': 'Son',
          'image':
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
        },
      ],
    },
  ];

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
    // Initialize filtered family members with all members
    _filteredFamilyMembers = List<Map<String, dynamic>>.from(
      _profileSections.firstWhere(
        (section) => section['title'] == 'Family Members',
      )['items'],
    );
    _searchController.addListener(_filterFamilyMembers);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animations after a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _filterFamilyMembers() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();

      List<Map<String, dynamic>> allFamilyMembers =
          List<Map<String, dynamic>>.from(
            _profileSections.firstWhere(
              (section) => section['title'] == 'Family Members',
            )['items'],
          );

      _filteredFamilyMembers = allFamilyMembers.where((member) {
        return searchTerm.isEmpty ||
            member['name'].toLowerCase().contains(searchTerm) ||
            member['relationship'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFamilyMembers);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 18.sp)),
        // actions: [
        //   ScaleTransition(
        //     scale: _fadeAnimation,
        //     child: IconButton(
        //       icon: Icon(Icons.search, size: 24.sp),
        //       onPressed: _showSearchBar,
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            SizedBox(height: 20.h),
            // Profile Sections
            _buildProfileSections(),
            SizedBox(height: 20.h),
            // Settings
            ScaleTransition(
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
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
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
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            subtitle: Text(
                              setting['subtitle'],
                              style: TextStyle(fontSize: 14.sp),
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
                                // Handle settings navigation
                                switch (index) {
                                  case 2:
                                    _showPrivacyDialog();
                                    break;
                                  case 3:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Language settings would open here',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
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
                              color: Colors.grey.withValues(alpha: 0.3),
                              indent: 16.w,
                              endIndent: 16.w,
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Logout Button
            Padding(
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
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     Theme.of(context).primaryColor,
        //     Theme.of(context).primaryColor.withValues(alpha: 0.9),
        //   ],
        // ),
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: Colors.white, width: 3.w),
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundImage: const CachedNetworkImageProvider(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16.sp,
                      color: const Color(0xFF006D77),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Resident • A-101',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                  ),
                ),
                SizedBox(height: 10.h),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Verified Resident',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSections() {
    return Column(
      children: _profileSections.map((section) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  section['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (section['title'] == 'Personal Information')
                _buildPersonalInfoSection(section['items'])
              else if (section['title'] == 'Family Members')
                _buildFamilyMembersSection(section['items'])
              else
                _buildGenericSection(section['items']),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalInfoSection(List<dynamic> items) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardTheme.color!,
              Theme.of(context).cardTheme.color!.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: items.map((item) {
            return ListTile(
              title: Text(
                item['label'],
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
              ),
              trailing: Text(
                item['value'],
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              onTap: () {
                _showEditInfoDialog(item['label'], item['value']);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFamilyMembersSection(List<dynamic> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).cardTheme.color!,
                    Theme.of(context).cardTheme.color!.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  ...items.map((member) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20.r,
                        backgroundImage: CachedNetworkImageProvider(
                          member['image'],
                        ),
                      ),
                      title: Text(
                        member['name'],
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      subtitle: Text(
                        member['relationship'],
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade600,
                          size: 24.sp,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditFamilyMemberDialog(member);
                          } else if (value == 'delete') {
                            _showDeleteFamilyMemberDialog(member);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              'Edit',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Divider(
                    color: Colors.grey.withValues(alpha: 0.3),
                    height: 1.h,
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    title: Text(
                      'Add Family Member',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    onTap: _showAddFamilyMemberDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericSection(List<dynamic> items) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardTheme.color!,
              Theme.of(context).cardTheme.color!.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: items.map((item) {
            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: item['icon'] == Icons.fingerprint
                      ? (_biometricEnabled
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1))
                      : item['icon'] == Icons.notifications
                      ? (_notificationsEnabled
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1))
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  item['icon'],
                  color: item['icon'] == Icons.fingerprint
                      ? (_biometricEnabled ? Colors.green : Colors.grey)
                      : item['icon'] == Icons.notifications
                      ? (_notificationsEnabled ? Colors.blue : Colors.grey)
                      : Colors.grey,
                  size: 24.sp,
                ),
              ),
              title: Text(item['title'], style: TextStyle(fontSize: 16.sp)),
              subtitle: Text(
                item['subtitle'],
                style: TextStyle(fontSize: 14.sp),
              ),
              trailing: item['icon'] == Icons.fingerprint
                  ? Switch(
                      value: _biometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                      },
                      activeThumbColor: Theme.of(context).primaryColor,
                    )
                  : item['icon'] == Icons.notifications
                  ? Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeThumbColor: Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: Colors.grey,
                    ),
              onTap: () {
                // Handle generic section item tap
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showEditInfoDialog(String label, String value) {
    final TextEditingController _controller = TextEditingController(
      text: value,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter $label'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label updated successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddFamilyMemberDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _relationshipController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Family Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _relationshipController,
                decoration: const InputDecoration(hintText: 'Relationship'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty &&
                    _relationshipController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _addFamilyMember(
                    _nameController.text.trim(),
                    _relationshipController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addFamilyMember(String name, String relationship) {
    // Add to family members list
    final newMember = {
      'name': name,
      'relationship': relationship,
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    };

    setState(() {
      // Find family members section and add new member
      for (var i = 0; i < _profileSections.length; i++) {
        if (_profileSections[i]['title'] == 'Family Members') {
          _profileSections[i]['items'].add(newMember);
          break;
        }
      }
      _filterFamilyMembers(); // Refresh filtered list
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Family member added successfully')),
    );
  }

  void _showEditFamilyMemberDialog(Map<String, dynamic> member) {
    final TextEditingController _nameController = TextEditingController(
      text: member['name'],
    );
    final TextEditingController _relationshipController = TextEditingController(
      text: member['relationship'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Family Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _relationshipController,
                decoration: const InputDecoration(hintText: 'Relationship'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty &&
                    _relationshipController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _editFamilyMember(
                    member,
                    _nameController.text.trim(),
                    _relationshipController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editFamilyMember(
    Map<String, dynamic> member,
    String name,
    String relationship,
  ) {
    setState(() {
      // Find and update the family member
      for (var i = 0; i < _profileSections.length; i++) {
        if (_profileSections[i]['title'] == 'Family Members') {
          for (var j = 0; j < _profileSections[i]['items'].length; j++) {
            if (_profileSections[i]['items'][j]['name'] == member['name']) {
              _profileSections[i]['items'][j] = {
                'name': name,
                'relationship': relationship,
                'image': member['image'],
              };
              break;
            }
          }
          break;
        }
      }
      _filterFamilyMembers(); // Refresh filtered list
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Family member updated successfully')),
    );
  }

  void _showDeleteFamilyMemberDialog(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Family Member'),
          content: Text('Are you sure you want to delete ${member['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFamilyMember(member);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFamilyMember(Map<String, dynamic> member) {
    setState(() {
      // Find and remove the family member
      for (var i = 0; i < _profileSections.length; i++) {
        if (_profileSections[i]['title'] == 'Family Members') {
          _profileSections[i]['items'].removeWhere(
            (item) => item['name'] == member['name'],
          );
          break;
        }
      }
      _filterFamilyMembers(); // Refresh filtered list
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${member['name']} deleted successfully')),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: Radio<String>(
                  value: 'en',
                  groupValue: 'en',
                  onChanged: (value) {},
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language set to English')),
                  );
                },
              ),
              ListTile(
                title: const Text('Hindi'),
                trailing: Radio<String>(
                  value: 'hi',
                  groupValue: null,
                  onChanged: (value) {},
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language set to Hindi')),
                  );
                },
              ),
            ],
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

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search family members...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D77),
                  ),
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
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
                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
