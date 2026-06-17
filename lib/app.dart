import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/accounting/accounting_bloc.dart';
import 'package:mygate_coepd/blocs/amenity/amenity_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/communications/communications_bloc.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/blocs/helpdesk/helpdesk_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/theme/theme_cubit.dart';
import 'package:mygate_coepd/repositories/accounting_repository.dart';
import 'package:mygate_coepd/repositories/amenity_repository.dart';
import 'package:mygate_coepd/repositories/communications_repository.dart';
import 'package:mygate_coepd/repositories/guard_repository.dart';
import 'package:mygate_coepd/repositories/helpdesk_repository.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/screens/auth/auth_screen.dart';
import 'package:mygate_coepd/screens/auth/onboarding_screen.dart';
import 'package:mygate_coepd/screens/auth/role_selection_screen.dart';
import 'package:mygate_coepd/screens/auth/splash_screen.dart';
import 'package:mygate_coepd/screens/guard/guard_main_screen.dart';
import 'package:mygate_coepd/screens/resident/amenity_booking_screen.dart';
import 'package:mygate_coepd/screens/resident/announcements_screen.dart';
import 'package:mygate_coepd/screens/resident/bills_payments_screen.dart';
import 'package:mygate_coepd/screens/resident/community_screen.dart';
import 'package:mygate_coepd/screens/resident/notifications_screen.dart';
import 'package:mygate_coepd/screens/resident/profile_details_screen.dart';
import 'package:mygate_coepd/screens/resident/profile_screen.dart';
import 'package:mygate_coepd/screens/resident/resident_main_screen.dart';
import 'package:mygate_coepd/screens/resident/service_requests_screen.dart';
import 'package:mygate_coepd/screens/resident/visitor_management_screen.dart';
import 'package:mygate_coepd/services/api_service.dart';
import 'package:mygate_coepd/services/fcm_service.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _MyGateBellState();
}

class _MyGateBellState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Hand the global navigator key to FcmService so it can deep-link
    FcmService.navigatorKey = apiNavigatorKey;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // This will trigger a rebuild when the system theme changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    log("Log Screen size: $screenWidth x $screenHeight");
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard/common mobile device size
      // designSize: Size(screenWidth, screenHeight), // According to current device size
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<UserRepository>(
            create: (context) => UserRepository(),
          ),
          RepositoryProvider<HouseholdRepository>(
            create: (context) => HouseholdRepository(),
          ),
          RepositoryProvider<AmenityRepository>(
            create: (context) => AmenityRepository(),
          ),
          RepositoryProvider<HelpdeskRepository>(
            create: (context) => HelpdeskRepository(),
          ),
          RepositoryProvider<CommunicationsRepository>(
            create: (context) => CommunicationsRepository(),
          ),
          RepositoryProvider<AccountingRepository>(
            create: (context) => AccountingRepository(),
          ),
          RepositoryProvider<GuardRepository>(
            create: (context) => GuardRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) =>
                  AuthBloc(userRepository: context.read<UserRepository>()),
            ),
            BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(
                userRepository: context.read<UserRepository>(),
                householdRepository: context.read<HouseholdRepository>(),
              ),
            ),
            BlocProvider<AmenityBloc>(
              create: (context) =>
                  AmenityBloc(repository: context.read<AmenityRepository>()),
            ),
            BlocProvider<HelpdeskBloc>(
              create: (context) =>
                  HelpdeskBloc(repository: context.read<HelpdeskRepository>()),
            ),
            BlocProvider<CommunicationsBloc>(
              create: (context) => CommunicationsBloc(
                repository: context.read<CommunicationsRepository>(),
              ),
            ),
            BlocProvider<AccountingBloc>(
              create: (context) => AccountingBloc(
                repository: context.read<AccountingRepository>(),
              ),
            ),
            BlocProvider<GuardBloc>(
              create: (context) =>
                  GuardBloc(repository: context.read<GuardRepository>()),
            ),
            BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                navigatorKey: apiNavigatorKey,
                title: 'App',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                initialRoute: '/',
                routes: {..._getMainRoutes()},
                debugShowCheckedModeBanner: false,
              );
            },
          ),
        ),
      ),
    );
  }

  static Map<String, WidgetBuilder> _getMainRoutes() {
    return {
      '/': (context) => const SplashScreen(),
      '/onboarding': (context) => const OnboardingScreen(),
      '/role-selection': (context) => const RoleSelectionScreen(),
      '/auth': (context) => const AuthScreen(),
      '/resident-main': (context) => const ResidentMainScreen(),
      '/resident-main/visitors': (context) =>
          ResidentMainScreen(initialTabIndex: 1),
      '/resident-main/services': (context) =>
          ResidentMainScreen(initialTabIndex: 2),
      '/resident-main/bills': (context) =>
          ResidentMainScreen(initialTabIndex: 3),
      '/resident-main/community': (context) =>
          ResidentMainScreen(initialTabIndex: 4),
      '/guard-main': (context) => const GuardMainScreen(),
      '/visitors': (context) => const VisitorManagementScreen(),
      '/announcements': (context) => const AnnouncementsScreen(),
      '/services': (context) => const ServiceRequestsScreen(),
      '/bills': (context) => const BillsPaymentsScreen(),
      '/amenities': (context) => const AmenityBookingScreen(),
      '/community': (context) => const CommunityScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/profile-details': (context) => const ProfileDetailsScreen(),
      '/resident-notifications': (context) => const NotificationsScreen(),
      '/security': (context) => const NotificationsScreen(), // Placeholder — swap for SecurityAlertsScreen when built
      '/otp-verification': (context) => throw UnimplementedError(
        'OTP Verification Screen requires parameters',
      ),
    };
  }
}
