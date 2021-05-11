import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:pixel_color_picker/pixel_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mlkit/mlkit.dart';

void main(){
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      initialRoute: '/',  
       routes: {  
      '/': (context) => FirstScreen(),  
      '/second': (context) => SecondScreen(), 
      '/third' : (context) => ThirdScreen(), 
    },
    )
  );
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection & Color Picker App'),
        backgroundColor: Colors.pink,
      ),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 280,
            width: 340,
            padding: EdgeInsets.fromLTRB(0,0,0,0) ,
            child: ElevatedButton(
              child: Text('Firebase Image Labeler', style: TextStyle(fontSize: 40), textAlign: TextAlign.center,),
              style: ElevatedButton.styleFrom(shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0),
                ),
               primary: Colors.pink,
               ),
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
        
            ),
          ),
          Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0)),
          Container(
            height: 280,
            width: 340,
            padding: EdgeInsets.fromLTRB(0,0,0,0) ,
            child: ElevatedButton(
              child: Text('Pick & Draw', style: TextStyle(fontSize: 40),),
              style: ElevatedButton.styleFrom(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                ), 
                primary: Colors.pink,
              ),
              onPressed: (){
                Navigator.pushNamed(context, '/third');
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => new _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  File _file;

  List<VisionLabel> _currentLabels = <VisionLabel>[];

  FirebaseVisionLabelDetector detector = FirebaseVisionLabelDetector.instance;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(
          title: new Text('Image Labeling Firebase'),
          backgroundColor: Colors.pink,
        ),
        body: _buildBody(_file),
        floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.pink,
          onPressed: () async {
            try {
              var file =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              setState(() {
                _file = file;
              });

              var currentLabels =
                  await detector.detectFromBinary(_file?.readAsBytesSync());
              setState(() {
                _currentLabels = currentLabels;
              });
            } catch (e) {
              print(e.toString());
            }
          },
          child:new Icon(Icons.camera)
        ), 
    );
  }

  Widget _buildBody(File _file) {
    return new Container(
      padding: EdgeInsets.fromLTRB(0, 5.0, 0.0, 0.0),
      child: new Column(
        children: <Widget>[displaySelectedFile(_file), _buildList(_currentLabels)],
      ),
    );
  }

  Widget _buildList(List<VisionLabel> labels) {
    if (labels == null || labels.length == 0 ) {
      return new Text('', textAlign: TextAlign.center);
    }
    return new Expanded(
      child: new Container(    
        child: new ListView.builder(
            padding: const EdgeInsets.all(1.0),
            itemCount: labels.length,
            itemBuilder: (context, i) {
              return _buildRow(labels[i].label, labels[i].confidence.toString(), labels[i].entityID);
            }),
      ),
    );
  }

   Widget displaySelectedFile(File file) {
    return new SizedBox(
      width: 300,
      child: file == null
          ? new Text('       Please click a photo !!!', textAlign: TextAlign.center, style: TextStyle(fontSize: 25),)
          : new Image.file(file),
    );
}

  Widget _buildRow(String label, String confidence, String entityID) {
    return new ListTile(
      title: new Text(
        "\nLabel: $label \nConfidence: $confidence \nEntityID: $entityID",
      ),
      dense: true,
    );
  }
}

class ThirdScreen extends StatelessWidget {
  Widget build(BuildContext context) => Scaffold(body: Signature());
}

class Signature extends StatefulWidget {
  SignatureState createState() => SignatureState();
}

class SignatureState extends State<Signature> {
  List<Offset> _points = <Offset>[];
  Color _pickedColor = Colors.black;
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Color Picker"),
        backgroundColor: Colors.pink,
      ),

      body: Column(children: <Widget>[
          getContainer(),
      ]
      ), 
    
      floatingActionButton: Container(
          height: 615.0,
          width: double.infinity,
          child: PixelColorPicker(  
            onChanged: (value){
                setState(() {
                  _pickedColor = value;
                });
            },
          child: Container(
            height: 240.0,
            width: double.infinity,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(),
                child: Image.asset('assets/bird.png', fit:BoxFit.fill,),
                onPressed: (){
                },
              ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget getContainer(){
    return Container(
      height: 628.0,
      width: 400.0,
      child: Builder(builder: (context)
      {
        return GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox referenceBox = context.findRenderObject();
              Offset localPosition =
                  referenceBox.globalToLocal(details.globalPosition);
              _points = List.from(_points)..add(localPosition);
            });
          },
        
          onPanEnd: (DragEndDetails details) => _points.add(null),
          child: CustomPaint(
            child: Container(
              padding: EdgeInsets.fromLTRB(220.0, 580.0, 5.0, 10.0),
                child: FloatingActionButton(
                backgroundColor: Colors.pink,
                child: Text('CLEAR SCREEN'),
                
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                
                onPressed: (){_points.clear();}
              ),
            ),
            painter: SignaturePainter(_points, _pickedColor),
            size: Size.infinite,
          ),
        );
      }
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this.points, this.pickedColor);
  final List<Offset> points;
  Color pickedColor;
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = pickedColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) 
        canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  bool shouldRepaint(SignaturePainter other) => other.points != points;
}