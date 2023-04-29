import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ome/models/memory.dart';
import 'package:ome/services/file_services.dart';

import '../../enums/state_status.dart';

part 'story_handler_event.dart';
part 'story_handler_state.dart';

class StoryHandlerBloc extends Bloc<StoryHandlerEvent, StoryHandlerState> {
  StoryHandlerBloc() : super(StoryHandlerState(status: StateStatus.NONE));

  FileServices get fileServices => GetIt.I<FileServices>();

  @override
  Stream<StoryHandlerState> mapEventToState(StoryHandlerEvent event) async* {
    switch (event.status) {
      case StoryHandlerEventStatus.GET:
        yield StoryHandlerState(status: StateStatus.LOADING);
        var model = await fileServices.getModelWithIndex(event.id ?? 0);
        yield StoryHandlerState(status: StateStatus.LOADED, story: model);

        break;
      case StoryHandlerEventStatus.NONE:
        yield StoryHandlerState(status: StateStatus.NONE);
        break;
      case StoryHandlerEventStatus.POST:
        yield StoryHandlerState(status: StateStatus.LOADING);
        await fileServices.addFileToAlbom(event.story!);
        yield StoryHandlerState(status: StateStatus.LOADED);
        break;
      case StoryHandlerEventStatus.UPDATE:
        yield StoryHandlerState(status: StateStatus.LOADING);
        await fileServices.addFileToAlbom(event.story!,isUpdate: true);
        yield StoryHandlerState(status: StateStatus.LOADED);
        break;
      case StoryHandlerEventStatus.UPDATEBACKGROUND:
        yield StoryHandlerState(status: StateStatus.LOADING);
        await fileServices.updateBackground(event.id!,event.path!);
        yield StoryHandlerState(status: StateStatus.LOADED);
        break;
      case StoryHandlerEventStatus.DELETE:
        yield StoryHandlerState(status: StateStatus.LOADING);
        await fileServices.deleteFileByIndex(event.id!);
        yield StoryHandlerState(status: StateStatus.LOADED);
        break;
      default:
    }
  }
}
