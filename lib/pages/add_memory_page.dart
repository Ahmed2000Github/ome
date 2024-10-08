// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ome/blocs/directory_info/directory_info_bloc.dart';
import 'package:ome/blocs/file_handler/file_handler_bloc.dart';
import 'package:ome/blocs/file_size_check.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';
import 'package:ome/components/loading_indicator.dart';
import 'package:ome/components/media_picker.dart';
import 'package:ome/configurations/utils.dart';
import 'package:ome/enums/media_type.dart';
import 'package:ome/enums/state_status.dart';
import 'package:ome/models/memory.dart';
import 'package:ome/services/file_services.dart';
import 'package:video_player/video_player.dart';

import '../blocs/download_progress.dart';
import '../blocs/open_close_download_indicator.dart';
import '../components/percent_indicator/percent_indicator.dart';

class AddMemoryPage extends StatefulWidget {
  MemoryModel? model;
  AddMemoryPage({this.model, Key? key}) : super(key: key);

  @override
  State<AddMemoryPage> createState() => _AddMemoryPageState(model);
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  IconData _currentMediaType = Icons.media_bluetooth_off;

  final ScrollController _scrollController = ScrollController();

  Function setInnerStateOfMediaPicker = () {};

  Function setInnerStateOfInitVideoController = () {};

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  bool _mediaSelectorVisibility = false;

  bool displayMediaPicker = false;

  MediaType _mediaType = MediaType.NONE;

  File? file;
  MemoryModel? model;
  FileServices get fileServices => GetIt.I<FileServices>();

  _AddMemoryPageState(this.model) {
    if (model != null) {
      file = model!.file;
      _mediaType = model!.fileType;
      _titleController.text = model!.title;
      _descriptionController.text = model!.description;
    } else {
      file = null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<FileHandlerBloc>().add(FileHandlerEvent(
        event: model == null
            ? FileHandlerEventEnum.EMPTY
            : FileHandlerEventEnum.LOADFILE,
        file: file,
        type: _mediaType));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      // backgroundColor: Colors.cyanAccent,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            SizedBox(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scrollController,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, bottom: 30),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd').format(
                                model == null ? DateTime.now() : model!.date),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 35,
                              color: Theme.of(context).canvasColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * .8,
                            child: TextFormField(
                                controller: _titleController,
                                style: TextStyle(
                                    color: Theme.of(context).canvasColor),
                                decoration: InputDecoration(
                                  hintText: "Title...",
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.5)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 7.0, horizontal: 5.0),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "title is required!";
                                  }
                                  // if (value.length > 40) {
                                  //   return "title should not have more than 40 caracters!";
                                  // }
                                }),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setInnerStateOfMediaPicker(() {
                          if (_mediaType == MediaType.NONE) {
                            _mediaSelectorVisibility = false;
                          } else {
                            _mediaSelectorVisibility = true;
                          }
                        });
                      },
                      child: StatefulBuilder(builder: (context, innetState) {
                        return Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Stack(
                            children: [
                              Transform.rotate(
                                angle: -pi / 30,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  height: width * .6,
                                  width: width * .85,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      border: Border.all(
                                          width: 10,
                                          color:
                                              Theme.of(context).primaryColor),
                                      boxShadow: const [
                                        BoxShadow(blurRadius: 20)
                                      ]),
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Center(
                                        child: BlocBuilder<FileHandlerBloc,
                                            FileHandlerState>(
                                          builder: (context, state) {
                                            if (state.status ==
                                                FileHandlerStateEnum.LOADED) {
                                              _mediaType = state.type!;
                                              file = state.file;
                                              if (state.type ==
                                                  MediaType.NONE) {
                                                return const Icon(
                                                  Icons.media_bluetooth_off,
                                                  size: 90,
                                                  color: Color(0xff999999),
                                                );
                                              }
                                              if (state.type ==
                                                  MediaType.AUDIO) {
                                                return Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Audio',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline5,
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .music_note_outlined,
                                                        size: 30,
                                                        color:
                                                            Color(0xffffffff),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              if (state.type ==
                                                  MediaType.VIDEO) {
                                                bool isVideoInit = false;
                                                VideoPlayerController
                                                    _controller =
                                                    VideoPlayerController.file(
                                                        state.file!)
                                                      ..initialize()
                                                          .then((value) {
                                                        setInnerStateOfInitVideoController(
                                                            () {});
                                                      });
                                                return StatefulBuilder(builder:
                                                    (builder, innerState) {
                                                  setInnerStateOfInitVideoController =
                                                      innerState;
                                                  return _controller
                                                          .value.isInitialized
                                                      ? Stack(
                                                          children: [
                                                            Center(
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    _controller
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    _controller),
                                                              ),
                                                            ),
                                                            Container(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor
                                                                    .withOpacity(
                                                                        .1),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Icon(
                                                                  Icons
                                                                      .play_circle_outline,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .canvasColor,
                                                                  size: 60,
                                                                ))
                                                          ],
                                                        )
                                                      : Container();
                                                });
                                              }
                                              return Image(
                                                image: FileImage(file!),
                                                fit: BoxFit.cover,
                                              );
                                            } else {
                                              return Icon(
                                                _currentMediaType,
                                                color: _currentMediaType !=
                                                        Icons
                                                            .media_bluetooth_off
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : const Color(0xff999999),
                                                size: 50,
                                              );
                                            }
                                          },
                                        ),
                                      )
                                      // child: const Center(
                                      //     child: Icon(
                                      //   Icons.mic_rounded,
                                      //   size: 90,
                                      //   color: Color(0xff999999),
                                      // )
                                      // ),
                                      ),
                                ),
                              ),
                              Positioned(
                                  right: 0,
                                  child: FloatingActionButton(
                                    tooltip: "media type",
                                    heroTag: "media type",
                                    backgroundColor:
                                        Theme.of(context).primaryColorDark,
                                    child: PopupMenuButton(
                                      child: Icon(Icons.layers_outlined,
                                          size: 30,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor),
                                      itemBuilder: (context) =>
                                          getMenuItems(context),
                                      onSelected: (result) {
                                        context.read<FileHandlerBloc>().add(
                                            FileHandlerEvent(
                                                event: FileHandlerEventEnum
                                                    .EMPTY));
                                        innetState(() {});
                                      },
                                    ),
                                    onPressed: () {},
                                  ))
                            ],
                          ),
                        );
                      }),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                          controller: _descriptionController,
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 400),
                                () {
                              _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent -
                                      60,
                                  duration: const Duration(microseconds: 500),
                                  curve: Curves.easeIn);
                            });
                          },
                          maxLines: 5,
                          style:
                              TextStyle(color: Theme.of(context).canvasColor),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Description \n................",
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.5)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 5.0),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "description is required!";
                            }
                            // if (value.length > 40) {
                            //   return "title should not have more than 40 caracters!";
                            // }
                          }),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      height: 60,
                      width: width,
                      // color: Theme.of(context).cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // FloatingActionButton(onPressed: () {}),
                          // const Spacer(),
                          GestureDetector(
                            onTap: () {
                              submitStory(context);
                            },
                            child: Container(
                              height: 50,
                              width: width * .5,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.white, blurRadius: 5)
                                  ]),
                              child: Text(
                                widget.model == null ? "Add" : "Update",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StatefulBuilder(builder: (context, innerState) {
              setInnerStateOfMediaPicker = innerState;
              return _mediaSelectorVisibility
                  ? MediaSelector(
                      mediaType: _mediaType,
                      setInnerState: setInnerStateOfMediaPicker,
                      function: () {
                        _mediaSelectorVisibility = false;
                      },
                    )
                  : Container();
            }),
            BlocBuilder<StoryHandlerBloc, StoryHandlerState>(
              builder: (context, state) {
                if (state.status == StateStatus.LOADING) {
                  return const LoadingIndicator();
                }
                return Container();
              },
            ),
            BlocBuilder<FileCheckSizeBloc, bool>(
              builder: (context, state) {
                return state
                    ? GestureDetector(
                        onTap: () {
                          context.read<FileCheckSizeBloc>().add(false);
                        },
                        child: Container(
                          color: Theme.of(context).cardColor.withOpacity(.5),
                          child: Center(
                            child: Container(
                                width: width * .9,
                                height: height * .25,
                                color: Theme.of(context).cardColor,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Spacer(),
                                        IconButton(
                                            onPressed: () {
                                              context
                                                  .read<FileCheckSizeBloc>()
                                                  .add(false);
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              size: 30,
                                              color:
                                                  Theme.of(context).canvasColor,
                                            ))
                                      ],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                              "The selected file has more than 10MB",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      )
                    : Container();
              },
            ),
            BlocBuilder<OpenCloseDownloadIndicatorBloc, bool>(
                builder: (context, state) {
              return state
                  ? Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context).canvasColor,
                                    blurRadius: 2)
                              ],
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10)),
                          width: width * 0.5,
                          height: width * 0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              BlocBuilder<DownloadProgressBloc, double>(
                                  builder: (context, state) {
                                return PercentIndicator(
                                  percent: state,
                                  lineWidth: 5.0,
                                  size: 30.0,
                                  lineColor: Colors.grey,
                                  completeColor: Colors.cyan,
                                );
                              }),
                              const Spacer(),
                              Text(
                                "Loading ...",
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container();
            })
          ],
        ),
      ),
    );
  }

  submitStory(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    var story = MemoryModel(
        id: widget.model?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        background: widget.model?.background ?? "",
        file: file,
        fileType: _mediaType,
        date: DateTime.now());

    context
        .read<FileHandlerBloc>()
        .add(FileHandlerEvent(event: FileHandlerEventEnum.EMPTY));
    context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
        status: widget.model == null
            ? StoryHandlerEventStatus.POST
            : StoryHandlerEventStatus.UPDATE,
        story: story));

    await _goBack(context);
  }

  _goBack(BuildContext context) async {
    var result = await fileServices.getIndexOfLastElement();
    Utils.CurrentIndex =
        widget.model?.id ?? (result['isEmpty'] ? 0 : result["index"] + 1);
    // context.read<StoryHandlerBloc>().add(
    //     StoryHandlerEvent(status: StoryHandlerEventStatus.GET, id: targetId));
    Navigator.pop(context);
  }

  List<PopupMenuEntry> getMenuItems(BuildContext context) {
    List<PopupMenuEntry> list = [];
    list.add(PopupMenuItem(
      onTap: () {
        _currentMediaType = Icons.photo_outlined;
        _mediaType = MediaType.IMAGE;
      },
      value: 0,
      child: Center(
        child: Icon(
          Icons.photo_outlined,
          color: Theme.of(context).secondaryHeaderColor,
          size: 30,
        ),
      ),
    ));
    list.add(PopupMenuItem(
      onTap: () {
        _currentMediaType = Icons.ondemand_video_outlined;
        _mediaType = MediaType.VIDEO;
      },
      value: 1,
      child: Center(
        child: Icon(
          Icons.ondemand_video_outlined,
          color: Theme.of(context).secondaryHeaderColor,
          size: 30,
        ),
      ),
    ));
    list.add(PopupMenuItem(
      onTap: () {
        _currentMediaType = Icons.music_note_outlined;
        _mediaType = MediaType.AUDIO;
      },
      value: 2,
      child: Center(
        child: Icon(
          Icons.music_note_outlined,
          color: Theme.of(context).secondaryHeaderColor,
          size: 30,
        ),
      ),
    ));
    list.add(PopupMenuItem(
      onTap: () {
        _currentMediaType = Icons.media_bluetooth_off;
        _mediaType = MediaType.NONE;
      },
      value: 3,
      child: Center(
        child: Icon(
          Icons.media_bluetooth_off,
          color: Theme.of(context).secondaryHeaderColor,
          size: 30,
        ),
      ),
    ));
    return list;
  }
}
