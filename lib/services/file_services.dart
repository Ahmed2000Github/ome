import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
import 'package:ome/configurations/utils.dart';
import 'package:ome/enums/media_type.dart';
import 'package:ome/models/memory.dart';
import 'package:ome/models/sory_theme.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;

class FileServices {
  // ************* for authorize only one story per day **********
  // var box = Hive.box('ome');
  // FileServices() {
  //   box.put("lastDate",
  //       DateFormat('yyyy-MM-dd').format(DateTime.parse("2024-01-01")));
  // }
  addFileToAlbom(MemoryModel story) async {
    // box.put("lastDate",DateFormat('yyyy-MM-dd').format(DateTime.parse("2024-01-01")));
    // var comingDate = DateFormat('yyyy-MM-dd').format(story.date);
    // DateTime currentDate = DateTime.parse(comingDate);
    // DateTime lastDate = DateTime.parse(box.get("lastDate"));
    // if (currentDate.isAfter(lastDate)) {
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

    data['background'] = "assets/images/backgrounds/ome_page_bg_1.jpg";
    data['textColor'] = "#FFFFFF";
    data['fontName'] = "RubikPuddles";
    data['dateColor'] = "#00B6DB";
    data['buttonBackgroundColor'] = "#00B6DB";
    data['buttonForgroundColor'] = "#FFFFFF";
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    var directory = Directory(dirPath + "/storyBook");
    if (!(await directory.exists())) {
      directory = await directory.create();
    }
    var result = (await getIndexOfLastElement());
    var fileIndex = result['isEmpty'] ? 0 : result['index'] + 1;
    var jsonFile = File(directory.path + "/story_$fileIndex.json");
    jsonFile.writeAsStringSync(json.encode(data));
    // }
  }

  updateFileFromAlbom(MemoryModel story) async {
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
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    filesListPaths.sort();
    var content = File(filesListPaths[story.id]).readAsStringSync();
    Map<String, dynamic> oldData = jsonDecode(content);
    data['background'] = oldData['background'];
    data['textColor'] = oldData['textColor'];
    data['fontName'] = oldData['fontName'];
    data['dateColor'] = oldData['dateColor'];
    data['buttonBackgroundColor'] = oldData['buttonBackgroundColor'];
    data['buttonForgroundColor'] = oldData['buttonForgroundColor'];
    var directory = Directory(dirPath + "/storyBook");
    if (!(await directory.exists())) {
      directory = await directory.create();
    }
    var fileIndex = story.id;
    var jsonFile = File(directory.path + "/story_$fileIndex.json");
    jsonFile.writeAsStringSync(json.encode(data));
  }

  Future<int> getNumberOfFiles() async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    var directory = Directory(dirPath + "/storyBook");
    if (!(await directory.exists())) {
      directory = await directory.create();
    }
    final files = directory.listSync();
    for (var item in files) {
    }
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

  Future<MemoryModel?> getModelWithIndex(int fileIndex) async {
    try {
      await Utils.deleteCacheDir();
      var dirPath = (await getExternalStorageDirectory())?.path ?? "";
      List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
      filesListPaths.sort();
      var content = File(filesListPaths[fileIndex]).readAsStringSync();
      Map<String, dynamic> data = jsonDecode(content);
      var fileType = MediaType.values
          .firstWhere((e) => e.toString().split('.').last == data['fileType']);
      StoryThemeModel theme = StoryThemeModel(
          textColor: data['textColor'],
          dateColor: data['dateColor'],
          fontName: data['fontName'],
          buttonBackgroundColor: data['buttonBackgroundColor'],
          buttonForgroundColor: data['buttonForgroundColor']);
      MemoryModel model = MemoryModel(
          id: fileIndex,
          title: data['title'],
          description: data['description'],
          background: data['background'],
          fileType: fileType,
          theme: theme,
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
    } catch (e) {
      return null;
    }
  }

  updateBackground(int fileIndex, String path) async {
    await Utils.deleteCacheDir();
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    filesListPaths.sort();
    var content = File(filesListPaths[fileIndex]).readAsStringSync();
    Map<String, dynamic> data = jsonDecode(content);
    data['background'] = path;
    var directory = Directory(dirPath + "/storyBook");
    var jsonFile = File(directory.path + "/story_$fileIndex.json");
    jsonFile.writeAsStringSync(json.encode(data));
  }

  updateTheme(int fileIndex, Map<String, String> theme) async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    filesListPaths.sort();
    var content = File(filesListPaths[fileIndex]).readAsStringSync();
    Map<String, dynamic> data = jsonDecode(content);
    theme.forEach((key, value) => data[key] = value);

    var directory = Directory(dirPath + "/storyBook");
    var jsonFile = File(directory.path + "/story_$fileIndex.json");
    jsonFile.writeAsStringSync(json.encode(data));
    // StoryHandlerBloc().add(
    //     StoryHandlerEvent(status: StoryHandlerEventStatus.GET, id: fileIndex));
  }

  deleteFileByIndex(int fileIndex) async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    filesListPaths.sort();
    var file = File(filesListPaths[fileIndex]);
    await file.delete();
    await Utils.deleteCacheDir();
  }

  Future<Map<String, dynamic>> getIndexOfLastElement() async {
    var dirPath = (await getExternalStorageDirectory())?.path ?? "";
    List<String> filesListPaths = _getFilesListPathOfDirectory(dirPath);
    filesListPaths.sort();
    if (filesListPaths.isNotEmpty) {
      var str = filesListPaths.last.split("/").last.split(".").first;
      var strIndex = str[str.length - 1];
      return {'isEmpty': false, "index": int.parse(strIndex)};
    } else {
      return {'isEmpty': true, "index": 0};
    }
  }
}
