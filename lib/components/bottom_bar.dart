import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/directory_info/directory_info_bloc.dart';
import 'package:ome/blocs/open_close_background_images.dart';
import 'package:ome/blocs/open_close_story_menu.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';
import 'package:ome/configurations/routes.dart' as routes;
import 'package:ome/models/memory.dart';

// ignore: must_be_immutable
class BottomBar extends StatelessWidget {
  MemoryModel model;
  BottomBar({required this.model});
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        width: width,
        // color: Theme.of(context).cardColor,
        child: Row(children: [
          FloatingActionButton(
            elevation: 25,
            heroTag: "share",
            child: Icon(
              Icons.share_outlined,
              size: 35,
              color: Theme.of(context).canvasColor,
            ),
            onPressed: () {},
          ),
          const Spacer(),
          FloatingActionButton(
            elevation: 30,
            heroTag: "background_image",
            child: Icon(
              Icons.image_rounded,
              size: 35,
              color: Theme.of(context).canvasColor,
            ),
            onPressed: () {
              context.read<OpenCloseBackgroundImagesBloc>().add(true);
            },
          ),
          const Spacer(),
          FloatingActionButton(
            heroTag: "edit",
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.edit_note_outlined,
              size: 35,
              color: Theme.of(context).canvasColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, routes.addMemoryPage,
                  arguments: model);
            },
          ),
          const Spacer(),
          FloatingActionButton(
            heroTag: "delete",
            backgroundColor: Colors.red,
            child: Icon(
              Icons.delete_outlined,
              size: 35,
              color: Theme.of(context).canvasColor,
            ),
            onPressed: () {
              // _deleteStory(context, model.id);
              context.read<OpenCloseStoryThemeMenuBloc>().add(true);
            },
          ),
          const Spacer(),
          FloatingActionButton(
            heroTag: "add",
            child: Icon(
              Icons.add,
              size: 30,
              color: Theme.of(context).canvasColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, routes.addMemoryPage);
            },
          ),
        ]),
      ),
    );
  }

  _deleteStory(BuildContext context, int indexFile) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController _controller = TextEditingController();
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text(
              "Warning !",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              "You are sure you want to delete this file.",
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child:
                    const Text("Remove", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
                      status: StoryHandlerEventStatus.DELETE, id: indexFile));
                  context.read<DirectoryInfoBloc>().add(DirectoryInfoEvent());

                  context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
                      status: StoryHandlerEventStatus.GET, id: 0));
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
