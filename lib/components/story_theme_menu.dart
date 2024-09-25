// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/open_close_story_menu.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';
import 'package:ome/components/custom_divider.dart';
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

  Function setContentState = () {};
  int currentIndex = 0;

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
      dateColors = data["dateColors"].cast<String>();
      List<dynamic> _buttonThemes = data['buttonThemes'];
      _buttonThemes.forEach((element) {
        buttonThemes.add({
          "backgroundColor": element["backgroundColor"],
          "forgroundColor": element["forgroundColor"],
        });
      });
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
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.only(top: height * .5),
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            width: width,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Column(children: [
              Text(
                "Select theme to add in your story ",
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: StatefulBuilder(builder: (context, setInnetState) {
                        return ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CustomTap(
                                  textTap: "Text color",
                                  id: 0,
                                  currentIndex: currentIndex,
                                  onTap: () {
                                    setInnetState(() => currentIndex = 0);
                                    setContentState(() {});
                                  }),
                              const SizedBox(
                                width: 10,
                              ),
                              CustomTap(
                                  textTap: "Date color",
                                  id: 1,
                                  currentIndex: currentIndex,
                                  onTap: () {
                                    setInnetState(() => currentIndex = 1);
                                    setContentState(() {});
                                  }),
                              const SizedBox(
                                width: 10,
                              ),
                              CustomTap(
                                  textTap: "Fonts",
                                  id: 2,
                                  currentIndex: currentIndex,
                                  onTap: () {
                                    setInnetState(() => currentIndex = 2);
                                    setContentState(() {});
                                  }),
                              const SizedBox(
                                width: 10,
                              ),
                              CustomTap(
                                  textTap: "Button theme",
                                  id: 3,
                                  currentIndex: currentIndex,
                                  onTap: () {
                                    setInnetState(() => currentIndex = 3);
                                    setContentState(() {});
                                  }),
                            ]);
                      }),
                    )
                  ],
                ),
              ),
              StatefulBuilder(builder: (context, setInnerState) {
                setContentState = setInnerState;
                switch (currentIndex) {
                  case 1:
                    return ColorGrid(
                      colors: dateColors,
                      currentColor: widget.storyTheme.dateColor,
                      paramKey: "dateColor",
                    );
                  case 2:
                    return FontList(
                      fonts: fonts,
                      currentFont: widget.storyTheme.fontName,
                      paramKey: "fontName",
                    );
                  case 3:
                    return ButtonThemesGrid(
                      themes: buttonThemes,
                      currentTheme: {
                        'backgroundColor':
                            widget.storyTheme.buttonBackgroundColor,
                        'forgroundColor': widget.storyTheme.buttonForgroundColor
                      },
                    );
                  default:
                    return ColorGrid(
                      colors: textColors,
                      currentColor: widget.storyTheme.textColor,
                      paramKey: "textColor",
                    );
                }
              })
            ]),
          ),
        ),
      ),
    );
  }
}

class ColorGrid extends StatelessWidget {
  List<String> colors;
  String currentColor;
  String paramKey;

  ColorGrid(
      {required this.colors,
      required this.currentColor,
      required this.paramKey});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
          crossAxisCount: 3,
          children: List.generate(colors.length, (index) {
            return GestureDetector(
              onTap: () {
                context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
                    status: StoryHandlerEventStatus.UPDATETHEME,
                    id: id,
                    theme: {paramKey: colors[index]}));
                _goBack(context);
              },
              child: Container(
                height: 80,
                width: 60,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Color(
                        int.parse(colors[index].substring(1, 7), radix: 16) +
                            0xFF000000),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: colors[index] == currentColor
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 2)
                        : null),
              ),
            );
          })),
    );
  }

  _goBack(BuildContext context) {
    context
        .read<StoryHandlerBloc>()
        .add(StoryHandlerEvent(status: StoryHandlerEventStatus.GET, id: id));
    context.read<OpenCloseStoryThemeMenuBloc>().add(false);
  }
}

class FontList extends StatelessWidget {
  List<String> fonts;
  String currentFont;
  String paramKey;

  FontList(
      {required this.fonts, required this.currentFont, required this.paramKey});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
          children: List.generate(fonts.length, (index) {
        return GestureDetector(
          onTap: () {
            context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
                status: StoryHandlerEventStatus.UPDATETHEME,
                id: id,
                theme: {paramKey: fonts[index]}));
            _goBack(context);
          },
          child: Container(
            height: 40,
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: fonts[index] == currentFont
                    ? Border.all(
                        color: Theme.of(context).primaryColor, width: 2)
                    : null),
            child: Text(
              fonts[index],
              style: TextStyle(
                  color: fonts[index] == currentFont
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).canvasColor,
                  fontSize: 20,
                  fontFamily: fonts[index]),
            ),
          ),
        );
      })),
    );
  }

  _goBack(BuildContext context) {
    context
        .read<StoryHandlerBloc>()
        .add(StoryHandlerEvent(status: StoryHandlerEventStatus.GET, id: id));
    context.read<OpenCloseStoryThemeMenuBloc>().add(false);
  }
}

class ButtonThemesGrid extends StatelessWidget {
  List<Map<String, String>> themes;
  Map<String, String> currentTheme;

  ButtonThemesGrid({required this.themes, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
          crossAxisCount: 3,
          children: List.generate(themes.length, (index) {
            return GestureDetector(
                onTap: () {},
                child: Container(
                  height: 40,
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border:
                          themes[index].toString() == currentTheme.toString()
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)
                              : null),
                  child: FloatingActionButton(
                    backgroundColor: Color(int.parse(
                            themes[index]["backgroundColor"]!.substring(1, 7),
                            radix: 16) +
                        0xFF000000),
                    onPressed: (() {
                      context.read<StoryHandlerBloc>().add(StoryHandlerEvent(
                              status: StoryHandlerEventStatus.UPDATETHEME,
                              id: id,
                              theme: {
                                'buttonBackgroundColor': themes[index]
                                    ["backgroundColor"]!,
                                'buttonForgroundColor': themes[index]
                                    ["forgroundColor"]!
                              }));
                      _goBack(context);
                    }),
                    child: Icon(
                      Icons.brush,
                      color: Color(int.parse(
                              themes[index]["forgroundColor"]!.substring(1, 7),
                              radix: 16) +
                          0xFF000000),
                    ),
                  ),
                ));
          })),
    );
  }

  _goBack(BuildContext context) {
    context
        .read<StoryHandlerBloc>()
        .add(StoryHandlerEvent(status: StoryHandlerEventStatus.GET, id: id));
    context.read<OpenCloseStoryThemeMenuBloc>().add(false);
  }
}
