import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/directory_info/directory_info_bloc.dart';
import 'package:ome/components/clipper.dart';
import 'package:ome/configurations/routes.dart' as routes;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;

  AnimationController? _controller;

  Function setInnerState = () {};

  Function setInnerState2 = () {};

  int currentIndex = 0;
  String numbersOfPages = '';

  List<String> urls = [
    "assets/images/album1.png",
    "assets/images/album2.png",
    "assets/images/album3.png",
    "assets/images/album4.png",
  ];

  @override
  void initState() {
    super.initState();
    context.read<DirectoryInfoBloc>().add(DirectoryInfoEvent());
    periodicTimer();
    animationConfigurations();
  }

  void periodicTimer() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      setInnerState(() {
        (currentIndex == urls.length - 1) ? currentIndex = 0 : currentIndex++;
      });
    });
  }

  void animationConfigurations() {
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(children: [
      Column(
        children: [
          const HomeCliper(),
          const Spacer(),
          Transform.rotate(angle: pi, child: const HomeCliper())
        ],
      ),
      Center(
        child: Container(
            height: height * .46,
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              StatefulBuilder(builder: (context, innerState) {
                setInnerState = innerState;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 2000),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Image(
                    key: UniqueKey(),
                    image: AssetImage(urls[currentIndex]),
                    width: height * .35,
                  ),
                );
              }),
              const Spacer(),
              Row(
                children: [
                  Text(
                    "Enjoy with \nyour memories",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      BlocBuilder<DirectoryInfoBloc, DirectoryInfoState>(
                          builder: (context, state) {
                        animation = Tween<double>(
                                begin: 0, end: state.numberOfFiles.toDouble())
                            .animate(_controller!)
                          ..addListener(() {
                            setInnerState2(() {
                              numbersOfPages =
                                  animation!.value.toStringAsFixed(0);
                            });
                          });
                        _controller!.forward();
                        return StatefulBuilder(builder: (context, innerState) {
                          setInnerState2 = innerState;
                          return Text(
                            numbersOfPages,
                            style: Theme.of(context).textTheme.headline3,
                          );
                        });
                      }),
                      Text(
                        "page",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ],
                  ),
                ],
              )
            ])),
      ),
      Positioned(
        bottom: height * .05,
        right: width * (1 / 8),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, routes.bookPage);
          },
          child: Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              boxShadow: const[ BoxShadow(color: Colors.white, blurRadius: 4)],
              borderRadius: BorderRadius.circular(50),
              color: Colors.white.withOpacity(.9),
            ),
            child: Center(
              child: Text(
                "GO",
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: height * .05,
        left: width * .05,
        child: Image(
          image: const AssetImage("assets/images/ome_logo_shadow.png"),
          width: height * .15,
        ),
      )
    ]));
  }
}
