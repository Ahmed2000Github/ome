import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/directory_info/directory_info_bloc.dart';
import 'package:ome/blocs/open_close_background_images.dart';
import 'package:ome/blocs/open_close_story_menu.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';
import 'package:ome/configurations/routes.dart' as routes;
import 'package:ome/models/memory.dart';

// ignore: must_be_immutable
class BottomBar extends StatefulWidget {
  MemoryModel model;
  BottomBar({required this.model});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  Function setMenuButton = () => {};
  late AnimationController _controller;
  bool isMenuVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: const Duration(seconds: 1),
    );
    // Tween<double>(begin: -240, end: 0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Stack(
        children: [
          Positioned(
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
                  heroTag: "effect",
                  child: Icon(
                    Icons.brush,
                    size: 30,
                    color: Theme.of(context).canvasColor,
                  ),
                  onPressed: () {
                    context.read<OpenCloseStoryThemeMenuBloc>().add(true);
                  },
                ),
                const Spacer(),
                FloatingActionButton(
                  heroTag: "page",
                  child: Text(
                    "${widget.model.id + 1}",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  onPressed: () {},
                )
              ]),
            ),
          ),
          StatefulBuilder(builder: (context, innerState) {
            setMenuButton = () {
              _controller.reverse();
              innerState((() => isMenuVisible = true));
            };
            return isMenuVisible
                ? Positioned(
                    left: 0,
                    top: 130,
                    child: GestureDetector(
                      onTap: () {
                        innerState((() => isMenuVisible = false));
                        _controller.forward();
                      },
                      child: Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: const Radius.circular(10))),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Theme.of(context).canvasColor,
                        ),
                      ),
                    ))
                : Container();
          }),
          Positioned(
            top: 0,
            left: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-250 + (255 * _controller.value), 140),
                  child:
                      CRUDMenu(model: widget.model, closeMenu: setMenuButton),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  dispose() {
    _controller.dispose(); // you need this
    super.dispose();
  }
}

class CRUDMenu extends StatelessWidget {
  MemoryModel model;
  Function closeMenu;
  CRUDMenu({required this.model, required this.closeMenu});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      // color: ,
      width: 110,
      height: height * .4,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => closeMenu(),
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    border: Border.all(
                        color: Theme.of(context).canvasColor, width: 2),
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(15))),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).canvasColor,
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            child: Container(
              height: height * .3,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(.8),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(
                children: [
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
                      _deleteStory(context, model.id);
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
                  )
                ],
              ),
            ),
          ),
        ],
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
