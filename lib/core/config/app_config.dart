
import '../errors/configuration_failure.dart';
import '../types/result.dart';
import 'app_environment.dart';
import 'network_config.dart';
import 'security_config.dart';
import 'feature_config.dart';

/// Secure application configuration management
///
/// This class handles loading configuration from environment variables and secure storage.
/// It replaces hard-coded values with secure, configurable alternatives.
class AppConfig {
  AppConfig._internal();
  static final AppConfig _instance = AppConfig._internal();
  static AppConfig get instance => _instance;

  // Configuration values
  late final AppEnvironment _environment;
  late final NetworkConfig _networkConfig;
  late final SecurityConfig _securityConfig;
  late final FeatureConfig _featureConfig;

  /// Initialize the configuration
  /// Should be called at app startup before any other operations
  Future<Result<void, ConfigurationFailure>> initialize() async {
    try {
      _environment = _loadEnvironment();
      _networkConfig = _loadNetworkConfig();
      _securityConfig = await _loadSecurityConfig();
      _featureConfig = _loadFeatureConfig();

      final validationResult = validate();
      if (validationResult.isFailure) {
        return Failure(validationResult.error!);
      }

      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(
        ConfigurationFailure(
          message: 'Invalid configuration: ${e.toString()}',
          code: 'INVALID_CONFIG',
        ),
      );
    }
  }

  /// Get the current environment configuration
  AppEnvironment get environment => _environment;

  /// Get network configuration
  NetworkConfig get network => _networkConfig;

  /// Get security configuration
  SecurityConfig get security => _securityConfig;

  /// Get feature configuration
  FeatureConfig get features => _featureConfig;

  /// Load environment from environment variable or default to development
  AppEnvironment _loadEnvironment() {
    const envString = String.fromEnvironment(
      'FLUTTER_ENV',
      defaultValue: 'development',
    );

    return AppEnvironment.fromString(envString);
  }

  /// Load network configuration based on current environment
  NetworkConfig _loadNetworkConfig() {
    return switch (_environment) {
      AppEnvironment.production => NetworkConfig(
          websocketUrl: const String.fromEnvironment(
            'WEBSOCKET_URL',
            defaultValue: 'wss://api.hospitality.com/ws',
          ),
          rfidServerHost: const String.fromEnvironment(
            'RFID_SERVER_HOST',
            defaultValue: 'rfid.hospitality.com',
          ),
          rfidServerPort: const int.fromEnvironment(
            'RFID_SERVER_PORT',
            defaultValue: 443,
          ),
          requestTimeout: const Duration(seconds: 30),
          useSSL: true,
        ),
      AppEnvironment.staging => NetworkConfig(
          websocketUrl: const String.fromEnvironment(
            'WEBSOCKET_URL',
            defaultValue: 'wss://staging-api.hospitality.com/ws',
          ),
          rfidServerHost: const String.fromEnvironment(
            'RFID_SERVER_HOST',
            defaultValue: 'staging-rfid.hospitality.com',
          ),
          rfidServerPort: const int.fromEnvironment(
            'RFID_SERVER_PORT',
            defaultValue: 443,
          ),
          requestTimeout: const Duration(seconds: 30),
          useSSL: true,
        ),
      AppEnvironment.development => NetworkConfig(
          websocketUrl: const String.fromEnvironment(
            'WEBSOCKET_URL',
            defaultValue: 'ws://192.168.144.8:3000',
          ),
          rfidServerHost: const String.fromEnvironment(
            'RFID_SERVER_HOST',
            defaultValue: '192.168.144.9',
          ),
          rfidServerPort: const int.fromEnvironment(
            'RFID_SERVER_PORT',
            defaultValue: 4000,
          ),
          requestTimeout: const Duration(seconds: 15),
          useSSL: false,
        ),
    };
  }

  /// Load security configuration based on environment
  Future<SecurityConfig> _loadSecurityConfig() async {
    const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

    // In production, API key is mandatory
    if (openAiApiKey.isEmpty && _environment.isProduction) {
      throw ConfigurationFailure(
        message: 'API key is missing or invalid',
        code: 'MISSING_API_KEY',
      );
    }

    return SecurityConfig(
      openAiApiKey: openAiApiKey,
      enableLogging: _environment.enableLogging,
      enableDebugMode: _environment.enableDebugFeatures,
      requireApiKey: _environment.isProduction,
    );
  }

  /// Load feature configuration based on environment
  FeatureConfig _loadFeatureConfig() {
    return switch (_environment) {
      AppEnvironment.production => const FeatureConfig(
          enableMockServices: false,
          enablePerformanceMonitoring: true,
          enableCrashReporting: true,
          enableAnalytics: true,
        ),
      AppEnvironment.staging => const FeatureConfig(
          enableMockServices: false,
          enablePerformanceMonitoring: true,
          enableCrashReporting: true,
          enableAnalytics: false,
        ),
      AppEnvironment.development => const FeatureConfig(
          enableMockServices: true,
          enablePerformanceMonitoring: false,
          enableCrashReporting: false,
          enableAnalytics: false,
        ),
    };
  }

  /// Validate that all required configuration is present
  Result<void, ConfigurationFailure> validate() {
    if (_securityConfig.requireApiKey && _securityConfig.openAiApiKey.isEmpty) {
      return const Failure(
        ConfigurationFailure(
          message: 'OpenAI API key is required in production environment',
          code: 'MISSING_API_KEY',
        ),
      );
    }

    if (_networkConfig.websocketUrl.isEmpty) {
      return const Failure(
        ConfigurationFailure(
          message: 'WebSocket URL is required but not configured',
          code: 'MISSING_WEBSOCKET_URL',
        ),
      );
    }

    return const Success(null);
  }

  /// Get configuration summary for logging (without sensitive data)
  Map<String, dynamic> getConfigSummary() {
    return {
      'environment': _environment.name,
      'network': {
        'websocketUrl': _networkConfig.websocketUrl,
        'rfidServerUrl': _networkConfig.rfidServerUrl,
        'useSSL': _networkConfig.useSSL,
        'requestTimeout': '${_networkConfig.requestTimeout.inMilliseconds}ms',
      },
      'security': {
        'hasApiKey': _securityConfig.hasApiKey,
        'enableLogging': _securityConfig.enableLogging,
        'enableDebugMode': _securityConfig.enableDebugMode,
      },
      'features': {
        'enableMockServices': _featureConfig.enableMockServices,
        'enablePerformanceMonitoring': _featureConfig.enablePerformanceMonitoring,
        'enableCrashReporting': _featureConfig.enableCrashReporting,
        'enableAnalytics': _featureConfig.enableAnalytics,
      },
    };
  }
}