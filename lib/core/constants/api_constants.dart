class ApiConstants {
  static const String baseUrl = 'http://65.109.193.233:8000/api/v1';
  static const String chatEndpoint = '/chat/ask';
  static const String feedbackEndpoint = '/feedback/feedback';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}