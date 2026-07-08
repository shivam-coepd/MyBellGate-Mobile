import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';

class EIntercomScreen extends StatefulWidget {
  const EIntercomScreen({super.key});

  @override
  State<EIntercomScreen> createState() => _EIntercomScreenState();
}

class _EIntercomScreenState extends State<EIntercomScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<GuardBloc>().add(const LoadResidents(limit: 100));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _callResident(String phone, String name) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      AppSnackbar.show(
        context: context,
        message: 'Cannot call $name',
        type: SnackBarType.error,
      );
    }
  }

  void _search(String query) {
    context.read<GuardBloc>().add(
      LoadResidents(
        search: query.trim().isEmpty ? null : query.trim(),
        limit: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Intercom'),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<GuardBloc>().add(const LoadResidents(limit: 100)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<GuardBloc, GuardState>(
        listener: (context, state) {
          if (state is GuardError) {
            AppSnackbar.show(
              context: context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          final residents = state is ResidentsLoaded
              ? state.residents
              : <Map<String, dynamic>>[];
          final isLoading = state is GuardLoading;

          return Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search resident by name or phone...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              _search('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _search,
                ),
              ),

              // Info card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Card(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primary,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            'Tap the call icon to ring a resident for visitor approval.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : residents.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          if (await AppInternetCheck()
                              .hasInternetConnection()) {
                            if (context.mounted) {
                              context.read<GuardBloc>().add(
                                const LoadResidents(limit: 100),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              AppInternetCheck.checkInternet(context: context);
                            }
                          }
                        },
                        child: ListView(
                          children: [
                            SizedBox(height: 120.h),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64.sp,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No residents found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (await AppInternetCheck()
                              .hasInternetConnection()) {
                            if (context.mounted) {
                              context.read<GuardBloc>().add(
                                const LoadResidents(limit: 100),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              AppInternetCheck.checkInternet(context: context);
                            }
                          }
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: residents.length,
                          itemBuilder: (_, i) =>
                              _buildResidentCard(residents[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResidentCard(Map<String, dynamic> resident) {
    final name = resident['name'] ?? 'Unknown';
    final phone = resident['phone'] ?? '';
    final flatNumber = resident['flat_number'] ?? '-';
    final imageUrl = resident['profile_image'];

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              backgroundImage: imageUrl != null
                  ? CachedNetworkImageProvider(imageUrl)
                  : null,
              child: imageUrl == null
                  ? Icon(Icons.person, color: AppTheme.primary, size: 24.sp)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Flat: $flatNumber',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.onBackgroundLight,
                    ),
                  ),
                  if (phone.isNotEmpty)
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.onBackgroundLight,
                      ),
                    ),
                ],
              ),
            ),
            if (phone.isNotEmpty)
              IconButton(
                onPressed: () => _callResident(phone, name),
                icon: Icon(Icons.call, color: AppTheme.primary, size: 24.sp),
                tooltip: 'Call $name',
              ),
          ],
        ),
      ),
    );
  }
}
