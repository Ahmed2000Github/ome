import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ome/enums/media_type.dart';

part 'file_handler_event.dart';
part 'file_handler_state.dart';

class FileHandlerBloc extends Bloc<FileHandlerEvent, FileHandlerState> {
  FileHandlerBloc()
      : super(FileHandlerState(status: FileHandlerStateEnum.NONE));
  @override
  Stream<FileHandlerState> mapEventToState(FileHandlerEvent event) async* {
    switch (event.event) {
      case FileHandlerEventEnum.LOADFILE:
        yield FileHandlerState(
            status: FileHandlerStateEnum.LOADED,
            file: event.file,
            type: event.type);

        break;
      case FileHandlerEventEnum.EMPTY:
        yield FileHandlerState(status: FileHandlerStateEnum.NONE);

        break;
      default:
    }
  }
}
