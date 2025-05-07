import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phychological_counselor/ai_chat/screens/chat_screen.dart';
import 'package:phychological_counselor/home/screens/home_screen.dart';
import 'package:phychological_counselor/features/video_call/video_call_screen.dart';

import '../../../data/local/user_database.dart';
import '../../global.dart';
import 'name.dart';

class AppPage {
  static List<PageEntity> routes = [
    PageEntity(
      route: AppRoutes.videoCall,
      page: const VideoCallScreen(),
    ),
    PageEntity(
      route: AppRoutes.initial,
      page: HomeScreen(),
    ),
    // PageEntity(
    //   route: AppRoutes.login,
    //   page: const LoginScreen(),
    //   bloc: BlocProvider(
    //     create: (_) => LoginBloc(),
    //   ),
    // ),
    // PageEntity(
    //   route: AppRoutes.register,
    //   page: const RegistrationScreen(),
    //   bloc: BlocProvider(
    //     create: (_) => RegisterBloc(),
    //   ),
    // ),
    // PageEntity(
    //   route: AppRoutes.home,
    //   page: const HomeScreen(),
    //
    // ),
    // PageEntity(
    //   route: AppRoutes.application,
    //   page: const ApplicationPage(),
    //   bloc: BlocProvider(
    //     create: (_) => AppBlocs(),
    //   ),
    // ),
    // PageEntity(
    //   route: AppRoutes.forgetPassword,
    //   page: ForgotPasswordScreen(),
    // ),
    // PageEntity(
    //   route: AppRoutes.forgetNotification,
    //   page: const ForgotNotificationScreen(),
    // ),
    // PageEntity(
    //   route: AppRoutes.profile,
    //   page: const ProfileScreen(),
    //   bloc: BlocProvider(
    //     create: (_) => ProfileBloc(databaseHelper: DatabaseHelper()),
    //   ),
    // ),
  ];

  static List<BlocProvider> allBlocProviders(BuildContext context) {
    List<BlocProvider> blocProviders = <BlocProvider>[];
    for (var bloc in routes) {
      if (bloc.bloc != null) {
        blocProviders.add(bloc.bloc as BlocProvider);
      }
    }
    return blocProviders;
  }

  static MaterialPageRoute generateRouteSettings(RouteSettings settings) {
    var result = routes.where((element) => element.route == settings.name);
    if (result.isNotEmpty) {
      bool deviceFirstOpen = Global.storageServices.getDeviceFirstOpen();
      bool isLoggedIn = Global.storageServices.getIsLoggedIn();

      if (result.first.route == AppRoutes.initial) {
        if (!deviceFirstOpen) {
          return MaterialPageRoute(
              builder: (_) => HomeScreen(), settings: settings);
        } else if (isLoggedIn) {
          return MaterialPageRoute(
              builder: (_) => const HomeScreen(), settings: settings);
        } else {
          return MaterialPageRoute(
              builder: (_) => const HomeScreen(), settings: settings);
        }
      }
      return MaterialPageRoute(
          builder: (_) => result.first.page, settings: settings);
    }
    return MaterialPageRoute(
        builder: (_) => HomeScreen(), settings: settings);
  }
}

class PageEntity {
  String route;
  Widget page;
  dynamic bloc;
  PageEntity({required this.route, required this.page, this.bloc});
}
