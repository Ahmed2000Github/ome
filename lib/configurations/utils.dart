import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ome/enums/media_type.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../blocs/download_progress.dart';

class Utils {
  static int CurrentIndex = 0;

  static Future<File?> getFileFromUrl(
      BuildContext context, String url, MediaType typeOfMedia) async {
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    File? file;
    if (response.statusCode == 200) {
      var mimeType = response.headers.contentType?.mimeType;
      var extension = getFileExtension(mimeType, url);
      var result = checkFile(extension, typeOfMedia);

      if (result) {
        var contentLength = response.headers.contentLength;
        var bytesReceived = 0;

        String dir = (await getTemporaryDirectory()).path;
        var currentTimestamp = DateTime.now().microsecondsSinceEpoch;
        file = File('$dir/$currentTimestamp.$extension');
        var sink = file.openWrite();

        await for (var chunk in response) {
          bytesReceived += chunk.length;
          var progress = (bytesReceived / contentLength * 100);
          context.read<DownloadProgressBloc>().add(progress);
          sink.add(chunk);
        }

        await sink.flush();
        await sink.close();
      } else {
        showToast(context,
            'The given URL is not supported or not match the type of media .');
        return null;
      }
    }
    context.read<DownloadProgressBloc>().add(0);
    throwIf(file == null, "Failed to download file.");
    return file;
  }

  static showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: Theme.of(context).textTheme.headline6,
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  static String getFileExtensionFromMimeType(String? mimeType) {
    const Map<String, String> mimeToExtension = {
      'audio/mpeg': 'mp3',
      'audio/aac': 'aac',
      'audio/wav': 'wav',
      'audio/ogg': 'ogg',
      'video/mp4': 'mp4',
      'video/quicktime': 'mov',
      'video/x-msvideo': 'avi',
      'video/x-matroska': 'mkv',
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/gif': 'gif',
    };

    if (mimeType == null || !mimeToExtension.containsKey(mimeType)) {
      return 'unknown';
    }

    return mimeToExtension[mimeType]!;
  }

  static String getFileExtensionFromUrl(String url) {
    final extension = p.extension(url).replaceAll('.', '');
    return extension.isNotEmpty ? extension : 'unknown';
  }

  static String getFileExtension(String? mimeType, String? url) {
    if (mimeType != null && mimeType.isNotEmpty) {
      final extension = getFileExtensionFromMimeType(mimeType);
      if (extension != 'unknown') {
        return extension;
      }
    }

    if (url != null) {
      final extension = getFileExtensionFromUrl(url);
      if (extension != 'unknown') {
        return extension;
      }
    }

    return "";
  }

  static bool checkFile(String extension, MediaType mediaType) {
    bool _isAudioFile(String extension) {
      return extension == 'mp3' || extension == 'wav';
    }

    bool _isVideoFile(String extension) {
      return extension == 'mp4';
    }

    bool _isImageFile(String extension) {
      return extension == 'jpg' || extension == 'jpeg' || extension == 'png';
    }

    switch (mediaType) {
      case MediaType.AUDIO:
        return _isAudioFile(extension);
      case MediaType.VIDEO:
        return _isVideoFile(extension);
      case MediaType.IMAGE:
        return _isImageFile(extension);
      default:
        return false;
    }
  }

  static Future<void> deleteCacheDir() async {
    var tempDir = await getTemporaryDirectory();

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }
}
