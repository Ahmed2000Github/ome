// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/open_close_story_menu.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';
import 'package:ome/models/sory_theme.dart';

int id = 0;

class StoryThemeMenu extends StatefulWidget {
  int storyId;
  StoryThemeModel storyTheme;
  StoryThemeMenu({Key? key, required this.storyId, required this.storyTheme})
      : super(key: key) {
    id = storyId;
  }

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
    final Map<String, dynamic> data = jsonDecode(
        await rootBundle.loadString('assets/data/story_themes.json'));
    setState(() {
      textColors = data["textColors"].cast<String>();
      fonts = data["fonts"].cast<String>();
    });
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
              color: Theme.of(context).cardColor),
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
                Container(
                    height: 80,
                    margin: EdgeInsets.only(bottom: 20, top: 20),
                    child: ColorList(
                        colorsList: textColors,
                        paramKey: "textColor",
                        currentColor: widget.storyTheme.textColor)),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Fonts: ",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                    height: 80,
                    margin: EdgeInsets.only(bottom: 20, top: 20),
                    child: ColorList(
                        colorsList: textColors,
                        paramKey: "fontName",
                        currentColor: widget.storyTheme.fontName)),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Date colors: ",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                    height: 80,
                    margin: EdgeInsets.only(bottom: 20, top: 20),
                    child: ColorList(
                        colorsList: textColors,
                        paramKey: "dateColor",
                        currentColor: widget.storyTheme.dateColor)),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Button themes: ",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                    height: 80,
                    margin: EdgeInsets.only(bottom: 20, top: 20),
                    child: ColorList(
                        colorsList: textColors,
                        paramKey: "dateColor",
                        currentColor: widget.storyTheme.textColor)),
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

class ColorList extends StatelessWidget {
  List<String> colorsList;
  String currentColor;
  String paramKey;
  ColorList(
      {required this.colorsList,
      required this.paramKey,
      required this.currentColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(
          colorsList.length,
          (index) => GestureDetector(
                onTap: () {
                  context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
                      status: StoryHandlerEventStatus.UPDATETHEME,
                      id: id,
                      theme: {paramKey: colorsList[index]}));
                  _goBack(context);
                },
                child: Container(
                  height: 80,
                  width: 60,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color(int.parse(colorsList[index].substring(1, 7),
                              radix: 16) +
                          0xFF000000),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: colorsList[index] == currentColor
                          ? Border.all(
                              color: Theme.of(context).primaryColor, width: 2)
                          : null),
                ),
              )),
    );
  }

  _goBack(BuildContext context) {
    context
        .read<StoryHandlerBloc>()
        .add(StoryHandlerEvent(status: StoryHandlerEventStatus.GET, id: id));
    context.read<OpenCloseStoryThemeMenuBloc>().add(false);
  }
}
