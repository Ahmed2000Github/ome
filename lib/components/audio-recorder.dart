import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  String? filePath;
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    widget.filePath = '${tempDir.path}/ome_sound.wav';

    await _recorder.startRecorder(
      toFile: widget.filePath,
      codec: Codec.pcm16WAV,
    );
    _startTimer();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _stopTimer();
    setState(() {
      _isRecording = false;
    });
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          _recordDuration++;
        });
      }
    });
  }

  void _stopTimer() {
    if (mounted) {
      setState(() {
        _recordDuration = 0;
      });
    }
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _getRecordedFile() {
    if (widget.filePath != null && !_isRecording) {
      File recordedFile = File(widget.filePath!);
      // print('Recorded file path: ${recordedFile.path}');
    } else {
      // print('No recording available');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: (widget.filePath != null && !_isRecording)
            ? Container(
                width: 60,
                height: 40,
                padding: const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(55, 0, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Record',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            widget.filePath = null;
                            _isRecording = false;
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 25,
                        )),
                  ],
                ),
              )
            : Row(
                children: [
                  const Spacer(),
                  Text(_formatDuration(_recordDuration),
                      style: Theme.of(context).textTheme.headline6),
                  const Spacer(),
                  IconButton(
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 35,
                      )),
                  const Spacer(),
                ],
              ));
  }
}
