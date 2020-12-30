import 'package:flutter/material.dart';
import 'package:userapp/ui/shared/colors.dart';

class CurvePainter extends CustomPainter {
  int type;

  CurvePainter({this.type});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = MikroMartColors.colorPrimary;
    paint.style = PaintingStyle.fill; // Change this to fill
    paint.strokeWidth = 2.0;

    var path = Path();

    switch (type) {
      case 1:
        path.moveTo(0, size.height * 0.7);

        path.quadraticBezierTo(size.width * 0.10, size.height * 0.7,
            size.width * 0.3, size.height * 0.8);

        path.quadraticBezierTo(size.width * 0.60, size.height * 0.95,
            size.width * 0.85, size.height * 0.5);

        path.quadraticBezierTo(size.width * 0.92, size.height * 0.4,
            size.width , size.height * 0.45);

        /*path.quadraticBezierTo(size.width * 0.25, size.height * 0.8,
            size.width * 0.5, size.height * 0.7);*/

        break;

      case 2:
        path.moveTo(0, size.height * 0.7);

        path.quadraticBezierTo(size.width * 0.20, size.height * 0.69,
            size.width * 0.3, size.height * 0.8);

        path.quadraticBezierTo(size.width * 0.5, size.height , size.width * 0.7,
            size.height*0.8);

        path.quadraticBezierTo(size.width * 0.8, size.height * 0.69, size.width,
            size.height * 0.7);

        break;

      case 3:
        path.moveTo(0, size.height * 0.35);

        path.quadraticBezierTo(size.width * 0.02, size.height * 0.33,
            size.width * 0.07, size.height * 0.35);

        path.quadraticBezierTo(size.width * 0.5, size.height * 0.50,
            size.width * 0.85, size.height * 0.31);

        path.quadraticBezierTo(size.width * 0.93, size.height * 0.264,
            size.width, size.height * 0.296);
        break;

      case 4:
        path.moveTo(0, size.height * 0.30);

        path.quadraticBezierTo(size.width * 0.10, size.height * 0.26,
            size.width * 0.28, size.height * 0.35);

        path.quadraticBezierTo(size.width * 0.55, size.height * 0.50,
            size.width * 0.85, size.height * 0.45);

        path.quadraticBezierTo(size.width * 0.93, size.height * 0.44,
            size.width, size.height * 0.42);
        break;
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
