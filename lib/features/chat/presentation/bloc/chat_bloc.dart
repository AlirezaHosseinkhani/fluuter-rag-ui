import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/send_feedback.dart';
import '../../../../core/constants/app_constants.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage sendMessage;
  final SendFeedback sendFeedback;
  final Uuid uuid = const Uuid();

  ChatBloc({
    required this.sendMessage,
    required this.sendFeedback,
  }) : super(ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<MessageSent>(_onMessageSent);
    on<FeedbackSent>(_onFeedbackSent);
  }

  Future<void> _onChatStarted(ChatStarted event, Emitter<ChatState> emit) async {
    final sessionId = uuid.v4();
    final welcomeMessage = Message(
      id: 'welcome',
      content: AppConstants.welcomeMessage,
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(ChatLoaded(
      messages: [welcomeMessage],
      sessionId: sessionId,
    ));
  }

  Future<void> _onMessageSent(MessageSent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    // Remove the feedback waiting check

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add user message and show typing indicator
    emit(currentState.copyWith(
      messages: [...currentState.messages, userMessage],
      isTyping: true,
    ));

    // Send message to API
    final result = await sendMessage(
      question: event.content,
      sessionId: currentState.sessionId,
    );

    result.fold(
          (failure) {
        emit(currentState.copyWith(isTyping: false));
        emit(ChatError(failure.message));
      },
          (response) {
        final botMessage = Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
          question: event.content,
        );

        emit(currentState.copyWith(
          messages: [...currentState.messages, userMessage, botMessage],
          isTyping: false,
          // Remove waitingForFeedback: true
        ));
      },
    );
  }

  Future<void> _onFeedbackSent(FeedbackSent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final messageToUpdate = currentState.messages.firstWhere(
          (msg) => msg.id == event.messageId,
      orElse: () => Message(
        id: '',
        content: '',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    if (messageToUpdate.id.isEmpty || messageToUpdate.isUser) return;

    // Check if feedback already exists
    if (messageToUpdate.feedback != null) return;

    // Update message with feedback
    final updatedMessages = currentState.messages.map((msg) {
      if (msg.id == event.messageId) {
        return msg.copyWith(feedback: event.feedback);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(
      messages: updatedMessages,
    ));

    // Send feedback to API
    if (messageToUpdate.question != null) {
      final result = await sendFeedback(
        question: messageToUpdate.question!,
        answer: messageToUpdate.content,
        sessionId: currentState.sessionId,
        feedback: event.feedback,
      );

      result.fold(
            (failure) {
          // Revert feedback on error
          final revertedMessages = currentState.messages.map((msg) {
            if (msg.id == event.messageId) {
              return msg.copyWith(feedback: null);
            }
            return msg;
          }).toList();

          emit(currentState.copyWith(
            messages: revertedMessages,
          ));
          emit(ChatError(failure.message));
        },
            (_) {
          // Feedback sent successfully
        },
      );
    }
  }
}