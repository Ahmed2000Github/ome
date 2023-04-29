import 'dart:io';

import 'package:ome/enums/media_type.dart';

class MemoryModel {
  int id;
  String title;
  String description;
  String background;
  File? file;
  MediaType fileType;
  DateTime date;

  MemoryModel(
      {required this.id,
      required this.title,
      required this.description,
      this.file,
      required this.fileType,
      required this.date,
      required this.background});
}
