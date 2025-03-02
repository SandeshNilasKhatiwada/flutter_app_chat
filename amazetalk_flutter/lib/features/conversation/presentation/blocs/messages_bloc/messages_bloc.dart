import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/data/datasource/auth_local_data_source.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/usecase/chats_usecase.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessagesUsecase fetchMessagesUsecase;
  final AuthLocalDataSource cache;
  MessagesBloc(this.fetchMessagesUsecase, this.cache)
      : super(MessagesInitial()) {
    on<FetchMessages>((event, emit) async {
      emit(MessagesLoading());
      try {
        final messages = await fetchMessagesUsecase(event.chatId);
        final uid = await cache.getUserId();
        if (uid == null) {
          return emit(MessagesError('No user data found'));
        }
        emit(MessagesLoaded(messages, uid));
      } catch (error) {
        emit(MessagesError("Fail to load messagesx \n$error"));
      }
    });
  }
}
