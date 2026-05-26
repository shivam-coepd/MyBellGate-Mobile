import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/screens/auth/address/LocationSelectionScreen.dart';
import 'package:mygate_coepd/screens/resident/profile_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/screens/auth/splash_screen.dart';
import 'package:mygate_coepd/screens/auth/onboarding_screen.dart';
import 'package:mygate_coepd/screens/auth/role_selection_screen.dart';
import 'package:mygate_coepd/screens/auth/auth_screen.dart';
import 'package:mygate_coepd/screens/resident/resident_main_screen.dart';
import 'package:mygate_coepd/screens/guard/guard_main_screen.dart';
import 'package:mygate_coepd/screens/resident/visitor_management_screen.dart';
import 'package:mygate_coepd/screens/resident/announcements_screen.dart';
import 'package:mygate_coepd/screens/resident/service_requests_screen.dart';
import 'package:mygate_coepd/screens/resident/bills_payments_screen.dart';
import 'package:mygate_coepd/screens/resident/amenity_booking_screen.dart';
import 'package:mygate_coepd/screens/resident/community_screen.dart';
import 'package:mygate_coepd/screens/resident/profile_details_screen.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        hasShownError = false;
      });

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'An error has occurred',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(details.exceptionAsString(), style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              'Please restart the app and try again.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  };

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FamilyMemberAdapter());
  Hive.registerAdapter(ResidentVehicleAdapter());
  Hive.registerAdapter(ResidentPetAdapter());

  // Initialize app configuration
  await AppConfig.init();

  // runApp(const MyGateBell());
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(const MyGateBell());
  });
}

class MyGateBell extends StatefulWidget {
  const MyGateBell({super.key});

  @override
  State<MyGateBell> createState() => _MyGateBellState();
}

class _MyGateBellState extends State<MyGateBell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    return Sizer(
      builder: (context, orientation, screenType) {
        return ScreenUtilInit(
          designSize: const Size(
            375,
            812,
          ), // Standard/common mobile device size
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
              ],
              child: MaterialApp(
                title: 'MyGateBell',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                initialRoute: '/',
                routes: {..._getMainRoutes()},
                debugShowCheckedModeBanner: false,
              ),
            ),
          ),
        );
      },
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
      '/location-selection': (context) => const LocationSelectionScreen(),
      '/otp-verification': (context) => throw UnimplementedError(
        'OTP Verification Screen requires parameters',
      ),
    };
  }
}
