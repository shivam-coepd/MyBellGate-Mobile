import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AmenityBookingScreen extends StatefulWidget {
  const AmenityBookingScreen({super.key});

  @override
  State<AmenityBookingScreen> createState() => _AmenityBookingScreenState();
}

class _AmenityBookingScreenState extends State<AmenityBookingScreen> with TickerProviderStateMixin {
  String _selectedDate = '2023-05-15';
  String _selectedTime = '18:00';
  int _selectedAmenityId = 1; // Use ID instead of index
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredAmenities = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _amenities = [
    {
      'id': 1,
      'name': 'Swimming Pool',
      'image':
          'https://plus.unsplash.com/premium_photo-1675745329659-29044cb6adbb?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8U3dpbW1pbmclMjBQb29sfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
      'description': 'Olympic size swimming pool with lifeguard',
      'availableSlots': [
        '06:00',
        '08:00',
        '10:00',
        '12:00',
        '14:00',
        '16:00',
        '18:00',
        '20:00',
      ],
    },
    {
      'id': 2,
      'name': 'Gym',
      'image':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=400&h=300',
      'description': 'Fully equipped fitness center',
      'availableSlots': [
        '06:00',
        '08:00',
        '10:00',
        '12:00',
        '14:00',
        '16:00',
        '18:00',
        '20:00',
      ],
    },
    {
      'id': 3,
      'name': 'Tennis Court',
      'image':
          'https://images.unsplash.com/photo-1564769353575-73f33a36d84f?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8J1Rlbm5pcyUyMENvdXJ0fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
      'description': 'Professional tennis court with lights',
      'availableSlots': [
        '06:00',
        '08:00',
        '10:00',
        '12:00',
        '14:00',
        '16:00',
        '18:00',
        '20:00',
      ],
    },
    {
      'id': 4,
      'name': 'Community Hall',
      'image':
          'https://media.istockphoto.com/id/1466734442/photo/empty-community-centre.webp?a=1&b=1&s=612x612&w=0&k=20&c=qWKFFRwhxvMuHH4hpJrF0bY0ldAcae0II1hvXef-3K4=',
      'description': 'Multi-purpose hall for events',
      'availableSlots': ['09:00', '11:00', '13:00', '15:00', '17:00', '19:00'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredAmenities = _amenities;
    _selectedAmenityId = _amenities.isNotEmpty ? _amenities[0]['id'] : 1; // Set initial ID
    _searchController.addListener(_filterAmenities);
    
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

  void _filterAmenities() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();
      
      _filteredAmenities = _amenities.where((amenity) {
        return searchTerm.isEmpty || 
            amenity['name'].toLowerCase().contains(searchTerm) ||
            amenity['description'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAmenities);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amenity Booking', style: TextStyle(fontSize: 18.sp)),
        actions: [
          ScaleTransition(
            scale: _fadeAnimation,
            child: IconButton(
              icon: Icon(Icons.search, size: 24.sp),
              onPressed: _showSearchBar,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amenity Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Amenity',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  _filteredAmenities.isEmpty
                      ? _buildEmptyState()
                      : SizedBox(
                          height: 200.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filteredAmenities.length,
                            itemBuilder: (context, index) {
                              final amenity = _filteredAmenities[index];
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      0.1 * index,
                                      0.3 + (0.1 * index),
                                      curve: Curves.elasticOut,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedAmenityId = amenity['id']),
                                  child: Container(
                                    width: 150.w,
                                    margin: EdgeInsets.only(right: 16.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: _selectedAmenityId == amenity['id']
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: amenity['image'],
                                            fit: BoxFit.cover,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withValues(alpha: 0.7),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10.h,
                                            left: 10.w,
                                            right: 10.w,
                                            child: Text(
                                              amenity['name'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),

              SizedBox(height: 16.h),

              // Amenity Details
              if (_filteredAmenities.isNotEmpty)
                ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.2, 0.5, curve: Curves.elasticOut),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSelectedAmenity()['name'],
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _getSelectedAmenity()['description'],
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 16.h),

              // Date Selection
              if (_filteredAmenities.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        // color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final formattedDate =
                              '${date.day}/${date.month}/${date.year}';
                          final isSelected =
                              _selectedDate ==
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          return ScaleTransition(
                            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  0.1 * index,
                                  0.3 + (0.1 * index),
                                  curve: Curves.elasticOut,
                                ),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedDate =
                                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              }),
                              child: Container(
                                margin: EdgeInsets.only(right: 10.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.withValues(alpha: 0.3),
                                    width: 1.w,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.color,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 16.h),

              // Time Selection
              if (_filteredAmenities.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Time Slot',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: _getSelectedAmenity()['availableSlots']
                          .asMap()
                          .entries
                          .map<Widget>((entry) {
                            final index = entry.key;
                            final slot = entry.value;
                            final isSelected = _selectedTime == slot;
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    0.05 * index,
                                    0.25 + (0.05 * index),
                                    curve: Curves.elasticOut,
                                  ),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTime = slot),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.withValues(alpha: 0.5),
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).textTheme.bodyLarge?.color,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ],
                ),

              SizedBox(height: 30.h),
              // Book Button
              if (_filteredAmenities.isNotEmpty)
                ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.4, 0.7, curve: Curves.elasticOut),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D77),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Book Amenity',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search amenities...',
                  prefixIcon: Icon(Icons.search, size: 24.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D77),
                  ),
                  child: Text('Search', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getSelectedAmenity() {
    // Find the amenity with the selected ID
    for (var amenity in _filteredAmenities) {
      if (amenity['id'] == _selectedAmenityId) {
        return amenity;
      }
    }
    // If not found, return the first amenity or an empty map
    return _filteredAmenities.isNotEmpty ? _filteredAmenities[0] : {};
  }

  String _formatSelectedDate() {
    final date = DateTime.parse(_selectedDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmBooking() {
    final selectedAmenity = _getSelectedAmenity();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Amenity Booking', style: TextStyle(fontSize: 18.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amenity: ${selectedAmenity['name']}', style: TextStyle(fontSize: 16.sp)),
              Text('Date: ${_formatSelectedDate()}', style: TextStyle(fontSize: 16.sp)),
              Text('Time: $_selectedTime', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 16.h),
              Text('Please confirm to proceed with booking', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Process the booking
                _completeBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('Confirm', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  void _completeBooking() {
    final selectedAmenity = _getSelectedAmenity();
    
    // Show booking processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 20.h),
              Text('Processing booking...', style: TextStyle(fontSize: 16.sp)),
            ],
          ),
        );
      },
    );

    // Simulate booking processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close processing dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booking confirmed for ${selectedAmenity['name']} on ${_formatSelectedDate()} at $_selectedTime',
              style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Colors.green,
        ),
      );

      // Reset selection
      setState(() {
        _selectedDate = DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0];
        _selectedTime = selectedAmenity['availableSlots'][0];
      });
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.sports_tennis,
              size: 50.sp,
              color: const Color(0xFF006D77),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No amenities found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Text(
            _searchController.text.isEmpty
                ? 'There are no amenities available'
                : 'No amenities match your search',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}