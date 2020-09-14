import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

Position currentLocation;
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          print("SNAPSHOT DATA: ${snapshot.data}");
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          currentLocation = new Position(longitude: snapshot.data.longitude, latitude: snapshot.data.latitude);
          print(currentLocation.longitude);
          print(currentLocation.latitude);
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

  final CameraPosition defaultCameraPosition = CameraPosition(
      zoom: 14,
      tilt: 0,
      target: LatLng(0,0)
  );
  final Set<Marker> helpMarkers = new Set();
  final Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    print("BUILDX");

    return Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              zoom: 14,
              tilt: 0,
              target: LatLng(currentLocation.latitude,currentLocation.longitude)
            ),
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
  }


