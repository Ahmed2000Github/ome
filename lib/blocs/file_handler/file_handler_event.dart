// ignore_for_file: constant_identifier_names

part of 'file_handler_bloc.dart';

class FileHandlerEvent {
  FileHandlerEventEnum event;
  File? file;
  MediaType? type;
  FileHandlerEvent({required this.event, this.file, this.type});
}

enum FileHandlerEventEnum { LOADFILE, SAVEFILE,EMPTY }
