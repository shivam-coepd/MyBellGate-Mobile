import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/screens/resident/edit_profile_screen.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:shimmer/shimmer.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<FamilyMember> _filteredFamilyMembers = [];
  late AnimationController _animationController;
  List<Map<String, dynamic>> _dailyHelpers = [];
  bool _isLoadingHelpers = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfile());
    _loadDailyHelpers();

    _searchController.addListener(_filterFamilyMembers);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

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

  // ─────────────────────────────────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAnimatedSection(Widget child, double delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 150).toInt()),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    VoidCallback? onAdd,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 12.h, left: 4.w, right: 4.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (onAdd != null)
            IconButton(
              onPressed: onAdd,
              icon: Icon(
                Icons.add_circle_rounded,
                color: Theme.of(context).primaryColor,
                size: 28.sp,
              ),
              tooltip: 'Add $title',
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32.sp,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String label,
    IconData? prefixIcon,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        child: Text(text),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FAMILY MEMBER CRUD
  // ─────────────────────────────────────────────────────────────────────────

  void _showFamilyMemberBottomSheet({FamilyMember? member}) {
    final isEdit = member != null;
    final nameCtrl = TextEditingController(text: member?.name ?? '');
    final phoneCtrl = TextEditingController(text: member?.phone ?? '');
    String relation = member?.relationship ?? 'Spouse';
    String memberType = member?.memberType ?? 'Adult';
    String? uploadedImageUrl = member?.profileImage;
    bool isUploadingImage = false;
    final s3 = S3UploadService();

    final relationships = [
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    isEdit ? 'Edit Family Member' : 'Add Family Member',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image == null) return;
                        setSheetState(() {
                          isUploadingImage = true;
                          uploadedImageUrl = null;
                        });
                        try {
                          final url = await s3.uploadImage(
                            File(image.path),
                            folder: S3UploadService.folderProfiles,
                          );
                          setSheetState(() => uploadedImageUrl = url);
                        } catch (e) {
                          if (mounted) {
                            AppSnackbar.show(
                              context: context,
                              message: 'Failed: $e',
                              type: SnackBarType.error,
                            );
                          }
                        } finally {
                          setSheetState(() => isUploadingImage = false);
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              image: uploadedImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(uploadedImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: uploadedImageUrl == null
                                ? Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                : null,
                          ),
                          if (isUploadingImage)
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildDropdownField<String>(
                    value: memberType,
                    label: 'Member Type *',
                    prefixIcon: Icons.person_search,
                    items: ['Adult', 'Kid']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) =>
                        setSheetState(() => memberType = v ?? 'Adult'),
                  ),
                  _buildInputField(
                    controller: nameCtrl,
                    label: 'Full Name *',
                    hint: 'Enter family member name',
                    prefixIcon: Icons.person_outline,
                  ),
                  _buildInputField(
                    controller: phoneCtrl,
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildDropdownField<String>(
                    value: relationships.contains(relation)
                        ? relation
                        : 'Other',
                    label: 'Relationship *',
                    prefixIcon: Icons.family_restroom,
                    items: relationships
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) =>
                        setSheetState(() => relation = v ?? 'Other'),
                  ),
                  SizedBox(height: 8.h),
                  _buildPrimaryButton(
                    isEdit ? 'Update Member' : 'Add Member',
                    () {
                      if (nameCtrl.text.trim().isEmpty) {
                        AppSnackbar.show(
                          context: context,
                          message: 'Name is required',
                          type: SnackBarType.error,
                          position: SnackBarPosition.top,
                        );
                        return;
                      }
                      if (isEdit) {
                        context.read<ProfileBloc>().add(
                          UpdateFamilyMember(
                            id: member.id,
                            name: nameCtrl.text.trim(),
                            relation: relation,
                            memberType: memberType,
                            phone: phoneCtrl.text.trim(),
                            imageUrl: uploadedImageUrl,
                          ),
                        );
                      } else {
                        context.read<ProfileBloc>().add(
                          AddFamilyMember(
                            name: nameCtrl.text.trim(),
                            relation: relation,
                            memberType: memberType,
                            phone: phoneCtrl.text.trim().isNotEmpty
                                ? phoneCtrl.text.trim()
                                : null,
                            imageUrl: uploadedImageUrl,
                          ),
                        );
                      }
                      Navigator.pop(ctx);
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VEHICLE CRUD
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _vehicleTypes = [];

  Future<void> _loadVehicleTypes() async {
    if (_vehicleTypes.isNotEmpty) return;
    try {
      _vehicleTypes = await context
          .read<HouseholdRepository>()
          .getVehicleTypes();
    } catch (_) {}
  }

  void _showVehicleBottomSheet({ResidentVehicle? vehicle}) async {
    final isEdit = vehicle != null;
    if (!isEdit) await _loadVehicleTypes();

    final regCtrl = TextEditingController(
      text: vehicle?.registrationNumber ?? '',
    );
    final makeCtrl = TextEditingController(text: vehicle?.make ?? '');
    final modelCtrl = TextEditingController(text: vehicle?.model ?? '');
    final colorCtrl = TextEditingController(text: vehicle?.color ?? '');
    final parkingCtrl = TextEditingController(text: vehicle?.parkingSpot ?? '');
    int selectedTypeId =
        vehicle?.vehicleTypeId ??
        (_vehicleTypes.isNotEmpty ? _vehicleTypes.first['id'] as int : 1);
    bool isElectric = vehicle?.isElectric == 1;
    bool isParked = vehicle?.isParked == 1;
    String? uploadedImageUrl = vehicle?.imageUrl;
    bool isUploadingImage = false;
    final s3 = S3UploadService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    isEdit ? 'Edit Vehicle' : 'Add Vehicle',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image == null) return;
                        setSheetState(() {
                          isUploadingImage = true;
                          uploadedImageUrl = null;
                        });
                        try {
                          final url = await s3.uploadImage(
                            File(image.path),
                            folder: 'vehicles',
                          );
                          setSheetState(() => uploadedImageUrl = url);
                        } catch (e) {
                          if (mounted) {
                            AppSnackbar.show(
                              context: context,
                              message: 'Failed to upload image',
                              type: SnackBarType.error,
                              position: SnackBarPosition.top,
                            );
                          }
                        } finally {
                          setSheetState(() => isUploadingImage = false);
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              image: uploadedImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(uploadedImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: uploadedImageUrl == null
                                ? Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                : null,
                          ),
                          if (isUploadingImage)
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildInputField(
                    controller: regCtrl,
                    label: 'Registration Number *',
                    hint: 'e.g. MH12AB1234',
                    prefixIcon: Icons.badge_outlined,
                    enabled: !isEdit,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  if (_vehicleTypes.isNotEmpty)
                    _buildDropdownField<int>(
                      value: _vehicleTypes.any((t) => t['id'] == selectedTypeId)
                          ? selectedTypeId
                          : _vehicleTypes.first['id'] as int,
                      label: 'Vehicle Type *',
                      prefixIcon: Icons.directions_car,
                      items: _vehicleTypes
                          .map(
                            (t) => DropdownMenuItem(
                              value: t['id'] as int,
                              child: Text(t['name']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSheetState(
                        () => selectedTypeId = v ?? selectedTypeId,
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: makeCtrl,
                          label: 'Make',
                          hint: 'e.g. Honda',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildInputField(
                          controller: modelCtrl,
                          label: 'Model',
                          hint: 'e.g. City',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: colorCtrl,
                          label: 'Color',
                          hint: 'e.g. White',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildInputField(
                          controller: parkingCtrl,
                          label: 'Parking Spot',
                          hint: 'e.g. A-12',
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Electric Vehicle'),
                    value: isElectric,
                    onChanged: (v) => setSheetState(() => isElectric = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Currently Parked'),
                    value: isParked,
                    onChanged: (v) => setSheetState(() => isParked = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 8.h),
                  _buildPrimaryButton(
                    isEdit ? 'Update Vehicle' : 'Add Vehicle',
                    () {
                      final reg = regCtrl.text.trim().toUpperCase();
                      if (reg.isEmpty) {
                        AppSnackbar.show(
                          context: context,
                          message: 'Registration number is required',
                          type: SnackBarType.error,
                          position: SnackBarPosition.top,
                        );
                        return;
                      }
                      if (isEdit) {
                        context.read<ProfileBloc>().add(
                          UpdateVehicle(
                            id: vehicle.id,
                            vehicleTypeId: selectedTypeId,
                            make: makeCtrl.text.trim().isNotEmpty
                                ? makeCtrl.text.trim()
                                : null,
                            model: modelCtrl.text.trim().isNotEmpty
                                ? modelCtrl.text.trim()
                                : null,
                            color: colorCtrl.text.trim().isNotEmpty
                                ? colorCtrl.text.trim()
                                : null,
                            parkingSpot: parkingCtrl.text.trim().isNotEmpty
                                ? parkingCtrl.text.trim()
                                : null,
                            isElectric: isElectric ? 1 : 0,
                            isParked: isParked ? 1 : 0,
                            imageUrl: uploadedImageUrl,
                          ),
                        );
                      } else {
                        context.read<ProfileBloc>().add(
                          AddVehicle(
                            registrationNumber: reg,
                            vehicleTypeId: selectedTypeId,
                            make: makeCtrl.text.trim().isNotEmpty
                                ? makeCtrl.text.trim()
                                : null,
                            model: modelCtrl.text.trim().isNotEmpty
                                ? modelCtrl.text.trim()
                                : null,
                            color: colorCtrl.text.trim().isNotEmpty
                                ? colorCtrl.text.trim()
                                : null,
                            parkingSpot: parkingCtrl.text.trim().isNotEmpty
                                ? parkingCtrl.text.trim()
                                : null,
                            isElectric: isElectric ? 1 : 0,
                            isParked: isParked ? 1 : 0,
                            imageUrl: uploadedImageUrl,
                          ),
                        );
                      }
                      Navigator.pop(ctx);
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PET CRUD
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _petTypes = [];

  Future<void> _loadPetTypes() async {
    if (_petTypes.isNotEmpty) return;
    try {
      _petTypes = await context.read<HouseholdRepository>().getPetTypes();
    } catch (_) {}
  }

  void _showPetBottomSheet({ResidentPet? pet}) async {
    final isEdit = pet != null;
    if (!isEdit) await _loadPetTypes();

    final nameCtrl = TextEditingController(text: pet?.name ?? '');
    final breedCtrl = TextEditingController(text: pet?.breed ?? '');
    final ageCtrl = TextEditingController(text: pet?.age?.toString() ?? '');
    final weightCtrl = TextEditingController(
      text: pet?.weight?.toString() ?? '',
    );
    final notesCtrl = TextEditingController(text: pet?.notes ?? '');
    int selectedTypeId =
        pet?.petTypeId ??
        (_petTypes.isNotEmpty ? _petTypes.first['id'] as int : 1);
    String vaccinationStatus = pet?.vaccinationStatus ?? 'pending';
    String? uploadedImageUrl = pet?.imageUrl;
    bool isUploadingImage = false;
    final s3 = S3UploadService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    isEdit ? 'Edit Pet' : 'Add Pet',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image == null) return;
                        setSheetState(() {
                          isUploadingImage = true;
                          uploadedImageUrl = null;
                        });
                        try {
                          final url = await s3.uploadImage(
                            File(image.path),
                            folder: S3UploadService.folderPets,
                          );
                          setSheetState(() => uploadedImageUrl = url);
                        } catch (e) {
                          if (mounted) {
                            AppSnackbar.show(
                              context: context,
                              message: 'Failed to upload image',
                              type: SnackBarType.error,
                              position: SnackBarPosition.top,
                            );
                          }
                        } finally {
                          setSheetState(() => isUploadingImage = false);
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              image: uploadedImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(uploadedImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: uploadedImageUrl == null
                                ? Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                          if (isUploadingImage)
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildInputField(
                    controller: nameCtrl,
                    label: 'Pet Name *',
                    hint: 'e.g. Bruno',
                    prefixIcon: Icons.pets,
                  ),
                  if (_petTypes.isNotEmpty)
                    _buildDropdownField<int>(
                      value: _petTypes.any((t) => t['id'] == selectedTypeId)
                          ? selectedTypeId
                          : _petTypes.first['id'] as int,
                      label: 'Pet Type *',
                      prefixIcon: Icons.category,
                      items: _petTypes
                          .map(
                            (t) => DropdownMenuItem(
                              value: t['id'] as int,
                              child: Text(t['name']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSheetState(
                        () => selectedTypeId = v ?? selectedTypeId,
                      ),
                    ),
                  _buildInputField(
                    controller: breedCtrl,
                    label: 'Breed',
                    hint: 'e.g. Labrador',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: ageCtrl,
                          label: 'Age (years)',
                          hint: 'e.g. 3',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildInputField(
                          controller: weightCtrl,
                          label: 'Weight (kg)',
                          hint: 'e.g. 12.5',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildDropdownField<String>(
                    value:
                        const [
                          'pending',
                          'up_to_date',
                          'not_vaccinated',
                          'partial',
                          'complete',
                          'not_required',
                        ].contains(vaccinationStatus)
                        ? vaccinationStatus
                        : 'pending',
                    label: 'Vaccination Status',
                    prefixIcon: Icons.vaccines,
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'up_to_date',
                        child: Text('Up to Date'),
                      ),
                      DropdownMenuItem(
                        value: 'not_vaccinated',
                        child: Text('Not Vaccinated'),
                      ),
                      DropdownMenuItem(
                        value: 'partial',
                        child: Text('Partial'),
                      ),
                      DropdownMenuItem(
                        value: 'complete',
                        child: Text('Complete'),
                      ),
                      DropdownMenuItem(
                        value: 'not_required',
                        child: Text('Not Required'),
                      ),
                    ],
                    onChanged: (v) =>
                        setSheetState(() => vaccinationStatus = v ?? 'pending'),
                  ),
                  _buildInputField(
                    controller: notesCtrl,
                    label: 'Notes',
                    hint: 'Any additional notes about your pet',
                    maxLines: 3,
                  ),
                  SizedBox(height: 8.h),
                  _buildPrimaryButton(isEdit ? 'Update Pet' : 'Add Pet', () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      AppSnackbar.show(
                        context: context,
                        message: 'Pet name is required',
                        type: SnackBarType.error,
                        position: SnackBarPosition.top,
                      );
                      return;
                    }
                    final age = int.tryParse(ageCtrl.text.trim());
                    final weight = double.tryParse(weightCtrl.text.trim());
                    if (isEdit) {
                      context.read<ProfileBloc>().add(
                        UpdatePet(
                          id: pet.id,
                          name: name,
                          petTypeId: selectedTypeId,
                          breed: breedCtrl.text.trim().isNotEmpty
                              ? breedCtrl.text.trim()
                              : null,
                          age: age,
                          weight: weight,
                          vaccinationStatus: vaccinationStatus,
                          notes: notesCtrl.text.trim().isNotEmpty
                              ? notesCtrl.text.trim()
                              : null,
                          imageUrl: uploadedImageUrl,
                        ),
                      );
                    } else {
                      context.read<ProfileBloc>().add(
                        AddPet(
                          name: name,
                          petTypeId: selectedTypeId,
                          breed: breedCtrl.text.trim().isNotEmpty
                              ? breedCtrl.text.trim()
                              : null,
                          age: age,
                          weight: weight,
                          vaccinationStatus: vaccinationStatus,
                          notes: notesCtrl.text.trim().isNotEmpty
                              ? notesCtrl.text.trim()
                              : null,
                          imageUrl: uploadedImageUrl,
                        ),
                      );
                    }
                    Navigator.pop(ctx);
                  }),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DAILY HELPER CRUD
  // ─────────────────────────────────────────────────────────────────────────

  void _showDailyHelperBottomSheet({Map<String, dynamic>? helper}) {
    final isEdit = helper != null;
    final nameCtrl = TextEditingController(
      text: helper?['name']?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: helper?['phone']?.toString() ?? '',
    );
    final purposeCtrl = TextEditingController(
      text: helper?['purpose']?.toString() ?? '',
    );
    final visitTimeCtrl = TextEditingController(
      text: helper?['visit_time']?.toString() ?? '',
    );
    String? uploadedImageUrl = helper?['image_url']?.toString();
    bool isUploadingImage = false;
    final s3 = S3UploadService();

    final serviceTypes = [
      'Maid',
      'Cook',
      'Driver',
      'Gardener',
      'Security',
      'Nanny',
      'Laundry',
      'Cleaner',
      'Tutor',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    isEdit ? 'Edit Daily Helper' : 'Add Daily Helper',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image == null) return;
                        setSheetState(() {
                          isUploadingImage = true;
                          uploadedImageUrl = null;
                        });
                        try {
                          final url = await s3.uploadImage(
                            File(image.path),
                            folder: 'visitors',
                          );
                          setSheetState(() => uploadedImageUrl = url);
                        } catch (e) {
                          if (mounted) {
                            AppSnackbar.show(
                              context: context,
                              message: 'Failed to upload image',
                              type: SnackBarType.error,
                              position: SnackBarPosition.top,
                            );
                          }
                        } finally {
                          setSheetState(() => isUploadingImage = false);
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              image: uploadedImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(uploadedImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: uploadedImageUrl == null
                                ? Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                          if (isUploadingImage)
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildInputField(
                    controller: nameCtrl,
                    label: 'Full Name *',
                    hint: 'Enter helper name',
                    prefixIcon: Icons.person_outline,
                  ),
                  _buildInputField(
                    controller: phoneCtrl,
                    label: 'Phone Number *',
                    hint: 'Enter phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildInputField(
                    controller: purposeCtrl,
                    label: 'Service Type *',
                    hint: 'e.g. Maid, Cook, Driver',
                    prefixIcon: Icons.work_outline,
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: serviceTypes.map((s) {
                      bool isSelected = purposeCtrl.text == s;
                      return ChoiceChip(
                        label: Text(
                          s,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            purposeCtrl.text = s;
                            setSheetState(() {});
                          }
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12.h),
                  _buildInputField(
                    controller: visitTimeCtrl,
                    label: 'Visit Time',
                    hint: 'e.g. 08:00 AM',
                    prefixIcon: Icons.access_time,
                  ),
                  SizedBox(height: 8.h),
                  _buildPrimaryButton(
                    isEdit ? 'Update Helper' : 'Add Helper',
                    () {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      final purpose = purposeCtrl.text.trim();
                      if (name.isEmpty || phone.isEmpty || purpose.isEmpty) {
                        AppSnackbar.show(
                          context: context,
                          message: 'Name, Phone and Service Type are required',
                          type: SnackBarType.error,
                          position: SnackBarPosition.top,
                        );
                        return;
                      }
                      if (isEdit) {
                        final helperId =
                            int.tryParse(helper['id'].toString()) ?? 0;
                        context.read<ProfileBloc>().add(
                          UpdateDailyHelper(
                            id: helperId,
                            name: name,
                            phone: phone,
                            serviceType: purpose,
                            visitTime: visitTimeCtrl.text.trim().isNotEmpty
                                ? visitTimeCtrl.text.trim()
                                : null,
                            imageUrl: uploadedImageUrl,
                          ),
                        );
                      } else {
                        context.read<ProfileBloc>().add(
                          AddDailyHelper(
                            name: name,
                            phone: phone,
                            serviceType: purpose,
                            visitTime: visitTimeCtrl.text.trim().isNotEmpty
                                ? visitTimeCtrl.text.trim()
                                : null,
                            imageUrl: uploadedImageUrl,
                          ),
                        );
                      }
                      Navigator.pop(ctx);
                      _loadDailyHelpers();
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
          _filterFamilyMembers();
        } else if (state is HouseholdUpdateSuccess) {
          AppSnackbar.show(
            context: context,
            message: state.message,
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
          _loadDailyHelpers();
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
        if (state is ProfileLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile Details"),
              actions: [
                TextButton(child: const Text('Edit'), onPressed: () {}),
              ],
            ),
            body: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeaderShimmer(theme),
                  SizedBox(height: 130.h), // Increased for new header design
                  _buildBioCardShimmer(theme),
                  _buildProfileSectionsShimmer(theme),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
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
            title: const Text("Profile Details"),
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
                  _buildProfileHeader(user),
                  SizedBox(
                    height: 130.h,
                  ), // Increased to account for name/unit below avatar
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildBioCard(user),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildProfileSections(user, theme),
                  ),
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
    final surfaceColor = isDarkMode
        ? AppTheme.surfaceDark
        : AppTheme.surfaceLight;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
          child: SizedBox(
            height: 180.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      user.coverImageUrl ??
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -125.h,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: user.profileImage ?? "",
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 55.r,
                    backgroundColor: surfaceColor,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: CircleAvatar(
                      radius: 55.r,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 55.r,
                    backgroundColor: surfaceColor,
                    child: Icon(Icons.person, size: 45.sp, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              if (user.unit != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Unit ${user.unit}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioCard(User user) {
    return _buildAnimatedSection(
      Card(
        elevation: 0,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: Theme.of(context).primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
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
                    SizedBox(height: 6.h),
                    Text(
                      user.bio ?? '',
                      style: TextStyle(fontSize: 14.sp, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      1,
    );
  }

  Widget _buildProfileSections(User user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedSection(
          _buildSectionHeader('Personal Information', Icons.info_outline),
          0,
        ),
        _buildAnimatedSection(_buildPersonalInfoCard(user, theme), 1),

        _buildAnimatedSection(
          _buildSectionHeader(
            'Family Members',
            Icons.people_outline,
            onAdd: () => _showFamilyMemberBottomSheet(),
          ),
          2,
        ),
        _buildAnimatedSection(_buildFamilyMembersList(user, theme), 3),

        _buildAnimatedSection(
          _buildSectionHeader(
            'Vehicles',
            Icons.directions_car_outlined,
            onAdd: () => _showVehicleBottomSheet(),
          ),
          4,
        ),
        _buildAnimatedSection(_buildVehiclesList(user, theme), 5),

        _buildAnimatedSection(
          _buildSectionHeader(
            'Pets',
            Icons.pets_outlined,
            onAdd: () => _showPetBottomSheet(),
          ),
          6,
        ),
        _buildAnimatedSection(_buildPetsList(user, theme), 7),

        _buildAnimatedSection(
          _buildSectionHeader(
            'Daily Help Providers',
            Icons.support_agent_outlined,
            onAdd: () => _showDailyHelperBottomSheet(),
          ),
          8,
        ),
        _buildAnimatedSection(_buildHelpersList(theme), 9),
      ],
    );
  }

  Widget _buildPersonalInfoCard(User user, ThemeData theme) {
    final personalItems = [
      {'label': 'Name', 'value': user.name, 'icon': Icons.person_outline},
      {
        'label': 'Email',
        'value': user.email.isEmpty ? 'N/A' : user.email,
        'icon': Icons.email_outlined,
      },
      {'label': 'Phone', 'value': user.phone, 'icon': Icons.phone_outlined},
      {
        'label': 'Unit',
        'value': user.unit ?? 'N/A',
        'icon': Icons.home_outlined,
      },
      {
        'label': 'Society ID',
        'value': user.societyId ?? 'N/A',
        'icon': Icons.domain_outlined,
      },
      if (user.residentType != null)
        {
          'label': 'Resident Type',
          'value': user.residentType!,
          'icon': Icons.badge_outlined,
        },
      if (user.profession != null && user.profession!.isNotEmpty)
        {
          'label': 'Profession',
          'value': user.profession!,
          'icon': Icons.work_outline,
        },
      if (user.hometown != null && user.hometown!.isNotEmpty)
        {
          'label': 'Hometown',
          'value': user.hometown!,
          'icon': Icons.location_city_outlined,
        },
    ];

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: personalItems.map((item) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 20.sp,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item['value'] as String,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFamilyMembersList(User user, ThemeData theme) {
    final familyMembersList = user.familyMembers ?? [];
    if (familyMembersList.isEmpty) {
      return _buildEmptyState(
        'No family members listed.',
        Icons.people_outline,
      );
    }
    return Column(
      children: familyMembersList
          .map((member) => _buildFamilyMemberCard(member, theme))
          .toList(),
    );
  }

  Widget _buildFamilyMemberCard(FamilyMember member, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: member.profileImage != null
                  ? NetworkImage(member.profileImage!)
                  : null,
              child: member.profileImage == null
                  ? Icon(Icons.person, size: 24.sp, color: theme.primaryColor)
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (member.isActive)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    member.relationship,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (member.phone != null && member.phone!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          member.phone!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showFamilyMemberBottomSheet(member: member),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20.sp,
                    color: theme.primaryColor,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
                SizedBox(height: 4.h),
                IconButton(
                  onPressed: () => _showDeleteConfirmDialog(
                    title: 'Remove Family Member',
                    content: 'Are you sure you want to remove ${member.name}?',
                    onDelete: () => context.read<ProfileBloc>().add(
                      DeleteFamilyMember(member.id),
                    ),
                  ),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.sp,
                    color: Colors.red.shade400,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList(User user, ThemeData theme) {
    final vehicles = user.vehicles ?? [];
    if (vehicles.isEmpty) {
      return _buildEmptyState(
        'No vehicles listed.',
        Icons.directions_car_outlined,
      );
    }
    return Column(
      children: vehicles
          .map((vehicle) => _buildVehicleCard(vehicle, theme))
          .toList(),
    );
  }

  Widget _buildVehicleCard(ResidentVehicle vehicle, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                color: theme.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.registrationNumber,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (vehicle.isElectric == 1)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12.r),
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
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        vehicle.typeName ?? 'Vehicle',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (vehicle.isParked == 1)
                        Text(
                          '  (Parked)',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.red.shade700,
                          ),
                        ),
                    ],
                  ),
                  if (vehicle.make != null || vehicle.model != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      [
                        vehicle.make,
                        vehicle.model,
                      ].where((s) => s != null && s.isNotEmpty).join(' '),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                  if (vehicle.color != null && vehicle.color!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        Text(vehicle.color!, style: TextStyle(fontSize: 13.sp)),
                      ],
                    ),
                  ],
                  if (vehicle.parkingSpot != null &&
                      vehicle.parkingSpot!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.local_parking,
                          size: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Spot: ${vehicle.parkingSpot!}',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showVehicleBottomSheet(vehicle: vehicle),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20.sp,
                    color: theme.primaryColor,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
                SizedBox(height: 4.h),
                IconButton(
                  onPressed: () => _showDeleteConfirmDialog(
                    title: 'Remove Vehicle',
                    content:
                        'Are you sure you want to remove ${vehicle.registrationNumber}?',
                    onDelete: () => context.read<ProfileBloc>().add(
                      DeleteVehicle(vehicle.id),
                    ),
                  ),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.sp,
                    color: Colors.red.shade400,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsList(User user, ThemeData theme) {
    final pets = user.pets ?? [];
    if (pets.isEmpty) {
      return _buildEmptyState('No pets listed.', Icons.pets_outlined);
    }
    return Column(
      children: pets.map((pet) => _buildPetCard(pet, theme)).toList(),
    );
  }

  Widget _buildPetCard(ResidentPet pet, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                  ? NetworkImage(pet.imageUrl!)
                  : null,
              child: pet.imageUrl == null || pet.imageUrl!.isEmpty
                  ? Icon(Icons.pets, color: theme.primaryColor, size: 24.sp)
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${pet.petTypeName ?? "Pet"}${pet.breed != null && pet.breed!.isNotEmpty ? " · ${pet.breed}" : ""}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (pet.age != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Age: ${pet.age} years',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                  if (pet.weight != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Weight: ${pet.weight} kg',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                  if (pet.vaccinationStatus != null &&
                      pet.vaccinationStatus!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: pet.vaccinationStatus == 'complete'
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Vaccination: ${pet.vaccinationStatus!}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: pet.vaccinationStatus == 'complete'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showPetBottomSheet(pet: pet),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20.sp,
                    color: theme.primaryColor,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
                SizedBox(height: 4.h),
                IconButton(
                  onPressed: () => _showDeleteConfirmDialog(
                    title: 'Remove Pet',
                    content: 'Are you sure you want to remove ${pet.name}?',
                    onDelete: () =>
                        context.read<ProfileBloc>().add(DeletePet(pet.id)),
                  ),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.sp,
                    color: Colors.red.shade400,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpersList(ThemeData theme) {
    if (_isLoadingHelpers) {
      return Container(
        padding: EdgeInsets.all(16.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_dailyHelpers.isEmpty) {
      return _buildEmptyState(
        'No daily helpers listed.',
        Icons.support_agent_outlined,
      );
    }
    return Column(
      children: _dailyHelpers
          .map((helper) => _buildHelperCard(helper, theme))
          .toList(),
    );
  }

  Widget _buildHelperCard(Map<String, dynamic> helper, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.support_agent_outlined,
                color: theme.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    helper['name']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    helper['purpose']?.toString() ?? 'Service',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (helper['phone'] != null) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          helper['phone'].toString(),
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ],
                  if (helper['visit_time'] != null &&
                      helper['visit_time'].toString().isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Visit: ${helper['visit_time']}',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showDailyHelperBottomSheet(helper: helper),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20.sp,
                    color: theme.primaryColor,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
                SizedBox(height: 4.h),
                IconButton(
                  onPressed: () {
                    final helperId = int.tryParse(helper['id'].toString()) ?? 0;
                    _showDeleteConfirmDialog(
                      title: 'Remove Daily Help',
                      content:
                          'Are you sure you want to remove ${helper['name'] ?? "this helper"}?',
                      onDelete: () {
                        context.read<ProfileBloc>().add(
                          DeleteDailyHelper(helperId),
                        );
                        _loadDailyHelpers();
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.sp,
                    color: Colors.red.shade400,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderShimmer(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -125.h,
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 110.r,
                  height: 110.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor,
                    border: Border.all(color: Colors.white, width: 4.w),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 150.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 80.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioCardShimmer(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 0,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: 100.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSectionsShimmer(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Info
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 180.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: List.generate(
              5,
              (index) => _buildShimmerListTile(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ),
          ),
        ),

        // Family
        Padding(
          padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 150.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: List.generate(
              2,
              (index) => _buildShimmerListTileWithAvatar(
                baseColor: baseColor,
                highlightColor: highlightColor,
                showSubtitle: true,
              ),
            ),
          ),
        ),

        // Vehicles
        Padding(
          padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 80.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: List.generate(
              1,
              (index) => _buildShimmerListTileWithIcon(
                baseColor: baseColor,
                highlightColor: highlightColor,
                showSubtitle: true,
              ),
            ),
          ),
        ),

        // Pets
        Padding(
          padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 50.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: List.generate(
              1,
              (index) => _buildShimmerListTileWithAvatar(
                baseColor: baseColor,
                highlightColor: highlightColor,
                showSubtitle: true,
              ),
            ),
          ),
        ),

        // Helpers
        Padding(
          padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 220.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: List.generate(
              1,
              (index) => _buildShimmerListTileWithIcon(
                baseColor: baseColor,
                highlightColor: highlightColor,
                showSubtitle: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerListTile({
    required Color baseColor,
    required Color highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListTile(
        title: Container(
          width: 100.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        trailing: Container(
          width: 80.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerListTileWithAvatar({
    required Color baseColor,
    required Color highlightColor,
    bool showSubtitle = false,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListTile(
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: baseColor),
        ),
        title: Container(
          width: 120.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        subtitle: showSubtitle
            ? Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 80.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              )
            : null,
        trailing: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildShimmerListTileWithIcon({
    required Color baseColor,
    required Color highlightColor,
    bool showSubtitle = false,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListTile(
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: baseColor),
        ),
        title: Container(
          width: 140.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        subtitle: showSubtitle
            ? Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 100.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              )
            : null,
        trailing: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
        ),
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade400,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
