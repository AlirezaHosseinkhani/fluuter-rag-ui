class ApiConstants {
  static const String baseUrl = 'http://0.0.0.0:8000/api/v1';
  static const String chatEndpoint = '/chat/ask';
  static const String feedbackEndpoint = '/feedback/feedback';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}