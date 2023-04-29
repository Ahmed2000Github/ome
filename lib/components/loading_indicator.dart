import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
          color: Theme.of(context).cardColor.withOpacity(.3),
          child: const CircularProgressIndicator()),
    );
  }
}
