import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatStarted extends ChatEvent {}

class MessageSent extends ChatEvent {
  final String content;

  const MessageSent(this.content);

  @override
  List<Object> get props => [content];
}

class FeedbackSent extends ChatEvent {
  final String messageId;
  final FeedbackType feedback;

  const FeedbackSent(this.messageId, this.feedback);

  @override
  List<Object> get props => [messageId, feedback];
}

class MessagesLoaded extends ChatEvent {}