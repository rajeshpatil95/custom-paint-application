import 'package:flutter/material.dart';
import 'dart:ui';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Draw!',
      theme: new ThemeData(
        primaryColor: Colors.lightGreen,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Center(
            child: new Text('Draw'),
          ),
        ),
        body: new DrawComponent(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DrawComponent extends StatefulWidget {
  @override
  _DrawComponentState createState() => new _DrawComponentState();
}

class _DrawComponentState extends State<DrawComponent> {
  _DrawComponentState() {
    _paths = [new Path()];
  }
  Path p = new Path();
  List<Path> _paths = <Path>[];
  List<Offset> _points = [];
  Path _path = new Path();
  Path fillPath = Path();
  Offset localPosition, offset;
  bool _repaint = false, fill = false;

  panDown(DragDownDetails details) {
    setState(() {
      _paths.add(_path);
      RenderBox object = context.findRenderObject();
      Offset localPosition = object.globalToLocal(details.globalPosition);
      _points.add(localPosition);

      offset = localPosition;
      for (int i = 0; i < _paths.length; i++) {
        fill = _paths[i].contains(offset);
        if (fill) {
          fillPath = _paths[i];
          break;
        }
      }

      print("Offsets $localPosition,${_path.contains(offset)} ");
      _paths.last.moveTo(localPosition.dx, localPosition.dy);
      _repaint = true;
    });
  }

  panUpdate(DragUpdateDetails details) {
    setState(() {
      RenderBox object = context.findRenderObject();
      Offset localPosition = object.globalToLocal(details.globalPosition);
      _points.add(localPosition);
      _paths.last.lineTo(localPosition.dx, localPosition.dy);
    });
  }

  panEnd(DragEndDetails details) {
    _points.add(null);
    setState(() {});
  }

  reset() {
    setState(() {
      _path = new Path();
      _paths = [new Path()];
      fillPath.reset();
      _repaint = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Padding(
        padding: new EdgeInsets.all(10.0),
        child: new Scaffold(
          backgroundColor: Colors.white,
          body: new GestureDetector(
            onPanDown: (DragDownDetails details) {
              panDown(details);
            },
            onPanUpdate: (DragUpdateDetails details) {
              panUpdate(details);
            },
            onPanEnd: (DragEndDetails details) {
              panEnd(details);
            },
            child: new CustomPaint(
              size: Size.infinite,
              painter: new PathPainter(
                paths: _paths,
                repaint: _repaint,
                offset: offset,
                fillType: fill,
                fillPath: fillPath,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: new Container(
        height: 40.0,
        margin: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new FlatButton(
              onPressed: () {
                reset();
              },
              child: new Icon(Icons.cancel),
              color: Colors.lightGreen,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey,
    );
  }
}

class PathPainter extends CustomPainter {
  List<Path> paths=[];
  Offset offset;
  bool repaint;
  bool fillType;
  Path fillPath = new Path();
  PathPainter(
      {this.paths,
      this.repaint,
      this.offset,
      this.fillType = false,
      this.fillPath});
  Path path = new Path();

  @override
  void paint(Canvas canvas, Size size) {
    if (paths != null) {
      Paint paint = new Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 10.0;

      if (!fillType) {
        paths.forEach((path) {
          canvas.drawPath(path, paint);
        });
      }

      if (fillType) {
        Paint paint = new Paint();
        paint.isAntiAlias = true;
        fillPath.fillType = PathFillType.evenOdd;
        canvas.drawPath(fillPath, paint);
      }
    }
    repaint = false;
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => repaint;
}
