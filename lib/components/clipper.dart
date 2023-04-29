
import 'package:flutter/material.dart';

class HomeCliper extends StatelessWidget {
  const HomeCliper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 63e3ff
    return Stack(
      children: [
    ClipPath(
      clipper: ClipPainter(),
      child: Container(
        height: MediaQuery.of(context).size.height * .27,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 30)
        ], color: Theme.of(context).primaryColorDark),
      ),
    ),
    ClipShadowPath(
      clipper: ClipPainter(),
      shadow: const Shadow(color: Colors.black, blurRadius: 2),
      child: Container(
        height: MediaQuery.of(context).size.height * .25,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(
              color: Colors.black,
              // offset: Offset(0.0, 0.75),
              blurRadius: 5.0)
        ], color: Theme.of(context).primaryColor),
      ),
    )
      ],
    );
  }
}

class ClipPainter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var height = size.height;
    var width = size.width;
    var path = Path();

    path.lineTo(0, height * 4 / 5);

    var controlPoint = Offset(width * (3 / 10), height);
    var endPoint = Offset(width * (2.8 / 5), height * 3 / 5);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    controlPoint = Offset(width * (4 / 5), height * 1 / 5);
    endPoint = Offset(width, height * (4 / 5));

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

@immutable
class ClipShadowPath extends StatelessWidget {
  final Shadow shadow;
  final CustomClipper<Path> clipper;
  final Widget child;

   const ClipShadowPath({Key? key, 
    required this.shadow,
    required this.clipper,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClipShadowShadowPainter(
        clipper: clipper,
        shadow: shadow,
      ),
      child: ClipPath(child: child, clipper: clipper),
    );
  }
}

class _ClipShadowShadowPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowShadowPainter({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
