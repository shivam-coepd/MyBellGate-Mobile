import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  void _showEditSheet(User user) {
    final theme = Theme.of(context);
    // Extract building and flat from unit string e.g. "A-Wing - 101"
    final parts = (user.unit ?? '').split(' - ');
    final buildingCtrl = TextEditingController(
      text: parts.isNotEmpty ? parts[0].trim() : '',
    );
    final flatCtrl = TextEditingController(
      text: parts.length > 1 ? parts[1].trim() : '',
    );
    final floorCtrl = TextEditingController(text: '');
    final areaCtrl = TextEditingController(text: '');
    String ownerType = user.residentType ?? 'owner';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, sSet) => Container(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 20.h,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Edit Property Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Update your property information',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: buildingCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Building / Wing',
                    hintText: 'e.g. A-Wing',
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: flatCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Flat Number',
                    hintText: 'e.g. 101',
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: floorCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Floor',
                    hintText: 'e.g. 3',
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: areaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Area (sq.ft)',
                    hintText: 'e.g. 1200',
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Ownership',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    for (final t in ['owner', 'tenant', 'family'])
                      ChoiceChip(
                        label: Text(t[0].toUpperCase() + t.substring(1)),
                        selected: ownerType == t,
                        selectedColor: theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        onSelected: (v) => v ? sSet(() => ownerType = t) : null,
                      ),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppSnackbar.show(
                        context: context,
                        message: 'Property details updated successfully',
                        type: SnackBarType.success,
                      );
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        title: const Text('Property Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            onPressed: () {
              final user = context.read<UserRepository>().getCurrentUser();
              if (user != null) _showEditSheet(user);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (ctx, state) {
          final user = (state is ProfileLoaded)
              ? state.user
              : context.read<UserRepository>().getCurrentUser();

          if (user == null) {
            return const Center(child: Text('No property data available'));
          }

          // Parse unit into building and flat
          final parts = (user.unit ?? '').split(' - ');
          final building = parts.isNotEmpty ? parts[0].trim() : 'N/A';
          final flat = parts.length > 1 ? parts[1].trim() : 'N/A';
          final floorNumber = parts.length > 1
              ? parts[1].trim()[0].toString()
              : 'N/A';
          final area = "${user.flats?.first.areaSqft.toString()} Sq.Ft";

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Property Header Card ──────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.05,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.apartment,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.unit ?? 'Property',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'PRIMARY ADDRESS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Status',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      user.status != null
                                          ? user.status![0].toUpperCase() +
                                                user.status!.substring(1)
                                          : 'Active',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Type',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      user.residentType != null
                                          ? user.residentType![0]
                                                    .toUpperCase() +
                                                user.residentType!.substring(1)
                                          : 'Owner',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Property Information ──────────────────────────────────
                SizedBox(height: 16.h),
                Text(
                  'PROPERTY INFORMATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        theme,
                        Icons.apartment_outlined,
                        'Building / Wing',
                        building,
                      ),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(
                        theme,
                        Icons.door_front_door_outlined,
                        'Flat Number',
                        flat,
                      ),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(
                        theme,
                        Icons.layers_outlined,
                        'Floor',
                        floorNumber,
                      ),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(theme, Icons.square_foot_outlined, 'Area', area),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(
                        theme,
                        Icons.home_work_outlined,
                        'Ownership',
                        user.residentType ?? 'Owner',
                      ),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(
                        theme,
                        Icons.calendar_today_outlined,
                        'Registered Since',
                        user.createdAt != null
                            ? _formatDate(user.createdAt!)
                            : 'N/A',
                      ),
                    ],
                  ),
                ),

                // ── Society Information ───────────────────────────────────
                SizedBox(height: 16.h),
                Text(
                  'SOCIETY INFORMATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        theme,
                        Icons.business_outlined,
                        'Society ID',
                        user.societyId ?? 'N/A',
                      ),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(
                        theme,
                        Icons.verified_user_outlined,
                        'Approval Status',
                        user.isApproved == true ? 'Approved' : 'Pending',
                      ),
                    ],
                  ),
                ),

                // ── Resident Info ─────────────────────────────────────────
                SizedBox(height: 16.h),
                Text(
                  'RESIDENT INFORMATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _infoRow(theme, Icons.person_outline, 'Name', user.name),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(
                        theme,
                        Icons.email_outlined,
                        'Email',
                        user.email,
                      ),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      _infoRow(
                        theme,
                        Icons.phone_outlined,
                        'Phone',
                        user.phone,
                      ),
                      if (user.profession != null) ...[
                        Divider(
                          height: 0,
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        _infoRow(
                          theme,
                          Icons.work_outline,
                          'Profession',
                          user.profession!,
                        ),
                      ],
                      if (user.hometown != null) ...[
                        Divider(
                          height: 0,
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        _infoRow(
                          theme,
                          Icons.location_city_outlined,
                          'Hometown',
                          user.hometown!,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditSheet(user),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Property Details'),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return d;
    }
  }
}
