import 'base_failure.dart';

/// Failure related to configuration and setup
class ConfigurationFailure extends Failure {
  const ConfigurationFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });

  factory ConfigurationFailure.missingApiKey() {
    return const ConfigurationFailure(
      message: 'API key is missing or invalid',
      code: 'MISSING_API_KEY',
    );
  }

  factory ConfigurationFailure.invalidConfiguration(String details) {
    return ConfigurationFailure(
      message: 'Invalid configuration: $details',
      code: 'INVALID_CONFIG',
    );
  }
}