import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

LocationData myLocation;
Location location = new Location();


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: location.getLocation(),
      builder: (context, snapshot) {
        print ("SNAPSHOT 1 ${snapshot.data}");
        if (snapshot.data == null) {
          print("SNAPSHOT DATA: ${snapshot.data}");
          location.requestPermission();
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          print ("SNAPSHOT 2 ${snapshot.data}");
          myLocation = snapshot.data;
          print ("BUILD");
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
                  // TODO: REQUEST HELP
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

  static const double RADIUS = 20;
  final Set<Marker> helpMarkers = new Set();
  final Completer<GoogleMapController> _controller = Completer();
  final BehaviorSubject<double> radiusBehavior = BehaviorSubject.seeded(RADIUS);
  StreamSubscription subscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location.onLocationChanged.listen((LocationData currentLocation) {
      myLocation = currentLocation;
      print ("MY NEW LOCATION $myLocation");
      updateLocation();
      getHelpRequest();
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
            markers: helpMarkers,
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
    var ref = FirebaseFirestore.instance.collection("location");
  }
  @override
  void dispose() {
    radiusBehavior.close();
    subscription.cancel();
    super.dispose();
  }
}


