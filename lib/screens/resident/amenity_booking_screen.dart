import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/amenity/amenity_bloc.dart';
import 'package:mygate_coepd/models/amenity.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:shimmer/shimmer.dart';

class AmenityBookingScreen extends StatefulWidget {
  const AmenityBookingScreen({super.key});
  @override
  State<AmenityBookingScreen> createState() => _AmenityBookingScreenState();
}

class _AmenityBookingScreenState extends State<AmenityBookingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animCtrl;

  Amenity? _selected;
  String _date = '';
  String _startSlot = '06:00';
  List<Amenity> _amenities = [];

  static const _slots = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final n = DateTime.now();
    _date =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animCtrl.forward();
      context.read<AmenityBloc>().add(const LoadAmenities());
    });
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        context.read<AmenityBloc>().add(const LoadMyBookings());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  String _endSlot() {
    final h = (int.parse(_startSlot.split(':')[0]) + 1).clamp(0, 23);
    return '${h.toString().padLeft(2, '0')}:00';
  }

  void _book() {
    if (_selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select an amenity')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amenity: ${_selected!.name}'),
            Text('Date: $_date'),
            Text('Time: $_startSlot – ${_endSlot()}'),
            if (_selected!.bookingFee > 0)
              Text(
                'Fee: ₹${_selected!.bookingFee.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AmenityBloc>().add(
                BookAmenity(
                  amenityId: _selected!.id,
                  bookingDate: _date,
                  startTime: '$_startSlot:00',
                  endTime: '${_endSlot()}:00',
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AmenityBloc, AmenityState>(
      listener: (ctx, state) {
        if (state is AmenityBookingSuccess) {
          AppSnackbar.show(
            context: context,
            message: 'Booking requested for ${_selected?.name}!',
            type: SnackBarType.success,
          );
          context.read<AmenityBloc>().add(const LoadMyBookings());
          _tabController.animateTo(1);
        } else if (state is AmenityError) {
          AppSnackbar.show(
            context: context,
            message: 'Failed to book amenity',
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Amenity Booking'),
          bottom: TabBar(
            controller: _tabController,
            // labelColor: theme.colorScheme.onSurface,
            dividerColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            indicatorColor: theme.primaryColor,
            unselectedLabelColor: theme.primaryColor,
            labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Book'),
              Tab(text: 'My Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildBookTab(), _buildMyBookingsTab()],
        ),
      ),
    );
  }

  Widget _buildBookTab() {
    return BlocBuilder<AmenityBloc, AmenityState>(
      builder: (ctx, state) {
        if (state is AmenityLoading) {
          return const _AmenityBookShimmer();
        }
        if (state is AmenityError) {
          return _errorWidget(
            state.message,
            () => ctx.read<AmenityBloc>().add(const LoadAmenities()),
          );
        }
        if (state is AmenitiesLoaded) {
          _amenities = state.amenities;
          if (_selected == null && _amenities.isNotEmpty) {
            _selected = _amenities.first;
          }
        }
        if (_amenities.isEmpty) {
          return _emptyWidget(
            'No Amenities',
            'No active amenities in your society.',
          );
        }
        return _bookContent(state);
      },
    );
  }

  Widget _bookContent(AmenityState state) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<AmenityBloc>().add(const LoadAmenities()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Amenity',
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 180.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _amenities.length,
                itemBuilder: (_, i) {
                  final a = _amenities[i];
                  final sel = _selected?.id == a.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = a),
                    child: Container(
                      width: 140.w,
                      margin: EdgeInsets.only(right: 14.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: sel
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            a.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: a.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) =>
                                        Container(color: Colors.grey.shade200),
                                  )
                                : Container(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.sports,
                                      size: 40.sp,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.65),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8.h,
                              left: 8.w,
                              right: 8.w,
                              child: Text(
                                a.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            if (a.bookingFee > 0)
                              Positioned(
                                top: 6.h,
                                right: 6.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '₹${a.bookingFee.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

            if (_selected != null) ...[
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(14.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selected!.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selected!.description != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        _selected!.description!,
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.people, size: 15.sp, color: Colors.grey),
                        SizedBox(width: 5.w),
                        Text(
                          'Capacity: ${_selected!.capacity}',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),
              Text(
                'Select Date',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 60.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (_, i) {
                    final d = DateTime.now().add(Duration(days: i));
                    final ds =
                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    final sel = _date == ds;
                    final day = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][d.weekday - 1];
                    return GestureDetector(
                      onTap: () => setState(() => _date = ds),
                      child: Container(
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: sel
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: sel ? Colors.white70 : Colors.grey,
                              ),
                            ),
                            Text(
                              '${d.day}/${d.month}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: sel
                                    ? Colors.white
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 18.h),
              Text(
                'Select Start Time',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                'Slot: $_startSlot – ${_endSlot()} (1 hour)',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: _slots.map((s) {
                  final sel = _startSlot == s;
                  return GestureDetector(
                    onTap: () => setState(() => _startSlot = s),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: sel
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: sel ? Colors.white : null,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is AmenityLoading ? null : _book,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: state is AmenityLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Book Amenity',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookingsTab() {
    return BlocBuilder<AmenityBloc, AmenityState>(
      builder: (ctx, state) {
        if (state is AmenityLoading) {
          return const _AmenityBookingsShimmer();
        }
        if (state is AmenityError) {
          return _errorWidget(
            state.message,
            () => ctx.read<AmenityBloc>().add(const LoadMyBookings()),
          );
        }
        if (state is BookingsLoaded) {
          if (state.bookings.isEmpty) {
            return _emptyWidget(
              'No Bookings',
              'Book an amenity to see it here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ctx.read<AmenityBloc>().add(const LoadMyBookings()),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.bookings.length,
              itemBuilder: (_, i) {
                final b = state.bookings[i];
                Color sc;
                switch (b.status) {
                  case 'confirmed':
                    sc = Colors.green;
                    break;
                  case 'cancelled':
                    sc = Colors.red;
                    break;
                  case 'completed':
                    sc = Colors.blue;
                    break;
                  case 'already_booked':
                    sc = Colors.deepOrange;
                    break;
                  default:
                    sc = Colors.orange;
                }
                return Card(
                  margin: EdgeInsets.only(bottom: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.amenityName ?? 'Amenity #${b.amenityId}',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    b.bookingDate,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: sc,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                b.statusLabel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 15.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '${b.startTime} – ${b.endTime}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                              ),
                            ),
                            if (b.totalAmount > 0) ...[
                              const Spacer(),
                              Text(
                                '₹${b.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _errorWidget(String msg, VoidCallback retry) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56.sp, color: Colors.red),
          SizedBox(height: 14.h),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 18.h),
          ElevatedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  Widget _emptyWidget(String t, String s) => Center(
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
            size: 48.sp,
            color: const Color(0xFF006D77),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          t,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          s,
          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// Shimmer for the Book tab (amenity cards + date/time selectors)
class _AmenityBookShimmer extends StatelessWidget {
  const _AmenityBookShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Container(
              height: 18.h,
              width: 130.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 12.h),
            // Horizontal amenity cards
            SizedBox(
              height: 180.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, _) => Container(
                  width: 140.w,
                  margin: EdgeInsets.only(right: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            // Date section title
            Container(
              height: 18.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 10.h),
            // Date chips
            SizedBox(
              height: 60.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (_, _) => Container(
                  width: 60.w,
                  margin: EdgeInsets.only(right: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            // Time section title
            Container(
              height: 18.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 10.h),
            // Time slot chips
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: List.generate(
                8,
                (_) => Container(
                  width: 60.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer for the My Bookings tab
class _AmenityBookingsShimmer extends StatelessWidget {
  const _AmenityBookingsShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (_, _) => Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14.h,
                            width: 120.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            height: 12.h,
                            width: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 70.w,
                      height: 26.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      height: 11.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      height: 11.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
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
}
