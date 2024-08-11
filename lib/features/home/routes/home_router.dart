import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/config/router/app_router.dart';
import 'package:smart_spend_app/features/home/screens/home_screen.dart';

final homeRouter = GoRoute(
  path: '/home',
  pageBuilder: defaultPageBuilder(child: const HomeScreen()),
);
