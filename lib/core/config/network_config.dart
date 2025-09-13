/// Network-related configuration
class NetworkConfig {
  const NetworkConfig({
    required this.websocketUrl,
    required this.rfidServerHost,
    required this.rfidServerPort,
    required this.requestTimeout,
    required this.useSSL,
  });

  final String websocketUrl;
  final String rfidServerHost;
  final int rfidServerPort;
  final Duration requestTimeout;
  final bool useSSL;

  /// Get the full RFID server URL
  String get rfidServerUrl => '${useSSL ? 'wss' : 'ws'}://$rfidServerHost:$rfidServerPort';

  @override
  String toString() => 'NetworkConfig('
      'websocketUrl: $websocketUrl, '
      'rfidServerUrl: $rfidServerUrl, '
      'requestTimeout: ${requestTimeout.inMilliseconds}ms, '
      'useSSL: $useSSL'
      ')';
}