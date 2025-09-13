/// Feature flags configuration
class FeatureConfig {
  const FeatureConfig({
    required this.enableMockServices,
    required this.enablePerformanceMonitoring,
    required this.enableCrashReporting,
    required this.enableAnalytics,
  });

  final bool enableMockServices;
  final bool enablePerformanceMonitoring;
  final bool enableCrashReporting;
  final bool enableAnalytics;

  @override
  String toString() => 'FeatureConfig('
      'enableMockServices: $enableMockServices, '
      'enablePerformanceMonitoring: $enablePerformanceMonitoring, '
      'enableCrashReporting: $enableCrashReporting, '
      'enableAnalytics: $enableAnalytics'
      ')';
}