import 'package:dartz/dartz.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> sendMessage(String question, String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.sendMessage(question, sessionId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('اتصال اینترنت وجود ندارد'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendFeedback({
    required String question,
    required String answer,
    required String sessionId,
    required FeedbackType feedback,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.sendFeedback(
          question: question,
          answer: answer,
          sessionId: sessionId,
          feedback: feedback,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('اتصال اینترنت وجود ندارد'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getCachedMessages() async {
    try {
      final messages = await localDataSource.getCachedMessages();
      return Right(messages);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cacheMessages(List<Message> messages) async {
    try {
      final messageModels = messages.map((message) => MessageModel.fromEntity(message)).toList();
      await localDataSource.cacheMessages(messageModels);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}