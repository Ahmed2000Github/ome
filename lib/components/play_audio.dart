import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:ome/blocs/open_close_media.dart';

class PlayAudio extends StatefulWidget {
  File file;
  PlayAudio({required this.file});
  @override
  State<PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  double _value = 0;
  double maxValue = 0;
  bool loop = false;
  bool mute = false;
  bool isSoundFinished = false;
  Timer? timer;
  Function setInnerState = () {};
  @override
  void initState() {
    super.initState();
    initAudio();
    onSoundFinished();
  }

  Future<void> initAudio() async {
    var bytes = await widget.file.readAsBytes();
    var buffer = bytes.buffer;
    player.play(BytesSource(Uint8List.view(buffer)));
    isPlaying = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // print("Timer run");
      var value =
          (await player.getCurrentPosition())!.inSeconds.floorToDouble();
      var _maxValue = (await player.getDuration())!.inSeconds.floorToDouble();
      if (mounted == true) {
        setState(() {
          // print("the value is : " + value.toString());
          // print("the max value is : " + _maxValue.toString());
          _value = value;
          maxValue = _maxValue;
        });
      }
    });
  }

  void onSoundFinished() {
    var s = player.onPlayerComplete;
    s.listen((event) {
      timer!.cancel();
      setState(() {
        isPlaying = false;
        isSoundFinished = true;
      });
      if (loop) {
        initAudio();
      }
    });
  }

  void closeAudio() {
    if (isPlaying == true) {
      player.stop();
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Stack(
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
                  BoxShadow(color: Theme.of(context).canvasColor, blurRadius: 2)
                ],
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    child: Lottie.asset("assets/images/sound.json",
                        animate: isPlaying)),
                Container(
                  margin: const EdgeInsets.only(top: 200),
                  child: StatefulBuilder(builder: (context, innerState) {
                    setInnerState = innerState;
                    return Slider(
                        value: _value,
                        min: 0.0,
                        max: maxValue,
                        thumbColor: Theme.of(context).primaryColor,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) async {
                          player.seek(Duration(seconds: value.ceil()));
                        });
                  }),
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
                              mute ? Icons.volume_off : Icons.volume_up,
                              size: 40,
                              color: Theme.of(context).canvasColor,
                            ),
                            onPressed: () async {
                              setState(() {
                                mute = !mute;
                                player.setVolume(mute ? 0.0 : 1.0);
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
                            onPressed: () async {
                              player.seek((await player.getCurrentPosition())! -
                                  const Duration(seconds: 10));
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause
                                  : Icons.play_circle_outline_outlined,
                              size: 40,
                              color: Theme.of(context).canvasColor,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                player.pause();
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                if (isSoundFinished) {
                                  initAudio();
                                } else {
                                  player.resume();
                                  setState(() {
                                    isPlaying = true;
                                  });
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.forward_10,
                              size: 40,
                              color: Theme.of(context).canvasColor,
                            ),
                            onPressed: () async {
                              player.seek((await player.getCurrentPosition())! +
                                  const Duration(seconds: 10));
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              loop ? Icons.repeat : Icons.repeat_one,
                              size: 40,
                              color: Theme.of(context).canvasColor,
                            ),
                            onPressed: () {
                              setState(() {
                                loop = !loop;
                              });
                            },
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
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
