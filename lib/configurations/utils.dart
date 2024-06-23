import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static Future<File> getFileFromUrl(String url) async {
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getTemporaryDirectory()).path;
    var currentTimestamp = DateTime.now().microsecondsSinceEpoch;
    File file = File('$dir/$currentTimestamp');
    await file.writeAsBytes(bytes);
    return file;
  }

  // static createDirectory(String path) async {
  //   var dir = Directory(path);
  //   if (dir.existsSync()) {
  //     dir.deleteSync();
  //   }
  //   await dir.create();
  //   print(dir.existsSync());
  // }

  static Future<void> deleteCacheDir() async {
    var tempDir = await getTemporaryDirectory();

    if (tempDir.existsSync()) {
      // print(tempDir.listSync());
      tempDir.deleteSync(recursive: true);
    }
  }
}
