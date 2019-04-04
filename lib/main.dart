import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io' as Io;
import 'package:image/image.dart' as Im;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main()=>runApp(A());
class A extends StatelessWidget{@override Widget build(BuildContext context){return MaterialApp(home:SW());}}
class SW extends StatefulWidget{@override St createState()=>St();}
class St extends State<SW> {
  List<L> it;StreamSubscription<Event> sub;
  final ref=FirebaseDatabase.instance.reference().child('r');
  final sr=FirebaseStorage.instance.ref();
  TextEditingController t;double lt,ln; int id=1;
  Map<MarkerId,Marker>m=<MarkerId,Marker>{};
  GoogleMapController ct;

  @override void initState() {super.initState();it=List();sub=ref.onChildAdded.listen(onAdd);t=TextEditingController();}
  Future img() async {
    var f=await ImagePicker.pickImage(source:ImageSource.camera);
    if(f!=null){Im.Image im=Im.decodeImage(Io.File(f.path).readAsBytesSync());Im.Image th=Im.copyResize(im,600);Io.File(f.path)..writeAsBytesSync(Im.encodePng(th));
      cin((await(await sr.child(Random().nextInt(10000).toString()+".jpeg").putFile(f,StorageMetadata(contentType:"image/jpeg")).onComplete).ref.getDownloadURL()),lt,ln);}
  }
  Future loc() async{
    var l=await Location().getLocation();lt=l["latitude"];ln=l["longitude"];
    setState((){m.clear();m[MarkerId("id$id")]=Marker(markerId:MarkerId("id$id"),position:LatLng(lt,ln));});
    id++;ct.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom:12,target:LatLng(lt,ln))));
  }
  @override void dispose(){sub.cancel();super.dispose();}
  @override Widget build(BuildContext context){return MaterialApp(home:Scaffold(appBar:AppBar(title:Text('Check-in')),body:list(context)));}
  Widget map(int p){
    var ll=LatLng(50,30);if (p>=0){ll=LatLng(it[p].lat,it[p].lng);m[MarkerId("id$id")]=Marker(markerId:MarkerId("id$id"),position:ll);}
    id++;return GoogleMap(scrollGesturesEnabled:true,zoomGesturesEnabled:true,onMapCreated:(c){ct=c;},markers:Set<Marker>.of(m.values),initialCameraPosition:CameraPosition(target:ll,zoom:12));
  }
  Widget list(BuildContext context){
    return Scaffold(backgroundColor:Colors.blue[600],body:ListView.builder(itemCount:it.length,itemBuilder:(context,pos) {
      return Stack(alignment:AlignmentDirectional.bottomStart,children:<Widget>[
        Padding(padding:EdgeInsets.all(12),child:Stack(alignment:AlignmentDirectional.centerStart,children:<Widget>[
        Card(color: Colors.lightBlue,shape:StadiumBorder(),child:Container(width:double.infinity,child:Padding(padding:EdgeInsets.only(left:80,right:16,top:16,bottom:16),child:Text('${it[pos].txt}',
          style:TextStyle(fontSize:20,color:Colors.white))))),
        GestureDetector(child:CircleAvatar(radius:36,backgroundImage:NetworkImage("${it[pos].url}")),
          onTap:(){Navigator.push(context,MaterialPageRoute(builder:(_){
            return Scaffold(appBar:AppBar(title:Text("${it[pos].txt}")),body:Image.network("${it[pos].url}",
            fit:BoxFit.cover,height:double.infinity,width:double.infinity));}));})]))]);}),
      floatingActionButton:FloatingActionButton(backgroundColor:Colors.green,child:Icon(Icons.location_on),onPressed:map2)
    );
  }
  void onAdd(Event e){setState((){it.insert(0,L.fromSnapshot(e.snapshot));});}
  void map2(){
    Navigator.push(context, MaterialPageRoute(builder:(_){return Scaffold(
     appBar:AppBar(automaticallyImplyLeading:false,title:Text('Your location')),body:map(-1),floatingActionButton:Row(mainAxisSize:MainAxisSize.min,children:[
       Container(margin:EdgeInsets.symmetric(horizontal:24),child:RawMaterialButton(fillColor:Colors.yellow,splashColor:Colors.yellowAccent,
         child:Padding(padding:EdgeInsets.all(12),child: Row(children:<Widget>[Icon(Icons.arrow_back),Text("Back")])),
         onPressed:(){Navigator.pop(context);},shape:StadiumBorder())),
       FloatingActionButton(child:Icon(Icons.location_on),onPressed:loc),
       Container(margin:EdgeInsets.symmetric(horizontal:24),child:RawMaterialButton(fillColor:Colors.yellow,splashColor:Colors.yellowAccent,
         child:Padding(padding:EdgeInsets.all(12),child:Row(children:<Widget>[Text("Next"),Icon(Icons.arrow_forward)])),
         onPressed:img,shape:StadiumBorder())),
     ]),floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat);}));
  }
  void cin(String u,double lt,double ln)async{
    Navigator.of(context).push(MaterialPageRoute(builder:(BuildContext context)=>Scaffold(appBar:AppBar(title:Text('Check-in')),
      body:Container(margin:EdgeInsets.all(16),child:Column(children:<Widget>[TextField(controller:t,decoration:InputDecoration(labelText:'Title'),),Padding(padding:EdgeInsets.all(8)),
      RaisedButton(child:Text('Post'),onPressed:(){ref.push().set({'txt':t.text,'url':u,'lat':lt,'lng':ln}).then((_){Navigator.pop(context);});})])))));
  }
}
class L{
  String id,txt,url;double lat,lng;
  L(this.id,this.txt,this.url);
  L.map(dynamic o) {this.id=o['id'];this.txt=o['txt'];this.url=o['url'];this.lat=o['lat'];this.lng=o['lng'];}
  L.fromSnapshot(DataSnapshot s){id=s.key;txt=s.value['txt'];lat=s.value['lat'];lng=s.value['lng'];url=s.value['url'];}
}