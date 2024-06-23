import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ome/blocs/directory_info/directory_info_bloc.dart';
import 'package:ome/blocs/file_handler/file_handler_bloc.dart';
import 'package:ome/blocs/file_size_check.dart';
import 'package:ome/blocs/open_close_background_images.dart';
import 'package:ome/blocs/open_close_media.dart';
import 'package:ome/blocs/open_close_story_menu.dart';
import 'package:ome/blocs/story_handler/story_handler_bloc.dart';
import 'package:ome/configurations/routes.dart' as routes;
import 'package:ome/configurations/utils.dart';
import 'package:ome/services/file_services.dart';

setUp() async {
  GetIt.I.registerLazySingleton(() => FileServices());
  await Hive.initFlutter();
  await Hive.openBox('ome');
}

void main() async {
  await setUp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Utils.deleteCacheDir();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OpenCloseMediaBloc(),
        ),
        BlocProvider(
          create: (context) => FileHandlerBloc(),
        ),
        BlocProvider(
          create: (context) => StoryHandlerBloc(),
        ),
        BlocProvider(
          create: (context) => DirectoryInfoBloc(),
        ),
        BlocProvider(
          create: (context) => FileCheckSizeBloc(),
        ),
        BlocProvider(
          create: (context) => OpenCloseBackgroundImagesBloc(),
        ),
        BlocProvider(
          create: (context) => OpenCloseStoryThemeMenuBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OME',
        theme: ThemeData(
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                foregroundColor: const Color(0xffffffff),
                backgroundColor: Colors.cyan.withOpacity(.9),
                highlightElevation: 23),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.cyan)
                .copyWith(secondary: Colors.cyan),
            primaryColor: Colors.cyan,
            cardColor: const Color.fromARGB(255, 0, 29, 59),
            primaryColorDark: Colors.cyan,
            primaryTextTheme:
                const TextTheme(headline4: TextStyle(color: Color(0xffffffff))),
            // elevated button theme
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    primary: Colors.cyan, // background color
                    textStyle: const TextStyle(
                        fontSize: 20, fontStyle: FontStyle.italic))),
            // outlined button theme
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
              backgroundColor: Colors.cyan.shade100,
              padding: const EdgeInsets.all(15),
              textStyle: const TextStyle(
                fontSize: 20,
              ),
            )),
            textTheme: const TextTheme(
                headline4: TextStyle(color: Color(0xffffffff)),
                headline6: TextStyle(color: Color(0xffffffff)),
                headline5: TextStyle(color: Color(0xffffffff)),
                subtitle1: TextStyle(color: Colors.cyan, fontSize: 25),
                headline3: TextStyle(
                    color: Color(0xffffffff), fontWeight: FontWeight.bold)),
            scaffoldBackgroundColor: const Color(0xff00142a)),
        onGenerateRoute: routes.controller,
        initialRoute: routes.homePage,
      ),
    );
  }
}
