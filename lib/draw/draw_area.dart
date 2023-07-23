import 'package:flutter/material.dart';

class DrawArea extends StatefulWidget {
  @override
  _DrawAreaState createState() => _DrawAreaState();
}

class _DrawAreaState extends State<DrawArea> {
  List<Offset?> _points = [];
  List<double> _velocity = [0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Offset? localPosition =
                renderBox!.globalToLocal(details.globalPosition);
            _points = List.from(_points)..add(localPosition);
            // _velocity = List.from(_velocity)..add(details.delta.distance);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Offset? localPosition =
                renderBox!.globalToLocal(details.globalPosition);
            _points = List.from(_points)..add(localPosition);
            // _velocity = List.from(_velocity)..add(details.delta.distance);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _points.add(null);
            // _velocity.add(0);
          });
        },
        child: CustomPaint(
          painter: MyPainter(points: _points),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete),
        onPressed: () {
          setState(() {
            _points = [];
            // _velocity = [0];
          });
        },
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter({required this.points});

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF889278)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..strokeJoin = StrokeJoin.miter;

    // liner interpolation
    // for (int i = 1; i < points.length; i++) {
    //   if (points[i] != null && points[i - 1] != null) {
    //
    //     var mx = (points[i]!.dx + points[i-1]!.dx) / 2;
    //     var my = (points[i]!.dy + points[i-1]!.dy) / 2;
    //
    //     path..lineTo(mx, my)..lineTo(points[i]!.dx, points[i]!.dy);
    //     print("${mx}, ${my}");
    //     print("${points[i]!.dx}, ${points[i]!.dy}");
    //     path.moveTo(points[i]!.dx, points[i]!.dy);
    //   }
    // }
    Path path = Path();

    if (points[0] != null) {
      path.moveTo(points[0]!.dx, points[0]!.dy);
    }
    for (int i = 1; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        if (points[i - 1] == null && points[i] != null) {
          print("start point: (${points[i]!.dx}, ${points[i]!.dy})");
          path.moveTo(points[i]!.dx, points[i]!.dy);
        }
        var mx = (points[i]!.dx + points[i + 1]!.dx) / 2;
        var my = (points[i]!.dy + points[i + 1]!.dy) / 2;

        print("control point: (${mx}, ${my})");
        print("    end point: (${points[i + 1]!.dx}, ${points[i + 1]!.dy})");

        path.quadraticBezierTo(
          mx,
          my,
          points[i + 1]!.dx,
          points[i + 1]!.dy,
        );
        path.moveTo(mx, my);
        // path.lineTo(points[i]!.dx, points[i]!.dy);
        // path.lineTo(mx, my);
        // path.moveTo(mx, my);
      }
      canvas.drawPath(path, paint);
      // if (points[i] != null && points[i + 1] != null) {
      //   canvas.drawLine(points[i]!, points[i + 1]!, paint);
      // }
    }

    // for (int i = 1; i < points.length - 1; i++) {
    //   if(points[i -1] == null || points[i] == null || points[i + 1] == null) continue;
    //   var p1 = points[i - 1]!.dx;
    //   var p2 = points[i]!.dx;
    //   var p3 = points[i + 1]!.dx;
    //
    //   var q1 = points[i - 1]!.dy;
    //   var q2 = points[i]!.dy;
    //   var q3 = points[i + 1]!.dy;
    //
    //   // f(x) = a + x^2 + b + x + c
    //   if(p1 == p2 || p2 == p3 || p1 == p3) continue;
    //   var a = ( (q2-q1)/(p2-p1) - (q3-q2)/(p3-p2)) / (p1-p3);
    //   var b = (q2-q1)/(p2-p1) - a * (p1+p2);
    //   var c = q1 - a * pow(p1, 2) - b * p1;
    //
    //   print("f(x) = ${a}x^2 + ${b}x + ${c}");
    //   print("(${points[i]!.dx}, ${points[i]!.dy}) -> ");
    //   var preFi = points[i]!;
    //   var dx = (points[i+1]!.dx - points[i]!.dx) / 4;
    //   for (double x = 0; x < 0.75; x += 0.25) {
    //     var x = preFi.dx + dx;
    //     var fx = a * pow(x, 2) + b * x + c;
    //     var postFi = Offset(x, fx);
    //     print("(${postFi.dx}, ${postFi.dy})");
    //     canvas.drawLine(preFi, postFi, paint);
    //     preFi = postFi;
    //   }
    //   print("-> (${points[i+1]!.dx}, ${points[i+1]!.dy})");
    // }

    // final interpolation = 5;
    // for (int i = 1; i < points.length; i++) {
    //   if(points[i] != null && points[i-1] != null){
    //     // var startX = points[i-1]!.dx;
    //     // var startY = points[i-1]!.dy;
    //     // var dx = (points[i]!.dx - points[i-1]!.dx) / interpolation;
    //     // var dy = (points[i]!.dy - points[i-1]!.dy) / interpolation;
    //     // for(int j=0; j<interpolation; j++){
    //     //   var targetX = dx * j + startX;
    //     //   var targetY = dy * j + startY;
    //     //   canvas.drawLine(Offset(startX, startY), Offset(targetX, targetY), paint);
    //     //   startX = targetX;
    //     //   startY = targetY;
    //     // }
    //     canvas.drawLine(points[i-1]!, points[i]!, paint);
    //   }
    // }

    // for (int i = 0; i < points.length - 2; i++) {
    //   if (points[i] != null && points[i + 1] != null && points[i+2] != null) {
    //     Offset middlePoint = Offset(
    //         (points[i]!.dx + points[i + 2]!.dx) / 2,
    //         (points[i]!.dy + points[i + 2]!.dy) / 2
    //     );
    //     path.quadraticBezierTo(points[i+1]!.dx, points[i+1]!.dy, middlePoint.dx, middlePoint.dy);
    //   }
    // }
    // canvas.drawPath(path, paint);

    // for (int i = 0; i < points.length - 2 ; i += 1) {
    //   print("(${points[i]} ,${points[i+1]})");
    //   if (points[i + 0] == null || points[i + 1] == null || points[i + 2] == null){
    //     print("skip");
    //   }else{
    //     canvas.drawLine(points[i]!, points[i+1]!, paint);
    //     Path path = Path();
    //     path.moveTo(points[i]!.dx, points[i]!.dy);
    //     path.cubicTo(
    //         points[i]!.dx, points[i]!.dy,
    //         points[i + 1]!.dx, points[i + 1]!.dy,
    //         points[i + 2]!.dx, points[i + 2]!.dy
    //     );
    //     // path.cubicTo(
    //     //     points[i]!.dx, points[i]!.dy,
    //     //     points[i + 1]!.dx, points[i + 1]!.dy,
    //     //     points[i + 2]!.dx, points[i + 2]!.dy);
    //
    //     canvas.drawPath(path, paint);
    //   }
    //   // for (double t = 0; t <= 1.0; t += 0.05) {
    //     // double xt = 0.5 * ((2 * points[i + 1].dx) + (-points[i].dx + points[i + 2].dx) * t +
    //     //     (2 * points[i].dx - 5 * points[i + 1].dx + 4 * points[i + 2].dx - points[i + 3].dx) * t * t +
    //     //     (-points[i].dx + 3 * points[i + 1].dx - 3 * points[i + 2].dx + points[i + 3].dx) * t * t * t);
    //     // double yt = 0.5 * ((2 * points[i + 1].dy) + (-points[i].dy + points[i + 2].dy) * t +
    //     //     (2 * points[i].dy - 5 * points[i + 1].dy + 4 * points[i + 2].dy - points[i + 3].dy) * t * t +
    //     //     (-points[i].dy + 3 * points[i + 1].dy - 3 * points[i + 2].dy + points[i + 3].dy) * t * t * t);
    //     // canvas.drawCircle(Offset(xt, yt), paint.strokeWidth / 2, paint);
    //   // }
    // }
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => oldDelegate.points != points;
}
