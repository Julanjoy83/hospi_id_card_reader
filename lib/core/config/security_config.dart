/// Security-related configuration
class SecurityConfig {
  const SecurityConfig({
    required this.openAiApiKey,
    required this.enableLogging,
    required this.enableDebugMode,
    required this.requireApiKey,
  });

  final String openAiApiKey;
  final bool enableLogging;
  final bool enableDebugMode;
  final bool requireApiKey;

  /// Whether API key is configured
  bool get hasApiKey => openAiApiKey.isNotEmpty;

  @override
  String toString() => 'SecurityConfig('
      'hasApiKey: $hasApiKey, '
      'enableLogging: $enableLogging, '
      'enableDebugMode: $enableDebugMode, '
      'requireApiKey: $requireApiKey'
      ')';
}