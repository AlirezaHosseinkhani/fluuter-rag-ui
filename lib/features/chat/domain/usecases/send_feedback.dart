import 'package:dartz/dartz.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';
import '../../../../core/error/failures.dart';

class SendFeedback {
  final ChatRepository repository;

  SendFeedback(this.repository);

  Future<Either<Failure, bool>> call({
    required String question,
    required String answer,
    required String sessionId,
    required FeedbackType feedback,
  }) async {
    return await repository.sendFeedback(
      question: question,
      answer: answer,
      sessionId: sessionId,
      feedback: feedback,
    );
  }
}