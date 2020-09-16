import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:najdah/Design/rounded_button.dart';
import 'package:najdah/Design/rounded_input_field.dart';
import 'package:najdah/constants.dart';
import 'package:najdah/screens/login_screen.dart';
import 'package:najdah/services/auth.dart';
import 'package:rxdart/rxdart.dart';

// Variable Across the Widget
LocationData myLocation;
Location location = new Location();

class HomePage extends StatelessWidget {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _requestHelpKey = GlobalKey<FormState>();
  BuildContext _context;
  final Geoflutterfire geo = new Geoflutterfire();
  Auth authService = new Auth();
  final CollectionReference helpRequestsCollection = FirebaseFirestore.instance.collection('help_requests');
  Size size;

  // Request Help by get your current location and save it to the database
  Future requestHelp() async {
    showHelpRequestSheet();
    GeoFirePoint geoFirePoint = geo.point(
        latitude: myLocation.latitude, longitude: myLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    _context = context;
    return FutureBuilder(
      future: location.getLocation(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          location.requestPermission();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: const CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          myLocation = snapshot.data;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: new ThemeData(canvasColor: Colors.transparent, primaryColor: kPrimaryColor),
            home: Scaffold(
              body: MapWidget(), // :: TODO
              bottomNavigationBar: Container(
                height: 60,
                child: BottomAppBar(
                  elevation: 60,
                  child: Container(
                    margin: EdgeInsets.only(right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: IconButton(
                            tooltip: "Sign Out",
                            icon:
                                Icon(Icons.exit_to_app),
                            color: kPrimaryColor,
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return LoginScreen();
                                  }
                              ));
                            },
                          ),
                          margin: EdgeInsets.only(left: 10),
                          alignment: Alignment.bottomRight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  requestHelp();
                },
                icon: Icon(Icons.add),
                label: Text(
                  "Help",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              appBar: AppBar(
                title: Text('NAJDAH'),
              ),
            ),
          );
        }
      },
    );
  }

  void showHelpRequestSheet() {
    showModalBottomSheet(
        context: _context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
              color: Colors.transparent,
              child: Container(
                  margin: EdgeInsets.all(10),

                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.all(Radius.circular(15.0))
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "REQUEST HELP",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        Form(
                          key: _requestHelpKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RoundedInputField(
                                controller: _typeController,
                                hintText: "Request Type",
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              RoundedInputField(
                                controller: _descriptionController,
                                hintText: "Description",
                                onChanged: (value) {},
                                maxLines: 6,
                              ),
                              RoundedButton(
                                text: "HELP",
                                press: () {
                                  if (_requestHelpKey.currentState.validate()) {
                                    requestHelpMethod();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
          );
        }
    );
  }

  Future requestHelpMethod() async {
    GeoFirePoint geoFirePoint = geo.point(
        latitude: myLocation.latitude, longitude: myLocation.longitude);
    User user = await authService.getCurrentUser();
    Navigator.pop(_context);
    return helpRequestsCollection.doc(user.uid).set({
      'owner': user.uid,
      'location': geoFirePoint.data,
      'time': Timestamp.now(),
      'canHelp': 0,
      'type': _typeController.value.text,
      'description': _descriptionController.value.text,
    });
  }

}


class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const double RADIUS =
      10; // TODO: CHANGE THE RADIUS TO REASONABLE NUMBER
  final Set<Marker> requestMarkers = new Set();
  final Set<Circle> circleSet = new Set();
  final Completer<GoogleMapController> _controller = Completer();
  StreamSubscription subscription;
  final Geoflutterfire geoflutterfire = Geoflutterfire();
  final BehaviorSubject<double> circleRadiusBehavior =
      BehaviorSubject.seeded(RADIUS);
  bool enableInfoBottomSheet;

  final CollectionReference requesterCollection =
      FirebaseFirestore.instance.collection('requester');
  CollectionReference helpRef;
  @override
  void initState() {
    super.initState();
    location.changeSettings(
      interval: 10000,
      accuracy: LocationAccuracy.high,
    );
    location.onLocationChanged.listen((LocationData currentLocation) {
      print(currentLocation);
      myLocation = currentLocation;
      storeToDatabase ();
      getHelpRequest();
      getHelperMarker();
      updateLocation();
    });
    enableInfoBottomSheet = false;
  }
  void storeToDatabase () async {
    final CollectionReference userRef = FirebaseFirestore.instance.collection("users");
    GeoPoint myGeo = new GeoPoint(myLocation.latitude, myLocation.longitude);
    userRef.doc(FirebaseAuth.instance.currentUser.uid).set({
      'location': myGeo,
    });
  }
  @override
  Widget build(BuildContext context) {
    CameraPosition defaultCameraPosition =
        CameraPosition(zoom: 14, tilt: 0, target: LatLng(0, 0));
    if (myLocation != null) {
      defaultCameraPosition = CameraPosition(
        target: LatLng(myLocation.latitude, myLocation.longitude),
        zoom: 14,
        tilt: 0,
      );
    }
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: defaultCameraPosition,
          markers: requestMarkers,
          myLocationEnabled: true,
          compassEnabled: true,
          buildingsEnabled: false,
          circles: circleSet,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          zoomControlsEnabled: false,
        ),
      ],
    );
  }

  void updateLocation() async {
    // Update Camera position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(myLocation.latitude, myLocation.longitude)));
  }

  void getHelpRequest() async {
    var ref = FirebaseFirestore.instance.collection("help_requests");
    GeoFirePoint geoCenterCurrentLocation = geoflutterfire.point(
        latitude: myLocation.latitude, longitude: myLocation.longitude);
    subscription = circleRadiusBehavior.switchMap((circleRadius) {
      return geoflutterfire.collection(collectionRef: ref).within(
          center: geoCenterCurrentLocation,
          radius: circleRadius,
          field: 'location',
          strictMode: true);
    }).listen(listenToMarkers);
  }
  void getHelperMarker () async {
    helpRef = FirebaseFirestore.instance.collection("canHelp");
    helpRef.doc(FirebaseAuth.instance.currentUser.uid).get().then((value) {
      if (value.data() != null) {
        value.data().forEach((key, _value) {
            listenToHelperMarkers(key, _value);
        });
      }
    });
  }
  void listenToHelperMarkers(key,_value) {
    if(_value == true) {
      var ref = FirebaseFirestore.instance.collection("users");
      GeoPoint rvalue;
      ref.doc(key).get().then((value) {
        rvalue = value.data()['location'];
        print(rvalue.longitude);
        print(rvalue.latitude);
        circleSet.add(Circle(
          circleId: CircleId(key),
          center: LatLng(rvalue.latitude, rvalue.longitude),
          radius: 1,
        ));
      });
    } else {
      circleSet.clear();
    }
    setState(() {

    });
  }

  String requesterID, description, type;
  int canHelp;
  Timestamp time;
  void listenToMarkers(List<DocumentSnapshot> documentList) {
    requestMarkers.clear();
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint geoPoint = document.data()['location']['geopoint'];
      requesterID = document.data()['owner'];
      description = document.data()['description'];
      type = document.data()['type'];
      canHelp = document.data()['canHelp'];
      time = document.data()['time'];
      InfoScreen i = new InfoScreen (requesterID, description, type, canHelp, time);
      requestMarkers.add(Marker(
          markerId: MarkerId(document.data()['location']['geohash']),
          position: LatLng(geoPoint.latitude, geoPoint.longitude),

          onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) {
                  return i;
                }
            ));
            // showInfo (requesterID, description, type, canHelp, time);
            // print ("Hello");
            // return ShowInfo (requesterID: requesterID, description: description, type: type, canHelp: canHelp, time: time,);
          }));
    });
    setState(() {});
  }

  bool pressed = false;
  void showInfo(
      String id, String description, String type, int canHelp, Timestamp time) {
    print("ID : $id");
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(Radius.circular(15.0))),
              child: Column(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(id)
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print("Error");
                        return Container();
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        print("Loading");
                        return Container();
                      }
                      print("SNAPSHOT ${snapshot.data.data().values}");
                      print(
                          "Also Data $id and $description and $type and $canHelp and $time");
                      return Container(
                        child: Column(
                          children: [
                            RaisedButton(
                              child: pressed
                                  ? Text("Cancel Help")
                                  : Text("Can Help"),
                              onPressed: () => canHelpMethod(id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void canHelpMethod(String id) {
    helpRef.doc(id).get().then((value) {
      print(value.data());
    });
    setState(() {
      pressed = true;
    });
  }

  @override
  void dispose() {
    circleRadiusBehavior.close();
    subscription.cancel();
    super.dispose();
  }
}

class ShowInfo extends StatefulWidget {
  final String requesterID, description, type;
  final int canHelp;
  final Timestamp time;
  final BuildContext context;
  ShowInfo(
      {Key key,
      this.requesterID,
      this.description,
      this.type,
      this.canHelp,
      this.time,
      this.context})
      : super(key: key);

  @override
  _ShowInfoState createState() => _ShowInfoState();
}

class _ShowInfoState extends State<ShowInfo> {
  @override
  Widget build(BuildContext context) {
    String requesterID = widget.requesterID;
    String description = widget.description;
    String type = widget.type;
    int canHelp = widget.canHelp;
    Timestamp time = widget.time;
    print("$requesterID and $description and $type and $canHelp and $time");
    return Container();
  }
}


class InfoScreen extends StatefulWidget {
  final String requesterID, description, type;
  final int canHelp;
  final Timestamp time;
  InfoScreen(this.requesterID, this.description, this.type, this.canHelp, this.time);
  @override
  _InfoScreenState createState() => _InfoScreenState(requesterID, description, type, canHelp, time);
}

class _InfoScreenState extends State<InfoScreen> {
  final String requesterID, description, type;
  final int canHelp;
  final Timestamp time;
  var rvalue;
  bool isDone = false;
  _InfoScreenState(this.requesterID, this.description, this.type, this.canHelp, this.time);
  final CollectionReference helpRef = FirebaseFirestore.instance.collection("canHelp");

  @override
  Widget build(BuildContext context) {
    print ("$requesterID and $description and $canHelp");
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(requesterID).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          print ("Error");
          return Container();
        }
        if (snapshot.hasData) {
          return FutureBuilder (
          future: helpRef.doc(requesterID).get().then((value) {
            if (value.data().containsKey(FirebaseAuth.instance.currentUser.uid) && value.data()[FirebaseAuth.instance.currentUser.uid] == true) {
              isDone = true;
            } else {
              isDone = false;
            }
          }),
          builder: (context, snapshott) {
            return MaterialApp(
              home: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${snapshot.data.data()["name"]}"),
                        Text("$type"),
                        Text("$description"),
                        RaisedButton(
                          child: (snapshott.connectionState == ConnectionState.done) ? ((isDone) ? Text("Cancel Help") : Text("Can Help")) : Text("Loading"),
                          onPressed: () {
                            canHelpMethod(requesterID);
                          },
                        ),
                      ],
                    ),
                  )
              ) ,
            );
          },
        );
        } else {
          return Container(child: Center(child: Text("Loading..."),),);
        }
  }
    );
  }
  void canHelpMethod(String id) {
    if (FirebaseAuth.instance.currentUser.uid == requesterID) {
      helpRef.doc(id).get().then((value) {
        print (value);
      });
      setState(() {
        isDone = !isDone;
      });
    } else if (FirebaseAuth.instance.currentUser.uid != requesterID && isDone == false){
      helpRef.doc(id).set({
        FirebaseAuth.instance.currentUser.uid: true,
      });
    } else if (FirebaseAuth.instance.currentUser.uid != requesterID && isDone == true) {
      helpRef.doc(id).set({
        FirebaseAuth.instance.currentUser.uid: false,
      });
    }

    // if my id != requester id show just add the number of people can help on the button
    setState(() {
      isDone = !isDone;
    });
  }
}
