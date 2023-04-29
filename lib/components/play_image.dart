import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ome/blocs/open_close_media.dart';

class PlayImage extends StatelessWidget {
  File file;
  Function setInnerState = () {};
  PlayImage({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            context.read<OpenCloseMediaBloc>().add(false);
          },
          child: Container(
            color: Theme.of(context).primaryColor.withOpacity(.1),
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.all(10),
            height: height * .5,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Theme.of(context).canvasColor, blurRadius: 2)
                ],
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 50, 10, 60),
                  child: StatefulBuilder(builder: (context, innerState) {
                    setInnerState = innerState;
                    return file != null
                        ? Image(
                            image: FileImage(file),
                            fit: BoxFit.contain,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
                ),
                Column(
                  children: [
                    ListTile(
                      trailing: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 30,
                          color: Theme.of(context).canvasColor,
                        ),
                        onPressed: () {
                          context.read<OpenCloseMediaBloc>().add(false);
                        },
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 15),
                      child: Row(
                        children: [
                          // IconButton(
                          //   icon: Icon(
                          //     Icons.share_outlined,
                          //     size: 40,
                          //     color: Theme.of(context).canvasColor,
                          //   ),
                          //   onPressed: () {},
                          // ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.share_outlined,
                              size: 40,
                              color: Theme.of(context).canvasColor,
                            ),
                            onPressed: () {},
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
