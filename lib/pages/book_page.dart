// ignore: unused_import
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/directory_info/directory_info_bloc.dart';
import 'package:ome/blocs/open_close_background_images.dart';
import 'package:ome/blocs/open_close_media.dart';
import 'package:ome/blocs/open_close_story_menu.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';
import 'package:ome/components/background_images.dart';
import 'package:ome/components/bottom_bar.dart';
import 'package:ome/components/loading_indicator.dart';
import 'package:ome/components/page_content.dart';
import 'package:ome/components/play_audio.dart';
import 'package:ome/components/play_image.dart';
import 'package:ome/components/play_video.dart';
import 'package:ome/components/story_theme_menu.dart';
import 'package:ome/configurations/routes.dart' as routes;
import 'package:ome/configurations/utils.dart';
import 'package:ome/enums/media_type.dart';
import 'package:ome/enums/state_status.dart';

class BookPage extends StatelessWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<DirectoryInfoBloc>().add(DirectoryInfoEvent());
    return Scaffold(
      body: BlocBuilder<DirectoryInfoBloc, DirectoryInfoState>(
        builder: (context, state) {
          if (state.status == StateStatus.LOADING) {
            return const LoadingIndicator();
          } else if (state.numberOfFiles == 0) {
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 35,
                          color: Theme.of(context).canvasColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No story found!",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        onPressed: () {
                          context.read<StoryHandlerBloc>().add(
                              StoryHandlerEvent(
                                  status: StoryHandlerEventStatus.NONE));
                          Navigator.pushNamed(context, routes.addMemoryPage);
                        },
                        child: const Text("Add Story to Book",
                            style: TextStyle(fontFamily: "Harlow")))
                  ],
                )),
              ],
            );
          } else {
            return MemoryPage(
              numberOfFiles: state.numberOfFiles,
            );
          }
        },
      ),
    );
  }
}

class MemoryPage extends StatefulWidget {
  int numberOfFiles;
  MemoryPage({required this.numberOfFiles});
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  int currentPage = 0;
  bool isInCurrent = false;
  bool isInNext = false;

  @override
  void initState() {
    super.initState();
    context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
        status: StoryHandlerEventStatus.GET, id: Utils.CurrentIndex));
  }

  @override
  Widget build(BuildContext context) {
    // var isPlayMediaOpen = true;
    // var width = MediaQuery.of(context).size.width;
    // var height = MediaQuery.of(context).size.height;
    return BlocBuilder<StoryHandlerBloc, StoryHandlerState>(
      builder: (context, state) {
        if (state.status == StateStatus.LOADING) {
          return const LoadingIndicator();
        }
        if (state.status == StateStatus.LOADED) {
          if (state.story != null) {
            currentPage = state.story!.id;
            return Stack(
              children: [
                GestureDetector(
                  onHorizontalDragEnd: onHorizontalDragEnd,
                  child: PageContent(
                    model: state.story!,
                  ),
                ),
                BlocBuilder<OpenCloseMediaBloc, bool>(
                    builder: (context, localState) {
                  if (localState) {
                    switch (state.story!.fileType) {
                      case MediaType.AUDIO:
                        return PlayAudio(file: state.story!.file!);
                      case MediaType.IMAGE:
                        return PlayImage(file: state.story!.file!);
                      case MediaType.VIDEO:
                        return PlayVideo(file: state.story!.file!);
                      default:
                        return Container();
                    }
                  } else {
                    return Container();
                  }
                }),
                BottomBar(model: state.story!),
                BlocBuilder<OpenCloseBackgroundImagesBloc, bool>(
                  builder: (context, openState) {
                    return openState
                        ? BackgoundImages(
                            backgroundName: state.story!.background,
                            storyId: state.story!.id)
                        : Container();
                  },
                ),
                BlocBuilder<OpenCloseStoryThemeMenuBloc, bool>(
                  builder: (context, openState) {
                    return openState
                        ? StoryThemeMenu(
                            storyId: state.story!.id,
                            storyTheme: state.story!.theme!)
                        : Container();
                  },
                ),
              ],
            );
          }
          context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
              status: StoryHandlerEventStatus.GET, id: Utils.CurrentIndex));
          return Center(
              child: Text("Story not found!",
                  style: Theme.of(context).textTheme.headline4));
        } else {
          context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
              status: StoryHandlerEventStatus.GET, id: Utils.CurrentIndex));
          return Center(
              child: Text("No data fount \n loading ... ",
                  style: Theme.of(context).textTheme.headline4));
        }
      },
    );
  }

  onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 0 && (currentPage - 1) > -1) {
      Utils.CurrentIndex = currentPage - 1;
      context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
          status: StoryHandlerEventStatus.GET, id: Utils.CurrentIndex));
    } else if (details.primaryVelocity! < 0 &&
        (currentPage + 1) < widget.numberOfFiles) {
      Utils.CurrentIndex = currentPage + 1;
      context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
          status: StoryHandlerEventStatus.GET, id: Utils.CurrentIndex));
    }
  }
}
