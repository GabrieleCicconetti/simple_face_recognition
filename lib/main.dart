import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image image;
  List<Rect> rect = new List<Rect>();

  Future<ui.Image> loadImage(File image) async {
    var img = await image.readAsBytes();
    return await decodeImageFromList(img);
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      rect = List<Rect>();
    });

    var visionImage = FirebaseVisionImage.fromFile(image);

    var faceDetector = FirebaseVision.instance.faceDetector();

    List<Face> faces = await faceDetector.processImage(visionImage);

    for (Face f in faces) {
      rect.add(f.boundingBox);
    }

    loadImage(image).then((img) {
      setState(() {
        this.image = img;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Rec"),
      ),
      body: Container(
          child: FittedBox(
        child: SizedBox(
          width: image.width.toDouble(),
          height: image.height.toDouble(),
          child: CustomPaint(
            painter: Painter(rect: rect, image: image),
          ),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

class Painter extends CustomPainter {
  List<Rect> rect;
  ui.Image image;

  Painter({@required this.rect, @required this.image});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (image != null) {
      canvas.drawImage(image, Offset.zero, Paint());
    }

    for (Rect rect in this.rect) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.amberAccent
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
