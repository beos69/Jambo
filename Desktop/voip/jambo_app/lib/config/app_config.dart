class AppConfig {
  static const String websocketUrl = 'ws://192.168.1.28:8088/ws';
  static const String serverUrl = 'http://192.168.1.28:8088';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Origin': 'http://192.168.1.28',
  };

  static const int reconnectDelay = 5000; // en millisecondes
  static const int callTimeout = 60000; // en millisecondes
  static const int maxReconnectAttempts = 3;

  static const Map<String, dynamic> defaultCallSettings = {
    'context': 'from-internal',
    'extension': '1000',
    'priority': 1,
    'async': true,
    'timeout': 30000,
  };

  static const audioConfig = {
    'sampleRate': 8000,
    'channels': 1,
    'volume': 1.0,
  };
}
