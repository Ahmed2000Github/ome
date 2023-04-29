import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/open_close_background_images.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';

// ignore: must_be_immutable
class BackgoundImages extends StatefulWidget {
  int storyId;
  String backgroundName;
  BackgoundImages(
      {Key? key, required this.backgroundName, required this.storyId})
      : super(key: key);

  @override
  State<BackgoundImages> createState() => _BackgoundImagesState();
}

class _BackgoundImagesState extends State<BackgoundImages> {
  List<String> imagePaths = [];
  @override
  void initState() {
    _initImages();
    super.initState();
  }

  Future _initImages() async {
    final Map<String, dynamic> assets =
        jsonDecode(await rootBundle.loadString('AssetManifest.json'));

    setState(() {
      imagePaths = assets.keys
          .where((String key) => key.contains('backgrounds/'))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        context.read<OpenCloseBackgroundImagesBloc>().add(false);
      },
      child: Container(
        color: Theme.of(context).cardColor.withOpacity(.3),
        child: Container(
          margin: EdgeInsets.only(top: height * .5),
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          width: width,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Theme.of(context).cardColor),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Select background four your story ",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Divider(
              color: Theme.of(context).canvasColor,
              thickness: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: List.generate(
                      imagePaths.length,
                      (index) => GestureDetector(
                            onTap: () {
                              context.read<StoryHandlerBloc>().add(
                                  StoryHandlerEvent(
                                      status: StoryHandlerEventStatus
                                          .UPDATEBACKGROUND,
                                      id: widget.storyId,
                                      path: imagePaths[index]));
                              _goBack(context);
                            },
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  border: imagePaths[index] ==
                                          widget.backgroundName
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)
                                      : null),
                              child: Image(
                                image: AssetImage(imagePaths[index]),
                                fit: BoxFit.fill,
                                width: 200,
                              ),
                            ),
                          )),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  _goBack(BuildContext context) {
    context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
        status: StoryHandlerEventStatus.GET, id: widget.storyId));
    context.read<OpenCloseBackgroundImagesBloc>().add(false);
  }
}
