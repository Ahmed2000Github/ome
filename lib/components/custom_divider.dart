import 'package:flutter/material.dart';

class CustomTap extends StatelessWidget {
  Color color;
  double dividerHeight;
  String textTap;
  int id;
  int currentIndex;
  Function onTap;
  CustomTap(
      {required this.textTap,
      required this.id,
      required this.currentIndex,
      required this.onTap,
      this.color = Colors.white,
      this.dividerHeight = 1});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (currentIndex == id) {
      color = Theme.of(context).primaryColor;
    }
    return StatefulBuilder(builder: (context, innerState) {
      return GestureDetector(
        onTap: () {
          onTap();
          if (id == currentIndex) {
            innerState(() => color = Theme.of(context).primaryColor);
          }
        },
        child: Column(
          children: [
            Text(
              textTap,
              style:
                  TextStyle(color: color, fontSize: 20, fontFamily: "Harlow"),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: dividerHeight,
              width: width / 3,
              color: color,
            )
          ],
        ),
      );
    });
  }
}
