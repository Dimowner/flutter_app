import 'dart:async';import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io' as Io;import 'package:image/image.dart' as Im;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main()=>runApp(A());
class A extends StatelessWidget{@override Widget build(BuildContext context){return MaterialApp(home:W());}}
class W extends StatefulWidget{@override S createState()=>S();}
class S extends State<W> {

List<L> it;StreamSubscription<Event>sb;
final r=FirebaseDatabase.instance.reference().child('r');
final sr=FirebaseStorage.instance.ref();
TextEditingController t;
double lt,ln; int d=1;
Map<MarkerId,Marker>m=<MarkerId,Marker>{};GoogleMapController ct;

@override void initState() {super.initState();it=List();sb=r.onChildAdded.listen((e){setState((){it.insert(0,L.fromSnapshot(e.snapshot));});});t=TextEditingController();}
Future img() async {
  var f=await ImagePicker.pickImage(source:ImageSource.camera);
  if(f!=null){Im.Image im=Im.decodeImage(Io.File(f.path).readAsBytesSync());Im.Image th=Im.copyResize(im,900);Io.File(f.path)..writeAsBytesSync(Im.encodePng(th));}
  var u=await(await sr.child(Random().nextInt(10000).toString()+".jpeg").putFile(f,StorageMetadata(contentType:"image/jpeg")).onComplete).ref.getDownloadURL();
  r.push().set({'txt':t.text,'url':u,'lat':lt,'lng':ln});Navigator.pop(context);
  t.clear();
}
Future loc() async{
  var l=await Location().getLocation();lt=l["latitude"];ln=l["longitude"];
  setState((){m.clear();m[MarkerId("id$d")]=Marker(markerId:MarkerId("id$d"),position:LatLng(lt,ln));});
  d++;ct.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom:12,target:LatLng(lt,ln))));
}
@override void dispose(){sb.cancel();super.dispose();}
@override Widget build(BuildContext c){return MaterialApp(home:Scaffold(appBar:AppBar(title:Text('Check-in')),body:ls(c)));}
Widget map(int p){
  var ll=LatLng(37.422,-122.08);if(p>=0){ll=LatLng(it[p].lat,it[p].lng);m[MarkerId("id$d")]=Marker(markerId:MarkerId("id$d"),position:ll);}
  d++;return GoogleMap(scrollGesturesEnabled:true,zoomGesturesEnabled:true,onMapCreated:(c){ct=c;},markers:Set<Marker>.of(m.values),initialCameraPosition:CameraPosition(target:ll,zoom:12));
}
Widget ls(BuildContext c){
  return Scaffold(backgroundColor:Colors.blue[600],body:ListView.builder(itemCount:it.length,itemBuilder:(c,pos){
  return Stack(alignment:AlignmentDirectional.bottomStart,children:<Widget>[Padding(padding:EdgeInsets.all(12),child:Stack(alignment:AlignmentDirectional.centerStart,children:<Widget>[
  GestureDetector(onTap:(){Navigator.push(c,MaterialPageRoute(builder:(_){return map(pos);}));},
    child:Card(color:Colors.lightBlue,shape:StadiumBorder(),child:Container(width:double.infinity,
    child:Padding(padding:EdgeInsets.only(left:80,right:16,top:16,bottom:16),child:Text('${it[pos].txt}', style:TextStyle(fontSize:20,color:Colors.white)))))),
  GestureDetector(child:CircleAvatar(radius:36,backgroundImage:NetworkImage("${it[pos].url}")),onTap:(){Navigator.push(c,MaterialPageRoute(builder:(_){
  return Scaffold(appBar:AppBar(title:Text("${it[pos].txt}")),body:Image.network("${it[pos].url}",fit:BoxFit.cover,height:double.infinity,width:double.infinity));}));})]))]);}),
  floatingActionButton:FloatingActionButton(backgroundColor:Colors.green,child:Icon(Icons.location_on),onPressed:nw));
}
void nw(){
  Navigator.push(context, MaterialPageRoute(builder:(_){return Scaffold(
  appBar:AppBar(automaticallyImplyLeading:false,title:Text('Check-in')),body:Stack(alignment:AlignmentDirectional.bottomStart,children:<Widget>[map(-1),
  Container(height:150,decoration:BoxDecoration(color:Colors.grey[200]),child:Padding(padding:EdgeInsets.only(left:16,right:16),
    child:TextField(controller:t,decoration:InputDecoration(labelText:'Impression'))))]),floatingActionButton:Row(mainAxisSize:MainAxisSize.min,children:[
  Container(margin:EdgeInsets.symmetric(horizontal:24),child:RawMaterialButton(fillColor:Colors.yellow,splashColor:Colors.yellow,
    child:Padding(padding:EdgeInsets.all(12),child:Row(children:<Widget>[Icon(Icons.arrow_back),Text("Back")])),onPressed:(){Navigator.pop(context);},shape:StadiumBorder())),
  FloatingActionButton(child:Icon(Icons.location_on),onPressed:loc),
  Container(margin:EdgeInsets.symmetric(horizontal:24),child:RawMaterialButton(fillColor:Colors.yellow,splashColor:Colors.yellow,
    child:Padding(padding:EdgeInsets.all(12),child:Row(children:<Widget>[Text("Next"),Icon(Icons.arrow_forward)])), onPressed:img,shape:StadiumBorder())),
  ]),floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat);}));
}
}
class L{
  String id,txt,url;double lat,lng;
  L(this.id,this.txt,this.url);
  L.map(dynamic o) {this.id=o['id'];this.txt=o['txt'];this.url=o['url'];this.lat=o['lat'];this.lng=o['lng'];}
  L.fromSnapshot(DataSnapshot s){id=s.key;txt=s.value['txt'];lat=s.value['lat'];lng=s.value['lng'];url=s.value['url'];}
}