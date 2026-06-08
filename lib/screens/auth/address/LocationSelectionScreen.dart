import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/screens/auth/address/BuildingUnitSelectionScreen.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://app.mygatebell.com/backend'; // REPLACE WITH YOUR ACTUAL BASE URL

  final TextEditingController _societyController = TextEditingController();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _societyFocus = FocusNode();

  // Selected values
  Map<String, dynamic>? selectedCountry;
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedSociety;

  // Data lists
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> searchedSocieties = [];

  // Loading states
  bool isLoadingCountries = true;
  bool isLoadingCities = false;
  bool isLoadingSocieties = false;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _societyController.dispose();
    _cityFocus.dispose();
    _societyFocus.dispose();
    super.dispose();
  }

  // Fetch Countries
  Future<void> _fetchCountries() async {
    setState(() => isLoadingCountries = true);
    try {
      final response = await _dio.get('$baseUrl/api/locations/countries');
      if (response.data['status'] == true) {
        setState(() {
          countries = List<Map<String, dynamic>>.from(response.data['data']);
          isLoadingCountries = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load countries')));
      setState(() => isLoadingCountries = false);
    }
  }

  // Fetch Cities by selected country
  Future<void> _fetchCities(String countryName) async {
    setState(() => isLoadingCities = true);
    try {
      final response = await _dio.get(
        '$baseUrl/api/locations/cities/by-country/$countryName',
      );
      if (response.data['status'] == true) {
        setState(() {
          cities = List<Map<String, dynamic>>.from(response.data['data']);
          isLoadingCities = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load cities')));
      setState(() => isLoadingCities = false);
    }
  }

  // Primary + City-Filtered Suggestions
  Future<List<Map<String, dynamic>>> _fetchSocietySuggestions(
    String query,
  ) async {
    if (query.trim().isEmpty || selectedCity == null) {
      return [];
    }

    setState(() => isLoadingSocieties = true);
    List<Map<String, dynamic>> suggestions = [];

    try {
      // Step 1: Use global search API
      final response = await _dio.get(
        '$baseUrl/api/societies/search',
        queryParameters: {'q': query.trim()},
      );

      if (response.data['status'] == true) {
        final List<dynamic> results = response.data['data'];
        suggestions = results.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Global search failed: $e');
      // Continue to fallback
    }

    // Step 2: ALWAYS filter results to match selected city only
    final String selectedCityName = selectedCity!['name']
        .toString()
        .toLowerCase();

    suggestions = suggestions.where((society) {
      final societyCity = society['city']?.toString().toLowerCase() ?? '';
      return societyCity == selectedCityName;
    }).toList();

    // Optional Step 3: If no results from search, fallback to city-specific list
    if (suggestions.isEmpty) {
      try {
        final fallbackResponse = await _dio.get(
          '$baseUrl/api/admin/societies',
          queryParameters: {
            'page': 1,
            'limit': 50,
            'city': selectedCity!['name'],
          },
        );

        if (fallbackResponse.data['status'] == true) {
          final List<dynamic> allInCity = fallbackResponse.data['data']['data'];
          final List<Map<String, dynamic>> citySocieties = allInCity
              .cast<Map<String, dynamic>>();

          final lowerQuery = query.toLowerCase();
          suggestions = citySocieties.where((s) {
            return s['name'].toString().toLowerCase().contains(lowerQuery) ||
                s['address'].toString().toLowerCase().contains(lowerQuery);
          }).toList();
        }
      } catch (e) {
        debugPrint('Fallback city list failed: $e');
      }
    }

    if (mounted) setState(() => isLoadingSocieties = false);
    return suggestions;
  }

  void _onCountrySelected(Map<String, dynamic> country) {
    setState(() {
      selectedCountry = country;
      selectedCity = null;
      selectedSociety = null;
      _societyController.clear();
      cities = [];
    });
    debugPrint('Selected Country: ${country['name']}');
    _fetchCities(country['name']);
    _cityFocus.requestFocus();
  }

  void _onCitySelected(Map<String, dynamic> city) {
    setState(() {
      selectedCity = city;
      selectedSociety = null;
      _societyController.clear();
    });
    debugPrint('Selected City: ${city['name']}');
    _societyFocus.requestFocus();
  }

  void _onSocietySelected(Map<String, dynamic> society) {
    setState(() {
      selectedSociety = society;
      _societyController.text = society['name'];
    });
    debugPrint('Selected Society: ${society['name']} (ID: ${society['id']})');
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
    final secondaryTextColor = isDarkMode
        ? AppTheme.onPrimary.withValues(alpha: 0.7)
        : AppTheme.onBackgroundLight;
    final iconColor = AppTheme.primary;

    final bool canContinue = selectedSociety != null;

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
                          'Find Your Society',
                          style: TextStyle(
                            color: AppTheme.onPrimary,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Select country, city, and society',
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
                    // Country Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                  color: AppTheme.onBackgroundLight.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 5.h),
                                ),
                              ],
                      ),
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: selectedCountry,
                        hint: Text(
                          'Select Country',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.public_outlined,
                            color: iconColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 18.h,
                          ),
                        ),
                        items: countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(country['name']),
                          );
                        }).toList(),
                        onChanged: isLoadingCountries
                            ? null
                            : (value) => _onCountrySelected(
                                value as Map<String, dynamic>,
                              ),
                        isExpanded: true,
                      ),
                    ),

                    if (selectedCountry != null) ...[
                      SizedBox(height: 20.h),
                      // City Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: isDarkMode
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppTheme.onBackgroundLight
                                        .withValues(alpha: 0.1),
                                    blurRadius: 10.r,
                                    offset: Offset(0, 5.h),
                                  ),
                                ],
                        ),
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          focusNode: _cityFocus,
                          initialValue: selectedCity,
                          hint: Text(
                            'Select City',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: iconColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 18.h,
                            ),
                          ),
                          items: cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city['name']),
                            );
                          }).toList(),
                          onChanged: isLoadingCities
                              ? null
                              : (value) => _onCitySelected(
                                  value as Map<String, dynamic>,
                                ),
                          isExpanded: true,
                        ),
                      ),
                    ],

                    if (selectedCity != null) ...[
                      SizedBox(height: 20.h),
                      // Society Search with Real API
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: isDarkMode
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppTheme.onBackgroundLight
                                        .withValues(alpha: 0.1),
                                    blurRadius: 10.r,
                                    offset: Offset(0, 5.h),
                                  ),
                                ],
                        ),
                        child: TypeAheadField<Map<String, dynamic>>(
                          controller: _societyController,
                          focusNode: _societyFocus,
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Search Society Name',
                                labelStyle: TextStyle(
                                  color: secondaryTextColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.apartment_outlined,
                                  color: iconColor,
                                ),
                                suffixIcon: isLoadingSocieties
                                    ? Padding(
                                        padding: EdgeInsets.all(12.w),
                                        child: SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 18.h,
                                ),
                              ),
                            );
                          },
                          suggestionsCallback: _fetchSocietySuggestions,
                          itemBuilder: (context, society) {
                            return ListTile(
                              leading: Icon(Icons.apartment, color: iconColor),
                              title: Text(
                                society['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                '${society['address']}\n${society['city']}, ${society['state']}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: secondaryTextColor,
                                ),
                              ),
                            );
                          },
                          onSelected: _onSocietySelected,
                          emptyBuilder: (_) => Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              'No societies found',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: ElevatedButton(
                          onPressed: canContinue
                              ? () {
                                  debugPrint('Final Selection:');
                                  debugPrint(
                                    'Country: ${selectedCountry!['name']}',
                                  );
                                  debugPrint('City: ${selectedCity!['name']}');
                                  debugPrint(
                                    'Society: ${selectedSociety!['name']} (ID: ${selectedSociety!['id']})',
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BuildingUnitSelectionScreen(
                                            societyId: selectedSociety!['id'],
                                          ),
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
                    ],

                    SizedBox(height: 40.h),
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
