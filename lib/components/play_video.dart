import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/open_close_media.dart';
import 'package:video_player/video_player.dart';


// ignore: must_be_immutable
class PlayVideo extends StatefulWidget {
  File file;
  PlayVideo({Key? key, required this.file}) : super(key: key);

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;
  bool isInitialized = false;
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {
          isInitialized = true;
        });
      });
    _controller.addListener(checkVideo);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return isInitialized
        ? Stack(
            children: [
              GestureDetector(
                onTap: () {
                  context.read<OpenCloseMediaBloc>().add(false);
                },
                child: Container(
                  color: Theme.of(context).primaryColor.withOpacity(.1),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: height * .5,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).canvasColor, blurRadius: 2)
                      ],
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                constraints:
                                    BoxConstraints(maxHeight: height * 0.27),
                                child: Center(
                                  child: _controller.value.isInitialized
                                      ? AspectRatio(
                                          aspectRatio:
                                              _controller.value.aspectRatio,
                                          child: VideoPlayer(_controller),
                                        )
                                      : Container(),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                  playedColor: Theme.of(context).primaryColor),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ListTile(
                            trailing: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 30,
                                color: Theme.of(context).canvasColor,
                              ),
                              onPressed: () {
                                context.read<OpenCloseMediaBloc>().add(false);
                              },
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 15),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _controller.value.isLooping
                                        ? Icons.repeat
                                        : Icons.link_off,
                                    size: 40,
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _controller.setLooping(
                                          !_controller.value.isLooping);
                                    });
                                  },
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.replay_10,
                                    size: 40,
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  onPressed: () {
                                    _controller.seekTo(
                                        _controller.value.position -
                                            const Duration(seconds: 10));
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_circle_outline_outlined,
                                    size: 40,
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.forward_10,
                                    size: 40,
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  onPressed: () {
                                    _controller.seekTo(
                                        _controller.value.position +
                                            const Duration(seconds: 10));
                                  },
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.share_outlined,
                                    size: 40,
                                    color: Theme.of(context).canvasColor,
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        : Container();
  }

  void checkVideo() {
    // Implement your calls inside these conditions' bodies :
    if (_controller.value.position == Duration.zero) {
      print('video Started');
    }

    if (_controller.value.position == _controller.value.duration) {
      print('video Ended');
      setState(() {
        // _controller
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
