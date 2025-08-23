import 'package:dartz/dartz.dart';
import '../entities/message.dart';
import '../../../../core/error/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, String>> sendMessage(String question, String sessionId);
  Future<Either<Failure, bool>> sendFeedback({
    required String question,
    required String answer,
    required String sessionId,
    required FeedbackType feedback,
  });
  Future<Either<Failure, List<Message>>> getCachedMessages();
  Future<Either<Failure, void>> cacheMessages(List<Message> messages);
}