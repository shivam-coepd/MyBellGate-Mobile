import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/screens/auth/address/WhoAreYouScreen.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class BuildingUnitSelectionScreen extends StatefulWidget {
  final int societyId; // Pass this from previous screen

  const BuildingUnitSelectionScreen({super.key, required this.societyId});

  @override
  State<BuildingUnitSelectionScreen> createState() =>
      _BuildingUnitSelectionScreenState();
}

class _BuildingUnitSelectionScreenState
    extends State<BuildingUnitSelectionScreen> {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://app.mygatebell.com/backend'; // Replace with actual {{app_url}}

  List<dynamic> buildings = [];
  Map<String, dynamic>? selectedBuilding;
  int? selectedFloor;
  String? selectedFlat;
  List<dynamic> flatsOnSelectedFloor = [];

  bool isLoadingBuildings = true;
  bool isLoadingFlats = false;

  @override
  void initState() {
    super.initState();
    _fetchBuildings();
  }

  Future<void> _fetchBuildings() async {
    setState(() => isLoadingBuildings = true);
    try {
      final response = await _dio.get(
        '$baseUrl/api/buildings/by-society/${widget.societyId}',
      );
      if (response.data['status'] == true) {
        setState(() {
          buildings = response.data['data'];
          isLoadingBuildings = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching buildings: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load buildings')));
      setState(() => isLoadingBuildings = false);
    }
  }

  Future<void> _fetchFlats(int buildingId) async {
    setState(() => isLoadingFlats = true);
    try {
      final response = await _dio.get(
        '$baseUrl/api/flats/by-building/$buildingId',
      );
      if (response.data['status'] == true) {
        final allFlats = response.data['data']['flats'] as List<dynamic>;
        setState(() {
          if (selectedFloor != null) {
            flatsOnSelectedFloor = allFlats
                .where(
                  (flat) =>
                      flat['floor_number'].toString() ==
                      selectedFloor.toString(),
                )
                .toList();
          }
          isLoadingFlats = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching flats: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load flats')));
      setState(() => isLoadingFlats = false);
    }
  }

  void _onBuildingSelected(Map<String, dynamic> building) {
    setState(() {
      selectedBuilding = building;
      selectedFloor = null;
      selectedFlat = null;
      flatsOnSelectedFloor = [];
    });
    debugPrint(
      'Selected Building: ${building['name']} (ID: ${building['id']})',
    );
    _fetchFlats(building['id']);
  }

  void _onFloorSelected(int floor) async {
    setState(() {
      selectedFloor = floor;
      selectedFlat = null;
      isLoadingFlats = true;
      // Reset the flats list immediately when selecting a new floor
      flatsOnSelectedFloor = [];
    });
    debugPrint('Selected Floor: $floor');

    try {
      final response = await _dio.get(
        '$baseUrl/api/flats/by-building/${selectedBuilding!['id']}',
      );
      if (response.data['status'] == true) {
        final allFlats = response.data['data']['flats'] as List<dynamic>;
        final filteredFlats = allFlats
            .where(
              (flat) => flat['floor_number'].toString() == floor.toString(),
            )
            .toList();

        setState(() {
          flatsOnSelectedFloor = filteredFlats;
          isLoadingFlats = false;
        });

        // Debug print to help diagnose issues
        debugPrint('Flats found for floor $floor: ${filteredFlats.length}');
      } else {
        // If API returns success but with no data, ensure we show the empty state
        setState(() {
          flatsOnSelectedFloor = [];
          isLoadingFlats = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching flats: $e');
      // Ensure we show the empty state even when there's an error
      setState(() {
        flatsOnSelectedFloor = [];
        isLoadingFlats = false;
      });
    }
  }

  void _onFlatSelected(String flatNumber) {
    setState(() {
      selectedFlat = flatNumber;
    });
    debugPrint('Selected Flat: $flatNumber');
  }

  // Simple placeholder for shimmer effect without external package
  Widget _buildShimmerGrid(
    int count, {
    double aspectRatio = 1.4,
    int crossAxisCount = 2,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.onBackgroundLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final selectedRole = AppConfig.selectedRole ?? 'resident';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppTheme.backgroundDark
        : AppTheme.backgroundLight;
    final surfaceColor = isDarkMode
        ? AppTheme.surfaceDark
        : AppTheme.surfaceLight;
    final textColor = isDarkMode
        ? AppTheme.onPrimary
        : AppTheme.onBackgroundLight;
    final iconColor = AppTheme.primary;

    final bool canContinue = selectedFlat != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // Header with role info - Matching AuthScreen design
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative background elements
                  Positioned(
                    top: -30.h,
                    right: -30.w,
                    child: Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.onPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -25.h,
                    left: 30.w,
                    child: Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.onPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      top: 50.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppTheme.onPrimary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                selectedRole == 'guard'
                                    ? Icons.shield_outlined
                                    : selectedRole == 'admin'
                                    ? Icons.admin_panel_settings_outlined
                                    : Icons.home_outlined,
                                color: AppTheme.onPrimary,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registering as',
                                  style: TextStyle(
                                    color: AppTheme.onPrimary.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  selectedRole == 'guard'
                                      ? 'Security Guard'
                                      : selectedRole == 'admin'
                                      ? 'Administrator'
                                      : 'Resident',
                                  style: TextStyle(
                                    color: AppTheme.onPrimary,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Select Your Home',
                          style: TextStyle(
                            color: AppTheme.onPrimary,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Choose building, floor, and flat',
                          style: TextStyle(
                            color: AppTheme.onPrimary.withValues(alpha: 0.9),
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Building Selection
                    Text(
                      'Building',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    isLoadingBuildings
                        ? _buildShimmerGrid(
                            4,
                            aspectRatio: 1.4,
                            crossAxisCount: 2,
                          )
                        : buildings.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 60.h),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.apartment_outlined,
                                    size: 80.sp,
                                    color: AppTheme.onBackgroundLight
                                        .withValues(alpha: 0.4),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    'No buildings found',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textColor.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'This society currently has no registered buildings.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: textColor.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.4,
                                  crossAxisSpacing: 16.w,
                                  mainAxisSpacing: 16.h,
                                ),
                            itemCount: buildings.length,
                            itemBuilder: (context, index) {
                              final building = buildings[index];
                              final isSelected =
                                  selectedBuilding?['id'] == building['id'];
                              return GestureDetector(
                                onTap: () => _onBuildingSelected(building),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? iconColor
                                        : surfaceColor,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: isDarkMode
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: AppTheme.onBackgroundLight
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 8.r,
                                              offset: Offset(0, 4.h),
                                            ),
                                          ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apartment,
                                        size: 36.sp,
                                        color: isSelected
                                            ? AppTheme.onPrimary
                                            : iconColor,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        building['name'],
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppTheme.onPrimary
                                              : textColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '${building['total_floors']} Floors',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isSelected
                                              ? AppTheme.onPrimary.withValues(
                                                  alpha: 0.7,
                                                )
                                              : textColor.withValues(
                                                  alpha: 0.6,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    if (selectedBuilding != null) ...[
                      SizedBox(height: 20.h),

                      Text(
                        'Floor',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      // Safety check: if total_floors is 0 or null
                      selectedBuilding!['total_floors'] <= 0
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 30.h,
                                ), // Reduced vertical padding
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.layers_outlined,
                                      size: 70.sp,
                                      color: AppTheme.onBackgroundLight
                                          .withValues(alpha: 0.4),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'No floors present',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: textColor.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'This building has no floors registered.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: textColor.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    childAspectRatio: 1.2,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                  ),
                              itemCount: selectedBuilding!['total_floors'],
                              itemBuilder: (context, index) {
                                final floor = index + 1;
                                final isSelected = selectedFloor == floor;
                                return GestureDetector(
                                  onTap: () => _onFloorSelected(floor),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? iconColor
                                          : surfaceColor,
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: isDarkMode
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: AppTheme
                                                    .onBackgroundLight
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 6.r,
                                              ),
                                            ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$floor',
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppTheme.onPrimary
                                              : textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],

                    if (selectedFloor != null) ...[
                      SizedBox(height: 20.h),

                      if (isLoadingFlats)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flat Number (Floor $selectedFloor)',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildShimmerGrid(
                              4,
                              aspectRatio: 1.4,
                              crossAxisCount: 4,
                            ),
                          ],
                        )
                      else ...[
                        Text(
                          'Flat Number (Floor $selectedFloor)',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        flatsOnSelectedFloor.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30.h),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.home_outlined,
                                        size: 70.sp,
                                        color: AppTheme.onBackgroundLight
                                            .withValues(alpha: 0.4),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'No flats present on this floor',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: textColor.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'No units are registered on Floor $selectedFloor.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: textColor.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 1.4,
                                      crossAxisSpacing: 16.w,
                                      mainAxisSpacing: 16.h,
                                    ),
                                itemCount: flatsOnSelectedFloor.length,
                                itemBuilder: (context, index) {
                                  final flat = flatsOnSelectedFloor[index];
                                  final isSelected =
                                      selectedFlat == flat['flat_number'];
                                  return GestureDetector(
                                    onTap: () =>
                                        _onFlatSelected(flat['flat_number']),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? iconColor
                                            : surfaceColor,
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        boxShadow: isDarkMode
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: AppTheme
                                                      .onBackgroundLight
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 8.r,
                                                  offset: Offset(0, 4.h),
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          flat['flat_number'],
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AppTheme.onPrimary
                                                : textColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ],

                    SizedBox(
                      height: 30.h,
                    ), // Reduced spacing before continue button
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: canContinue
                            ? () {
                                debugPrint('Final Selection:');
                                debugPrint(
                                  'Building: ${selectedBuilding!['name']}',
                                );
                                debugPrint('Floor: $selectedFloor');
                                debugPrint('Flat: $selectedFlat');

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WhoAreYouScreen(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: isDarkMode ? 2 : 5,
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onPrimary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
