import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/property_provider.dart';
import 'services/notification_service.dart';

import 'services/api_service.dart';
import 'screens/property_list_screen.dart';
import 'screens/property_detail_screen.dart';

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Handle notification taps
  notificationService.onNotificationTapped = (propertyId) async {
    try {
      final apiService = ApiService();

      final response = await apiService.getProperties(page: 1, pageSize: 1000);
      final property = response.properties.firstWhere(
        (p) => p.id == propertyId,
        orElse: () => response.properties.first,
      );

      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: property),
          ),
        );
      }
    } catch (e) {
      print('Error navigating: $e');
    }
  };

  runApp(const EstateXApp());
}

class EstateXApp extends StatelessWidget {
  const EstateXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'EstateX - Property Listings',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const PropertyListScreen(),
      floatingActionButton: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FloatingActionButton(
            onPressed: () => themeProvider.toggleTheme(),
            child: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          );
        },
      ),
    );
  }
}
