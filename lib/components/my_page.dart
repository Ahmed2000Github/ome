import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ome/blocs/directory_info/directory_info_bloc.dart';
import 'package:ome/blocs/open_close_media.dart';
import 'package:ome/enums/media_type.dart';
import 'package:ome/models/memory.dart';
// import 'package:ome/configurations/routes.dart' as routes;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class MyPage extends StatefulWidget {
  MemoryModel model;
  MyPage({required this.model});
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  VideoPlayerController? _controller;
  bool isInitialized = false;
  @override
  void initState() {
    super.initState();
    if (widget.model.fileType == MediaType.VIDEO) {
      initData();
    }
  }

  Future<void> initData() async {
    _controller = VideoPlayerController.file(widget.model.file!)
      ..initialize().then((_) {
        setState(() {
          isInitialized = true;
        });
      });
    // file.delete();
    // _controller.addListener(checkVideo);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
            child: Image(
          image: AssetImage(widget.model.background),
          fit: BoxFit.fill,
          width: width,
          height: height,
        )),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 40, left: 10, bottom: 30),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 35,
                      color: Theme.of(context).canvasColor,
                    ),
                    onPressed: () {
                      context
                          .read<DirectoryInfoBloc>()
                          .add(DirectoryInfoEvent());
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                  Text(
                    DateFormat('yyyy-MM-dd').format(widget.model.date),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text(
                    widget.model.title,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: -pi / 30,
              child: GestureDetector(
                onTap: () {
                  context.read<OpenCloseMediaBloc>().add(true);
                },
                child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    height: width * .6,
                    width: width * .90,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: Theme.of(context).canvasColor,
                        boxShadow: [BoxShadow(blurRadius: 20)]),
                    child: _getMediaPlayer()),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 40),
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Text(
                    widget.model.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _getMediaPlayer() {
    switch (widget.model.fileType) {
      case MediaType.VIDEO:
        return Container(
            margin: const EdgeInsets.all(10),
            color: Theme.of(context).cardColor,
            child: isInitialized
                ? Stack(
                    children: [
                      Center(
                        child: _controller!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              )
                            : Container(),
                      ),
                      Container(
                          color: Theme.of(context).cardColor.withOpacity(.1),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Theme.of(context).canvasColor,
                            size: 60,
                          ))
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ));
      case MediaType.AUDIO:
        return Container(
          margin: const EdgeInsets.all(10),
          color: Theme.of(context).cardColor,
          child: const Center(
              child: Icon(
            Icons.mic_rounded,
            size: 90,
            color: Color(0xff999999),
          )),
        );
      case MediaType.NONE:
        return Container(
          margin: const EdgeInsets.all(10),
          color: Theme.of(context).cardColor,
          child: const Center(
              child: Icon(
            Icons.media_bluetooth_off,
            size: 90,
            color: Color(0xff999999),
          )),
        );
      default:
        return Container(
          margin: const EdgeInsets.all(10),
          color: Theme.of(context).cardColor,
          child: Image(
            image: FileImage(widget.model.file!),
            fit: BoxFit.contain,
          ),
        );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
