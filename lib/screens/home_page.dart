import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

LocationData myLocation;
Location location = new Location();


class HomePage extends StatelessWidget {

  final Geoflutterfire geo = new Geoflutterfire();
  final String currentUserID = FirebaseAuth.instance.currentUser.uid;
  final CollectionReference helpRequestsCollection = FirebaseFirestore.instance.collection('help_requests');
  // Request Help by get your current location and save it to the database
  // TODO: More information for the request
  Future requestHelp () async {
    GeoFirePoint geoFirePoint = geo.point(latitude: myLocation.latitude, longitude: myLocation.longitude);
    return helpRequestsCollection.doc(currentUserID).set({
      'owner': currentUserID,
      'location': geoFirePoint.data,
    });
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: location.getLocation(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          location.requestPermission();
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          myLocation = snapshot.data;
          return MaterialApp(
            home: Scaffold(
                body: MapWidget(), // :: TODO
                bottomNavigationBar: Container(
                  height: 60,
                  child: BottomAppBar(
                    elevation: 60,
                      child: Container(
                        margin: EdgeInsets.only(
                          right: 10,
                          left: 10
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              // TODO: CREATE FUNCTION TO WRAP THESE WIDGET INTO ONE WIDGET
                              Container(
                      child: IconButton(
                        icon: Icon(Icons.keyboard_arrow_up), // TODO: CHANGE THE ICON MAYBE
                        color: Colors.lightBlue,
                        onPressed: () {
                          // TODO: CREATE LIST OF EVERY REQUEST
                        },
                      ),
                      margin: EdgeInsets.only(left: 10),
                    ),
                              Container(
                                child: IconButton(
                                  icon: Icon(Icons.menu), // TODO: CHANGE THE ICON MAYBE
                                  color: Colors.lightBlue,
                                  onPressed: () {
                                  // TODO: CREATE THE MENU PAGE
                                  },
                                ),
                                margin: EdgeInsets.only(left: 10),
                              ),
                            ],
                        ),
                      ),
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended (
                  onPressed: () {
                    requestHelp();
                  },
                  icon: Icon(Icons.add),
                  label: Text("Help", style: TextStyle(fontSize: 20),),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            ),
          );
        }
      },
    );
  }
}

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {

  static const double RADIUS = 10; // TODO: CHANGE THE RADIUS TO REASONABLE NUMBER
  final Set<Marker> requestMarkers = new Set();
  final Completer<GoogleMapController> _controller = Completer();
  StreamSubscription subscription;
  final Geoflutterfire geoflutterfire = Geoflutterfire();
  final BehaviorSubject<double> circleRadiusBehavior = BehaviorSubject.seeded(RADIUS);

  @override
  void initState() {
    super.initState();
    location.changeSettings(
      interval: 1000,
      accuracy: LocationAccuracy.high,
    );
    location.onLocationChanged.listen((LocationData currentLocation) {
      print (currentLocation);
      myLocation = currentLocation;
      getHelpRequest();
      updateLocation();
    });
  }
  @override
  Widget build(BuildContext context) {
    CameraPosition defaultCameraPosition = CameraPosition(
        zoom: 14,
        tilt: 0,
        target: LatLng(0,0)
    );
    if (myLocation != null) {
      defaultCameraPosition = CameraPosition(
          target: LatLng(
              myLocation.latitude,
              myLocation.longitude
          ),
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
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            zoomControlsEnabled: false,
          ),
        ],
      );
  }

  void updateLocation () async {
    // Update Camera position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(LatLng(myLocation.latitude, myLocation.longitude)));
  }


  void getHelpRequest () async {
    var ref = FirebaseFirestore.instance.collection("help_requests");
    GeoFirePoint geoCenterCurrentLocation = geoflutterfire.point(latitude: myLocation.latitude, longitude: myLocation.longitude);
    subscription = circleRadiusBehavior.switchMap((circleRadius) {
      return geoflutterfire.collection(collectionRef: ref).within(
          center: geoCenterCurrentLocation,
          radius: circleRadius,
          field: 'location',
          strictMode: true
      );
    }).listen(listenToMarkers);
  }


  void listenToMarkers(List<DocumentSnapshot> documentList) {
    requestMarkers.clear();
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint geoPoint = document.data()['location']['geopoint'];
      requestMarkers.add(
          Marker(
            markerId: MarkerId(document.data()['location']['geohash']),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
          )
      );
    });
    setState(() {});
  }
  @override
  void dispose() {
    circleRadiusBehavior.close();
    subscription.cancel();
    super.dispose();
  }
}


