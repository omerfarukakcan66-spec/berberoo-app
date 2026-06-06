import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'data/store.dart';
import 'data/theme_controller.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = AppStore();
  final themeController = ThemeController();
  await Future.wait([store.init(), themeController.init()]);

  runApp(BarberooApp(store: store, themeController: themeController));
}

class BarberooApp extends StatelessWidget {
  final AppStore store;
  final ThemeController themeController;
  const BarberooApp({super.key, required this.store, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: store),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Barberoo',
            debugShowCheckedModeBanner: false,
            themeMode: theme.mode,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
