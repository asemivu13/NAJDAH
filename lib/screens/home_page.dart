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
LocationData currentLocation;
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
        latitude: currentLocation.latitude, longitude: currentLocation.longitude);
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
                child: const Text("Loading"),
              ),
            ),
          );
        } else {
          currentLocation = snapshot.data;
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
                              authService.signOut();
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
        latitude: currentLocation.latitude, longitude: currentLocation.longitude);
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
  static const double RADIUS = 5;
  final Set<Marker> requestMarkers = new Set();
  final Set<Circle> circleSet = new Set();
  final Completer<GoogleMapController> _controller = Completer();
  StreamSubscription subscription;
  final Geoflutterfire geoflutterfire = Geoflutterfire();
  final BehaviorSubject<double> circleRadiusBehavior = BehaviorSubject.seeded(RADIUS);
  bool enableInfoBottomSheet;
  bool doFunctionOnce = true;
  final CollectionReference helpRef = FirebaseFirestore.instance.collection('canHelp');
  final CollectionReference userRef = FirebaseFirestore.instance.collection("users");
  final CollectionReference helpRequestRef = FirebaseFirestore.instance.collection('help_requests');
  @override
  void initState() {
    super.initState();
    location.changeSettings(
      interval: 10000,
      accuracy: LocationAccuracy.high,
    );
    location.onLocationChanged.listen((LocationData _location) {
      currentLocation = _location;
      storeLocationToDatabase ();
      getHelpRequest();
      getHelperMarker();
      updateLocation();
    });
    enableInfoBottomSheet = false;
  }
  @override
  Widget build(BuildContext context) {
    CameraPosition defaultCameraPosition =
        CameraPosition(zoom: 14, tilt: 0, target: LatLng(0, 0));
    if (currentLocation != null) {
      defaultCameraPosition = CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
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

  void storeLocationToDatabase () async {
    GeoPoint myGeo = new GeoPoint(currentLocation.latitude, currentLocation.longitude);
    if (FirebaseAuth.instance.currentUser.uid != null) {
      userRef.doc(FirebaseAuth.instance.currentUser.uid).update({
        'location': myGeo,
      });
    }
  }
  void updateLocation() async {
    // Update Camera position
    if (doFunctionOnce) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(
          LatLng(currentLocation.latitude, currentLocation.longitude)));
      doFunctionOnce = false;
    }
  }

  void getHelpRequest() async {
    if (FirebaseAuth.instance.currentUser.uid != null) {
      GeoFirePoint geoCenterCurrentLocation = geoflutterfire.point(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude);
      subscription = circleRadiusBehavior.switchMap((circleRadius) {
        return geoflutterfire.collection(collectionRef: helpRequestRef).within(
            center: geoCenterCurrentLocation,
            radius: circleRadius,
            field: 'location',
            strictMode: true);
      }).listen(listenToMarkers);
    }
  }
  void getHelperMarker () async {
    if (FirebaseAuth.instance.currentUser.uid != null) {
      helpRef.doc(FirebaseAuth.instance.currentUser.uid).get().then((value) {
        if (value.data() != null) {
          value.data().forEach((key, _value) {
            listenToHelperMarkers(key, _value);
          });
        }
      });
    }
  }
  void listenToHelperMarkers(key,_value) {
    if(_value == true) {
      GeoPoint tempPoint;
      userRef.doc(key).get().then((value) {
        tempPoint = value.data()['location'];
        print(tempPoint.longitude);
        print(tempPoint.latitude);
        circleSet.add(Circle(
          circleId: CircleId(key),
          center: LatLng(tempPoint.latitude, tempPoint.longitude),
          radius: 1,
          fillColor: Colors.brown,
        ));
      });
    } else {
      circleSet.clear();
    }
    if (mounted) {
      setState(() {

      });
    }
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
    if (mounted) {
      setState(() {});
    }
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
                    stream: userRef.doc(id).snapshots(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print("Error");
                        return Container();
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return MaterialApp(
                          debugShowCheckedModeBanner: false,
                          home: Scaffold(
                            body: Center(
                              child: const Text("Loading"),
                            ),
                          ),
                        );
                      }
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
    if (mounted) {
      setState(() {
        pressed = true;
      });
    }
  }

  @override
  void dispose() {
    circleRadiusBehavior.close();
    subscription.cancel();
    super.dispose();
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
  bool changeButton = false;
  _InfoScreenState(this.requesterID, this.description, this.type, this.canHelp, this.time);
  final CollectionReference helpRef = FirebaseFirestore.instance.collection("canHelp");
  bool requesterIsUser = true;

  @override
  Widget build(BuildContext context) {
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
            if (value.data().containsKey(FirebaseAuth.instance.currentUser.uid) != null) {
              if (value.data()[FirebaseAuth.instance.currentUser.uid] == true) {
                changeButton = true;
              } else {
                changeButton = false;
              }
            }
          }),
          builder: (context, f_snapshot) {
            if (FirebaseAuth.instance.currentUser.uid == requesterID) {
              return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child:
                        RoundedButton(
                        text: "Delete Help Request",
                        press: () {
                          deleteRequest(requesterID);
                        },
                      ),
                    ),
                  )
              );
            } else {
              return MaterialApp(
                home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Request Detail", style: TextStyle(fontSize: 20),),
                          Text("Requester Name : ${snapshot.data.data()["name"]}", style: TextStyle(fontSize: 20)),
                          Text("Type of Request : $type", style: TextStyle(fontSize: 20)),
                          Text("Descripition : $description", style: TextStyle(fontSize: 20)),
                          RoundedButton(
                            text: (f_snapshot.connectionState == ConnectionState.done) ? ((changeButton) ? "Cancel Help" : "Can Help") : "Loading",
                            press: () {
                              canHelpMethod(requesterID);
                            },
                          ),
                        ],
                      ),
                    )
                ) ,
              );
            }
          },
        );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: const Text("Loading"),
              ),
            ),
          );
        }
  }
    );
  }
  void deleteRequest (String id) {
    FirebaseFirestore.instance.collection('help_requests').doc(requesterID).delete();
    Navigator.pop(context);
  }
  void canHelpMethod(String id) {
    if (FirebaseAuth.instance.currentUser.uid == requesterID) {
      if (mounted) {
        setState(() {
          changeButton = !changeButton;
        });
      }
    } else if (FirebaseAuth.instance.currentUser.uid != requesterID && changeButton == false){
      helpRef.doc(id).set({
        FirebaseAuth.instance.currentUser.uid: true,
      });
    } else if (FirebaseAuth.instance.currentUser.uid != requesterID && changeButton == true) {
      helpRef.doc(id).set({
        FirebaseAuth.instance.currentUser.uid: false,
      });
    }
    if (mounted) {
      setState(() {
        changeButton = !changeButton;
      });
    }
  }
}
