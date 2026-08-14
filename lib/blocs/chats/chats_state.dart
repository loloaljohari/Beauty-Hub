import 'package:equatable/equatable.dart';
import 'package:story_view/controller/story_controller.dart';
import '../../data/models/chat_model.dart';

enum ChatsStatus { initial, loading, loaded, failure }

enum ChatsActionStatus { initial, loading, success, failure }

class ChatsState extends Equatable {
  const ChatsState({
    this.mystory,
    this.stories = const [],
    this.chats = const [],
    this.searchQuery = '',
    this.status = ChatsStatus.initial,
     this.actionStatus=ChatsActionStatus.initial,
     this.errorMessage=''  });

  final List<StoryModel> stories;
  final List<ChatModel> chats;
  final String searchQuery;
  final ChatsStatus status;
  final dynamic mystory;
  final ChatsActionStatus actionStatus;
 final String errorMessage;
  bool get isEmpty => status == ChatsStatus.loaded && chats.isEmpty;

  List<ChatModel> get filteredChats {
    if (searchQuery.trim().isEmpty) return chats;
    final query = searchQuery.toLowerCase();
    return chats
        .where((c) => c.userName.toLowerCase().contains(query))
        .toList();
  }

  ChatsState copyWith(
      {List<StoryModel>? stories,
      List<ChatModel>? chats,
      String? searchQuery,
      ChatsStatus? status,
      dynamic mystory,
      ChatsActionStatus? actionStatus,
      String? errorMessage
      }) {
    return ChatsState(
      errorMessage: errorMessage??this.errorMessage,
      actionStatus:actionStatus??this.actionStatus,
        stories: stories ?? this.stories,
        chats: chats ?? this.chats,
        searchQuery: searchQuery ?? this.searchQuery,
        status: status ?? this.status,
        mystory: mystory ?? this.mystory);
  }

  @override
  List<Object?> get props =>
      [stories, chats, searchQuery, status, mystory, actionStatus,
       errorMessage];
}
