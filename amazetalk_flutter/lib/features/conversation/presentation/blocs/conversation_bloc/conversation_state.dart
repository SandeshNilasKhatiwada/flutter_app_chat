import 'package:amazetalk_flutter/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationsLoading extends ConversationState {}

class ConversationsLoaded extends ConversationState {
  final ConversationEntity conversations;
  ConversationsLoaded(this.conversations);
}

class ConversationsError extends ConversationState {
  final String message;
  ConversationsError(this.message);
}
