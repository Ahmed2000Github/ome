import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ome/configurations/utils.dart';
import 'package:ome/enums/media_type.dart';
import 'package:ome/models/memory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileServices {
  addFileToAlbom(MemoryModel story, {bool isUpdate = false}) async {
    Map<String, String> data = {};
    data['title'] = story.title;
    data['description'] = story.description;
    data['date'] = story.date.toString();
    data['fileType'] = describeEnum(story.fileType);
    if (story.fileType != MediaType.NONE) {
      try {
        File file = story.file!;
        var fileContent = base64.encode(file.readAsBytesSync());
        data["file"] = fileContent;
        data["extension"] = path.extension(file.path);
      // ignore: empty_catches
      } catch (e) {}
    }
    data['background'] = isUpdate
        ? story.background
        : "assets/images/backgrounds/ome_page_bg_3.jpg";
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    var directory = Directory(dirPath + "/storyBook");
    if (!(await directory.exists())) {
      directory = await directory.create();
    }
    var fileIndex = isUpdate ? story.id : (await getNumberOfFiles()) + 1;
    // add data to json file
    var jsonFile = File(directory.path + "/story_$fileIndex.json");
    jsonFile.writeAsStringSync(json.encode(data));
  }

  Future<int> getNumberOfFiles() async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    final directory = Directory(dirPath + "/storyBook");
    final files = directory.listSync();
    final fileCount = files.whereType<File>().length;
    return fileCount;
  }

  List<String> _getFilesListPathOfDirectory(String dirPath) {
    final directory = Directory(dirPath + "/storyBook");
    final files = directory.listSync();
    List<String> list = [];
    for (var file in files) {
      if (file is File) {
        list.add(file.path);
      }
    }
    return list;
  }

  Future<MemoryModel> getModelWithIndex(int fileIndex) async {
    await Utils.deleteCacheDir();
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    var content = File(filesListPaths[fileIndex]).readAsStringSync();
    Map<String, dynamic> data = jsonDecode(content);
    var fileType = MediaType.values
        .firstWhere((e) => e.toString().split('.').last == data['fileType']);
    // print(data);
    MemoryModel model = MemoryModel(
        id: fileIndex,
        title: data['title'],
        description: data['description'],
        background: data['background'],
        fileType: fileType,
        date: DateTime.parse(data['date']),
        file: null);
    if (fileType != MediaType.NONE) {
      try {
        File file = File((await getTemporaryDirectory()).path +
            "/file$fileIndex${data['extension']}");
        var contentBytes = base64.decode(data["file"]);
        file.writeAsBytesSync(contentBytes);
        model.file = file;
      } catch (err) {
        model.fileType = MediaType.NONE;
      }
    }

    return model;
  }

  updateBackground(int fileIndex, String path) async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    var content = File(filesListPaths[fileIndex]).readAsStringSync();
    Map<String, dynamic> data = jsonDecode(content);
    data['background'] = path;
    var directory = Directory(dirPath + "/storyBook");
    var jsonFile = File(directory.path + "/story_$fileIndex.json");
    jsonFile.writeAsStringSync(json.encode(data));
    }
  updateTheme(int fileIndex, String path) async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    var content = File(filesListPaths[fileIndex]).readAsStringSync();
    Map<String, dynamic> data = jsonDecode(content);
    data['background'] = path;
    var directory = Directory(dirPath + "/storyBook");
    var jsonFile = File(directory.path + "/story_$fileIndex.json");
    jsonFile.writeAsStringSync(json.encode(data));
    // StoryHandlerBloc().add(
    //     StoryHandlerEvent(status: StoryHandlerEventStatus.GET, id: fileIndex));
  }
  deleteFileByIndex(int fileIndex) async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    var file = File(filesListPaths[fileIndex]);
    await file.delete();
    await Utils.deleteCacheDir();
  }
}
