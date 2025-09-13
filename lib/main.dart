import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'shared/theme/app_theme.dart';
import 'screens/splash_wrapper.dart';

/// Main entry point for the Hospitality ID Scanner application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure configuration
  final configResult = await AppConfig.instance.initialize();

  if (configResult.isFailure) {
    print('❌ Configuration Error: ${configResult.error!.message}');
    runApp(ConfigErrorApp(error: configResult.error!));
    return;
  }

  // Log configuration in debug mode
  if (AppConfig.instance.security.enableLogging) {
    print('✅ Configuration loaded: ${AppConfig.instance.environment.displayName}');
  }

  runApp(const HospitalityApp());
}

/// Main application with proper theming and configuration
class HospitalityApp extends StatelessWidget {
  const HospitalityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check-in LOUNA',
      debugShowCheckedModeBanner: AppConfig.instance.security.enableDebugMode,
      theme: AppTheme.themeData,
      home: SplashWrapper(),
    );
  }
}

/// Error screen shown when configuration fails
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.error});
  final dynamic error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuration Error',
      home: Scaffold(
        backgroundColor: AppTheme.errorColor,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(error.toString()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
