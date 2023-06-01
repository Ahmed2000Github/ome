part of 'story_handler_bloc.dart';

class StoryHandlerEvent {
  StoryHandlerEventStatus status;
  MemoryModel? story;
  String? path;
  Map<String,String>? theme;
  int? id;
  StoryHandlerEvent({required this.status, this.story, this.id, this.path,this.theme});
}

enum StoryHandlerEventStatus {
  POST,
  GET,
  UPDATE,
  NONE,
  UPDATEBACKGROUND,
  UPDATETHEME,
  DELETE
}
