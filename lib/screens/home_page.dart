import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: mapWidget(), // :: TODO
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
      ),
    );
  }

  Widget mapWidget () {
    return Container();
  }
}

