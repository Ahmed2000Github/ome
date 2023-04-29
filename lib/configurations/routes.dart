import 'package:flutter/material.dart';
import 'package:ome/models/memory.dart';
import 'package:ome/pages/add_memory_page.dart';
import 'package:ome/pages/book_page.dart';
import 'package:ome/pages/home_page.dart';

const String homePage = "home";
const String bookPage = "book";
const String addMemoryPage = "add_memory";
const String testPage = "test";

Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case homePage:
      return MaterialPageRoute(builder: ((context) => HomePage()));
    case bookPage:
      return MaterialPageRoute(builder: ((context) => BookPage()));
    case addMemoryPage:
      return MaterialPageRoute(
          builder: ((context) =>
              AddMemoryPage(model: settings.arguments as MemoryModel)));
    default:
      return MaterialPageRoute(builder: ((context) => HomePage()));
  }
}
