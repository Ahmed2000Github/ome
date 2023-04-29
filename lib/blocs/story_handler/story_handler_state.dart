part of 'story_handler_bloc.dart';

class StoryHandlerState {
  StateStatus status;
  MemoryModel? story;
  String? msgError;
  StoryHandlerState({required this.status, this.story, this.msgError});
}

