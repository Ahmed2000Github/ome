// ignore_for_file: constant_identifier_names

part of 'file_handler_bloc.dart';

class FileHandlerState {
  FileHandlerStateEnum status;
  File? file;
  MediaType? type;
  FileHandlerState({required this.status, this.file, this.type});
}

enum FileHandlerStateEnum { NONE, LOADED, SAVED, ERROR }
