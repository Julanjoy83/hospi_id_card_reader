/// Application environment enumeration with configuration per environment
enum AppEnvironment {
  development(
    name: 'development',
    displayName: 'Development',
    isDebug: true,
    enableLogging: true,
    enableDebugFeatures: true,
  ),
  staging(
    name: 'staging',
    displayName: 'Staging',
    isDebug: true,
    enableLogging: true,
    enableDebugFeatures: false,
  ),
  production(
    name: 'production',
    displayName: 'Production',
    isDebug: false,
    enableLogging: false,
    enableDebugFeatures: false,
  );

  const AppEnvironment({
    required this.name,
    required this.displayName,
    required this.isDebug,
    required this.enableLogging,
    required this.enableDebugFeatures,
  });

  final String name;
  final String displayName;
  final bool isDebug;
  final bool enableLogging;
  final bool enableDebugFeatures;

  /// Whether this is a production environment
  bool get isProduction => this == AppEnvironment.production;

  /// Whether this is a development environment
  bool get isDevelopment => this == AppEnvironment.development;

  /// Create environment from string value
  static AppEnvironment fromString(String value) {
    return AppEnvironment.values.firstWhere(
      (env) => env.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }

  @override
  String toString() => displayName;
}