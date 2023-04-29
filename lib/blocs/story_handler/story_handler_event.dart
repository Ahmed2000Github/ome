part of 'story_handler_bloc.dart';


class StoryHandlerEvent {
  StoryHandlerEventStatus status;
  MemoryModel? story;
  String? path;
  int? id;
  StoryHandlerEvent({required this.status, this.story, this.id,this.path});
}

enum StoryHandlerEventStatus { POST, GET, UPDATE,NONE,UPDATEBACKGROUND,DELETE }
