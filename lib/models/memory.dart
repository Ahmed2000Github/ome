import 'dart:io';

import 'package:ome/enums/media_type.dart';
import 'package:ome/models/sory_theme.dart';

class MemoryModel {
  int id;
  String title;
  String description;
  String background;
  File? file;
  MediaType fileType;
  DateTime date;
  StoryThemeModel? theme;

  MemoryModel(
      {required this.id,
      required this.title,
      required this.description,
      this.file,
      this.theme,
      required this.fileType,
      required this.date,
      required this.background});
}
