import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class InfoScreen extends StatefulWidget {
  final String requesterID, description, type;
  final int canHelp;
  final Timestamp time;
  final BuildContext context;
  InfoScreen(this.requesterID, this.description, this.type, this.canHelp, this.time, this.context);
  @override
  _InfoScreenState createState() => _InfoScreenState(requesterID, description, type, canHelp, time, context);
}

class _InfoScreenState extends State<InfoScreen> {
  final String requesterID, description, type;
  final int canHelp;
  final Timestamp time;
  final BuildContext context;
  _InfoScreenState(this.requesterID, this.description, this.type, this.canHelp, this.time, this.context);
  @override
  Widget build(BuildContext context) {
    print ("$requesterID and $description and $canHelp");
    return Container();
  }
}
