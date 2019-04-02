import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: StWg());
  }
}

class StWg extends StatefulWidget {
  @override
  St createState() => new St();
}

class St extends State<StWg> {
  final controller = PageController(initialPage: 0);
  static const LatLng _center = const LatLng(45.521563, -122.677433);

  File _image;

  List<Note> items;
  StreamSubscription<Event> _subsc;
  final ref = FirebaseDatabase.instance.reference().child('notes');

  TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    items = new List();
    _subsc = ref.onChildAdded.listen(_onNoteAdded);
    _titleController = new TextEditingController();
  }

  Future _getImg() async {
    var userLocation = await new Location().getLocation();
    var i = await ImagePicker.pickImage(source: ImageSource.camera);
    if (i != null) {
      setState(() {
        _image = i;
      });
      print("Location:" + userLocation["latitude"].toString() + " " +
          userLocation["longitude"].toString());
      _createNewNote();
    }
  }

  @override
  void dispose() {
    _subsc.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: PageView(controller: controller, scrollDirection: Axis.horizontal, children: <Widget>[_buildPage0(true), _buildList(context),],)));
  }

  Widget _buildPage0(bool left) {
    return Scaffold(
        key: PageStorageKey<String>("page0"),
        body: _buildMap(),
        floatingActionButton: new Stack(children: [
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: RawMaterialButton(
              fillColor: Colors.yellow,
              splashColor: Colors.yellowAccent,
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0,),
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[SizedBox(width: 68.0), Icon(Icons.arrow_forward,)])),
              onPressed: _doAct,
              shape: const StadiumBorder(),
            ),),
          FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.location_on,), onPressed: _getImg,),
        ]),
        floatingActionButtonLocation: left ? FloatingActionButtonLocation.endFloat: FloatingActionButtonLocation.centerFloat
    );
  }

  Widget _buildMap() {
    return GoogleMap(onMapCreated: _onMapCreated, initialCameraPosition: CameraPosition(target: _center, zoom: 11.0,),);
  }

  void _onMapCreated(GoogleMapController controller) {
//    _controller2.complete(controller);
  }

  void _doAct() {
    controller.animateToPage(1, duration: Duration(milliseconds: 250), curve: Curves.ease);
  }

  Widget _buildList(BuildContext context) {
    return Center(
      child: ListView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.all(15.0),
          itemBuilder: (context, position) {
            return Column(
              children: <Widget>[
                Divider(height: 5.0),
                ListTile(
                  title: Text('${items[position].title}', style: TextStyle(fontSize: 22.0, color: Colors.red,),),
                  subtitle: Text('${items[position].description}', style: new TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic,),),
                ),
              ],
            );
          }),
    );
  }

  void _onNoteAdded(Event event) {
    setState(() {
      items.add(new Note.fromSnapshot(event.snapshot));
    });
  }

  void _createNewNote() async {
    Navigator.of(context).push(new MaterialPageRoute(builder:
        (BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('Check-in')),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: Text('Add'),
              onPressed: () {
                  ref.push().set({
                    'title': _titleController.text,
                    'description': "text"
                  }).then((_) {
                    Navigator.pop(context);
                  });
              },
            ),
          ],
        ),
      ),
    )));
  }
}

class Note {
  String id,title,description;

  Note(this.id, this.title, this.description);

  Note.map(dynamic o) {
    this.id = o['id'];
    this.title = o['title'];
    this.description = o['description'];
  }

  Note.fromSnapshot(DataSnapshot s) {
    id = s.key;
    title = s.value['title'];
    description = s.value['description'];
  }
}