import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/message.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class ChatRemoteDataSource {
  Future<String> sendMessage(String question, String sessionId);
  Future<bool> sendFeedback({
    required String question,
    required String answer,
    required String sessionId,
    required FeedbackType feedback,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Future<String> sendMessage(String question, String sessionId) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatEndpoint}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'question': question,
          'session_id': sessionId,
        }),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        // Decode the response body with UTF-8 encoding
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        return data['answer'] ?? data.toString();
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final errorData = json.decode(decodedBody);
        throw ServerException(errorData['detail'] ?? 'خطایی رخ داده است');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('خطا در ارتباط با سرور');
    }
  }

  @override
  Future<bool> sendFeedback({
    required String question,
    required String answer,
    required String sessionId,
    required FeedbackType feedback,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.feedbackEndpoint}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'question': question,
          'answer': answer,
          'session_id': sessionId,
          'feedback': feedback.toString().split('.').last,
        }),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final errorData = json.decode(decodedBody);
        throw ServerException(errorData['error'] ?? 'خطا در ارسال بازخورد');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('خطا در ارتباط با سرور');
    }
  }
}