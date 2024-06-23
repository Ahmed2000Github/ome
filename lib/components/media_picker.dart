import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ome/blocs/file_handler/file_handler_bloc.dart';
import 'package:ome/blocs/file_size_check.dart';
import 'package:ome/components/audio-recorder.dart';
import 'package:ome/configurations/utils.dart';
import 'package:ome/enums/media_type.dart';

class MediaSelector extends StatefulWidget {
  Function setInnerState;
  Function function;
  MediaType mediaType;

  MediaSelector(
      {Key? key,
      required this.mediaType,
      required this.setInnerState,
      required this.function})
      : super(key: key);
  @override
  State<MediaSelector> createState() => _MediaSelectorState();
}

class _MediaSelectorState extends State<MediaSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  XFile? _video;
  int maxFileSize = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: const Duration(seconds: 1),
    );
    // Tween<double>(begin: -240, end: 0).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () async {
        await _controller.reverse();
        widget.setInnerState(widget.function);
      },
      child: Container(
        width: width,
        height: height,
        color: Colors.red.withOpacity(0),
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 240 - (240 * _controller.value)),
                child: Container(
                    margin: EdgeInsets.only(top: height * .7),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    width: width,
                    height: 240,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            switch (widget.mediaType) {
                              case MediaType.AUDIO:
                                handleAudioFromGallery();
                                break;
                              case MediaType.VIDEO:
                                handleVideoFromGallery();
                                break;
                              default:
                                handleImageFromGallery();
                                break;
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            width: width * .3,
                            height: width * .3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_getGalleryIcon(),
                                    size: 50,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                Text(
                                  "Gallery",
                                  style: Theme.of(context).textTheme.headline6,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            switch (widget.mediaType) {
                              case MediaType.AUDIO:
                                handleAudioFromMicrop();
                                break;
                              case MediaType.VIDEO:
                                handleVideoFromCamera();
                                break;
                              default:
                                handleImageFromCamera();
                                break;
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            width: width * .3,
                            height: width * .3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_getDeviceIcon(),
                                    size: 50,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                Text(
                                  widget.mediaType == MediaType.AUDIO
                                      ? "Micro"
                                      : "Camera",
                                  style: Theme.of(context).textTheme.headline6,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            String enumName = widget.mediaType
                                .toString()
                                .split('.')
                                .last
                                .toLowerCase();
                            String formattedName = enumName[0].toUpperCase() +
                                enumName.substring(1);
                            var link = await getUrl(formattedName) ?? '';
                            if (link.isNotEmpty) {
                              handleFileFromUrl(link, widget.mediaType);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            width: width * .3,
                            height: width * .3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.link,
                                    size: 50,
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                                Text(
                                  "Link",
                                  style: Theme.of(context).textTheme.headline6,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              );
            }),
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (widget.mediaType) {
      case MediaType.AUDIO:
        return Icons.mic_none;
      case MediaType.VIDEO:
        return Icons.video_camera_back_outlined;
      default:
        return Icons.camera;
    }
  }

  IconData _getGalleryIcon() {
    switch (widget.mediaType) {
      case MediaType.AUDIO:
        return Icons.audio_file;
      case MediaType.VIDEO:
        return Icons.video_file;
      default:
        return Icons.collections;
    }
  }

  _closeMediaPicker() async {
    await _controller.reverse();
    widget.setInnerState(widget.function);
  }

  handleImageFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    _closeMediaPicker();
    context.read<FileHandlerBloc>().add(FileHandlerEvent(
        event: FileHandlerEventEnum.LOADFILE,
        file: File(image!.path),
        type: MediaType.IMAGE));
  }

  handleImageFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    _closeMediaPicker();
    context.read<FileHandlerBloc>().add(FileHandlerEvent(
        event: FileHandlerEventEnum.LOADFILE,
        file: File(image!.path),
        type: MediaType.IMAGE));
    // setState(() {
    //   _image = image;
    // });
  }

  // https://th.bing.com/th/id/OIP.4XB8NF1awQyApnQDDmBmQwHaEo?pid=ImgDet&rs=1

  // http://www.snut.fr/wp-content/uploads/2015/12/image-de-nature-4-1024x640.jpg

  handleVideoFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowCompression: false,
    );
    File file = File(result!.files.first.path!);
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > maxFileSize) {
      context.read<FileCheckSizeBloc>().add(true);
    } else {
      _closeMediaPicker();
      context.read<FileHandlerBloc>().add(FileHandlerEvent(
          event: FileHandlerEventEnum.LOADFILE,
          file: file,
          type: MediaType.VIDEO));
    }
  }

  handleVideoFromCamera() async {
    var video = await ImagePicker().pickVideo(source: ImageSource.camera);
    _closeMediaPicker();
    setState(() {
      _video = video;
    });
  }

  handleFileFromUrl(String link, MediaType typeOfMedia) async {
    try {
      var file = await Utils.getFileFromUrl(link);
      var result = checkFile(file, typeOfMedia);
      result
          ? context.read<FileHandlerBloc>().add(FileHandlerEvent(
              event: FileHandlerEventEnum.LOADFILE,
              file: File(file.path),
              type: typeOfMedia))
          : showToast(context);
    } catch (e) {}
  }

  handleAudioFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowCompression: false,
    );
    addFile(File(result!.files.first.path!));
  }

  handleAudioFromMicrop() async {
    String? _filePath = await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        AudioRecorder audioRecorder = AudioRecorder();
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text("Start record:"),
          content: StatefulBuilder(builder: (context, innerState) {
            return audioRecorder;
          }),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, '');
              },
            ),
            TextButton(
              child: const Text("Done"),
              onPressed: () {
                Navigator.pop(context, audioRecorder.filePath);
              },
            ),
          ],
        );
      },
    );
    if (_filePath != null) addFile(File(_filePath));
  }

  Future<String?> getUrl(String name) async {
    return await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Enter $name URL:"),
          content: TextField(
            controller: _controller,
            style:
                TextStyle(color: Theme.of(context).canvasColor, fontSize: 19),
            decoration: InputDecoration(
              hintText: "URL ...",
              hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(.5),
                  fontSize: 19),
            ),
            maxLines: null,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, '');
              },
            ),
            TextButton(
              child: const Text("Done"),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  bool checkFile(File file, MediaType mediaType) {
    String filePath = file.path.toLowerCase();
    String extension = filePath.split('.').last;

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

  bool _isAudioFile(String extension) {
    return extension == 'mp3' ||
        extension == 'aac' ||
        extension == 'wav' ||
        extension == 'ogg';
  }

  bool _isVideoFile(String extension) {
    return extension == 'mp4' ||
        extension == 'mov' ||
        extension == 'avi' ||
        extension == 'mkv';
  }

  bool _isImageFile(String extension) {
    return extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png' ||
        extension == 'gif';
  }

  addFile(File file) {
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > maxFileSize) {
      context.read<FileCheckSizeBloc>().add(true);
    } else {
      _closeMediaPicker();
      context.read<FileHandlerBloc>().add(FileHandlerEvent(
          event: FileHandlerEventEnum.LOADFILE,
          file: file,
          type: MediaType.AUDIO));
    }
  }

  void showToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The given URL is not match the type of media.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.reverse();
    _controller.dispose();
  }
}
