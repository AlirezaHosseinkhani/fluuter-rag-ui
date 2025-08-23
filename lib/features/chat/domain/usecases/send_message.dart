import 'package:dartz/dartz.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';
import '../../../../core/error/failures.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, String>> call({
    required String question,
    required String sessionId,
  }) async {
    return await repository.sendMessage(question, sessionId);
  }
}