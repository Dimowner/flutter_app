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
  LatLng center = const LatLng(45.521563, -122.677433);
  List<Loc> items;
  StreamSubscription<Event> subsc;
  final ref=FirebaseDatabase.instance.reference().child('r');
  final StorageReference stor=FirebaseStorage.instance.ref();
  TextEditingController tCntr;
  double lt,ln;
  int id=1;
  Map<MarkerId, Marker>markers=<MarkerId,Marker>{};
  GoogleMapController ct;

  @override void initState() {
    super.initState();
    items=List();
    subsc=ref.onChildAdded.listen(_onNoteAdded);
    tCntr=TextEditingController();
  }

  Future _getImg() async {
    var i = await ImagePicker.pickImage(source: ImageSource.camera);
    if (i != null) {
      _checkIn((await(await stor.child(Random().nextInt(100000).toString()+".jpeg")
          .putFile(i,StorageMetadata(contentType:"image/jpeg")).onComplete).ref.getDownloadURL()),lt,ln);
    }
  }

  Future _getLoc() async {
    var l = await Location().getLocation();
    lt=l["latitude"];ln=l["longitude"];
    setState((){markers.clear();markers[MarkerId("id$id")] = Marker(markerId:MarkerId("id$id"),position:LatLng(lt,ln));});
    id++;
    ct.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom:12,target:LatLng(lt,ln))));
  }

  @override void dispose() {
    subsc.cancel();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(appBar:AppBar(title:Text('Checkinner')),
        body: PageView(controller: controller, scrollDirection: Axis.horizontal, children: <Widget>[ _buildList2(context), ],)));
  }

  Widget _buildMap(int pos) {
    var ll = center;
    if (pos>=0) {ll = LatLng(items[pos].lat, items[pos].lng); markers[MarkerId("id$id")] = Marker(markerId: MarkerId("id$id"), position: ll); }
    id++;
    return GoogleMap(scrollGesturesEnabled:true,zoomGesturesEnabled:true, onMapCreated: (c) {ct = c;},
        markers: Set<Marker>.of(markers.values), initialCameraPosition:CameraPosition(target:ll,zoom:12.0));
  }

  Widget _buildList2(BuildContext context) {
    return Scaffold(
      body:ListView.builder(
          itemCount:items.length,
          itemBuilder:(context, pos) {
            return Stack(alignment: AlignmentDirectional.bottomStart, children: <Widget>[
              Container(height: 250, child: _buildMap(pos)),
              Padding(padding: EdgeInsets.all(16),child: Stack(alignment: AlignmentDirectional.centerStart,children: <Widget>[
              Card(shape:StadiumBorder(),
                  child:Container(width:double.infinity,child: Padding(padding:EdgeInsets.only(left:88,right:16,top:16,bottom:16),child:Text('${items[pos].txt}',
                      style:TextStyle(fontSize:24,color:Colors.indigo))))),
              GestureDetector(child: CircleAvatar(radius:42,backgroundImage:NetworkImage("${items[pos].url}")),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return Scaffold(appBar:AppBar(title:Text("${items[pos].txt}")), body:Image.network("${items[pos].url}",
                    fit: BoxFit.cover, height: double.infinity, width: double.infinity,));
                  }));
                },),
              ],),)
            ],);
          }),
      floatingActionButton:FloatingActionButton(backgroundColor:Colors.blue,child:Icon(Icons.location_on),onPressed:showMap)
    );
  }

  void _onNoteAdded(Event event) {
    setState(() {
      items.add(Loc.fromSnapshot(event.snapshot));
    });
  }

  void showMap() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
     return Scaffold(
         appBar:AppBar(automaticallyImplyLeading: false,title:Text('Select location')),
         body: _buildMap(-1),
         floatingActionButton:Row(mainAxisSize: MainAxisSize.min, children: [
           Container(
             margin: EdgeInsets.symmetric(horizontal: 8.0),
             child: RawMaterialButton(
               fillColor: Colors.yellow, splashColor: Colors.yellowAccent,
               child: Padding(padding:EdgeInsets.all(12.0),
                   child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(Icons.arrow_back),Text("Back")])),
               onPressed: () {Navigator.pop(context);},
               shape: const StadiumBorder(),),),
           FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.location_on,), onPressed: _getLoc,),
           Container(
             margin: EdgeInsets.symmetric(horizontal: 8.0),
             child: RawMaterialButton(
               fillColor: Colors.yellow, splashColor: Colors.yellowAccent,
               child: Padding(padding:EdgeInsets.all(12.0),
                   child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Text("Next"), Icon(Icons.arrow_forward,)])),
               onPressed: _getImg,
               shape: const StadiumBorder(),),),
         ]),
         floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
     );
    }));
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

class Loc {
  String id,txt,url;double lat,lng;
  Loc(this.id,this.txt,this.url);
  Loc.map(dynamic o) {this.id=o['id'];this.txt=o['txt'];this.url=o['url'];this.lat=o['lat'];this.lng=o['lng'];}
  Loc.fromSnapshot(DataSnapshot s) {id=s.key;txt=s.value['txt'];lat=s.value['lat'];lng=s.value['lng'];url=s.value['url'];}
}