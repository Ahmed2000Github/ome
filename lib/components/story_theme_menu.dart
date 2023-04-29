// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/open_close_story_menu.dart';
import 'package:ome/models/sory_theme.dart';

class StoryThemeMenu extends StatefulWidget {
  int storyId;
  StoryThemeModel storyTheme;
  StoryThemeMenu({Key? key, required this.storyId, required this.storyTheme})
      : super(key: key);

  @override
  State<StoryThemeMenu> createState() => _StoryThemeMenuState();
}

class _StoryThemeMenuState extends State<StoryThemeMenu> {
  List<String> textColors = [];

  List<String> fonts = [];

  List<String> dateColors = [];

  List<Map<String, String>> buttonThemes = [];

  @override
  void initState() {
    _initData();
    super.initState();
  }

  Future _initData() async {
    final Map<String, dynamic> data =
        jsonDecode(await rootBundle.loadString('assets/story_themes.json'));
    textColors = data["textColors"];
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        context.read<OpenCloseStoryThemeMenuBloc>().add(false);
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
              color: Theme.of(context).cardColor.withOpacity(.7)),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Select theme to add in your story ",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Divider(
              color: Theme.of(context).canvasColor,
              thickness: 1,
            ),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Text colors: ",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    children: List.generate(
                        textColors.length,
                        (index) => Container(
                              height: 100,
                              width: 100,
                              color: Colors.amber,
                            )),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Fonts: ",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Date colors: ",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Button themes: ",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
            )))
          ]),
        ),
      ),
    );
  }

  _goBack(BuildContext context) {
    // context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
    //     status: StoryHandlerEventStatus.GET, id: widget.storyId));
    context.read<OpenCloseStoryThemeMenuBloc>().add(false);
  }
}
