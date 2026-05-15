import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_layout.dart';
import 'logic/blocs/overview/overview_bloc.dart';
import 'logic/blocs/overview/overview_event.dart';
import 'logic/blocs/places/places_bloc.dart';
import 'logic/blocs/places/places_event.dart';
import 'logic/blocs/inquiries/inquiries_bloc.dart';
import 'logic/blocs/inquiries/inquiries_event.dart';
import 'logic/blocs/users/users_bloc.dart';
import 'logic/blocs/users/users_event.dart';
import 'logic/blocs/rewards/rewards_bloc.dart';
import 'logic/blocs/rewards/rewards_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DZGuideAdminApp());
}

class DZGuideAdminApp extends StatelessWidget {
  const DZGuideAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OverviewBloc()..add(LoadOverviewData()),
        ),
        BlocProvider(
          create: (context) => PlacesBloc()..add(LoadPlaces()),
        ),
        BlocProvider(
          create: (context) => InquiriesBloc()..add(LoadInquiries()),
        ),
        BlocProvider(
          create: (context) => UsersBloc()..add(LoadUsers()),
        ),
        BlocProvider(
          create: (context) => RewardsBloc()..add(LoadRewards()),
        ),
      ],
      child: MaterialApp(
        title: 'DZ Guide Admin Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainLayout(),
      ),
    );
  }
}
