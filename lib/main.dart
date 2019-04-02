import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() => runApp(A());
class A extends StatelessWidget{@override Widget build(BuildContext context){return MaterialApp(home:SW());}}
class SW extends StatefulWidget{@override St createState()=>St();}

class St extends State<SW> {
  final controller = PageController(initialPage: 0);
  static const LatLng center = const LatLng(45.521563, -122.677433);
  List<Note> items;
  StreamSubscription<Event> subsc;
  final ref=FirebaseDatabase.instance.reference().child('r');
  final StorageReference stor=FirebaseStorage.instance.ref();
  TextEditingController tCntr;

  @override void initState() {
    super.initState();
    items=List();
    subsc=ref.onChildAdded.listen(_onNoteAdded);
    tCntr=TextEditingController();
  }

  Future _getImg() async {
    var l = await Location().getLocation();
    var i = await ImagePicker.pickImage(source: ImageSource.camera);
    if (i != null) {
      _checkIn((await(await stor.child(Random().nextInt(100000).toString()+".jpeg").putFile(i,StorageMetadata(contentType:"image/jpeg")).onComplete).ref.getDownloadURL()),l["latitude"],l["longitude"]);
    }
  }

  @override void dispose() {
    subsc.cancel();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: PageView(controller: controller, scrollDirection: Axis.horizontal, children: <Widget>[_buildPage0(true), _buildList(context),],)));
  }

  Widget _buildPage0(bool left) {
    return Scaffold(
        body: _buildMap(),
        floatingActionButton:Stack(children: [
          Container(
            margin:EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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

  Widget _buildMap() {return GoogleMap(onMapCreated:_onMapCreated,initialCameraPosition:CameraPosition(target:center,zoom:11.0));}

  void _onMapCreated(GoogleMapController controller) {
//    _controller2.complete(controller);
  }

  void _doAct() {controller.animateToPage(1,duration:Duration(milliseconds:250),curve:Curves.ease);}

  Widget _buildList(BuildContext context) {
    return Center(
      child:ListView.builder(
          itemCount:items.length,
//          padding:const EdgeInsets.all(16),
          itemBuilder:(context, position) {
            return Column(
              children:<Widget>[
                Divider(height: 12),
                ListTile(
                  leading:CircleAvatar(radius:32,backgroundImage:NetworkImage("${items[position].url}")),
                  title:Text('${items[position].txt}',style:TextStyle(fontSize:24,color:Colors.red)),
                  subtitle:Text('${items[position].lat}',style:TextStyle(fontSize:18,fontStyle:FontStyle.italic)),
                ),
              ],
            );
          }),
    );
  }

  void _onNoteAdded(Event event) {
    setState(() {
      items.add(Note.fromSnapshot(event.snapshot));
    });
  }

  void _checkIn(String u, double lt, double ln)async{
    Navigator.of(context).push(MaterialPageRoute(builder:(BuildContext context)=>Scaffold(
      appBar:AppBar(title:Text('Check-in')),
      body:Container(
        margin:EdgeInsets.all(16),
        child:Column(
          children:<Widget>[
            TextField(controller:tCntr,decoration:InputDecoration(labelText:'Title'),),
            Padding(padding:EdgeInsets.all(8)),
            RaisedButton(child:Text('Post'),onPressed:(){ref.push().set({'txt':tCntr.text,'url':u,'lat':lt,'lng':ln}).then((_){Navigator.pop(context);});}),
          ],
        ),
      ),
    )));
  }
}

class Note {
  String id,txt,url;double lat,lng;
  Note(this.id,this.txt,this.url);
  Note.map(dynamic o) {this.id=o['id'];this.txt=o['txt'];this.url=o['url'];this.lat=o['lat'];this.lng=o['lng'];}
  Note.fromSnapshot(DataSnapshot s) {id=s.key;txt=s.value['txt'];lat=s.value['lat'];lng=s.value['lng'];url=s.value['url'];}
}