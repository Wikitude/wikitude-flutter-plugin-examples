import 'dart:io';

import 'package:flutter/material.dart';

class PoiDetailsState extends State<PoiDetailsWidget> {

  String id;
  String title;
  String description;

  PoiDetailsState(String  id, String title, String description) {
    this.id = id;
    this.title = title;
    this.description = description;
  }

  AppBar get appBar {
    if (!Platform.isIOS) {
      return null;
    }
    return new AppBar(
      title: Text("Poi Details"),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this.appBar,
      body: Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 60.0),
        child: Column (
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold)), flex: 1),
                Expanded(child: Text(id), flex: 2)
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)), flex: 1),
                  Expanded(child: Text(title), flex: 2)
                ],
              )
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold)), flex: 1),
                  Expanded(child: Text(description), flex: 2)
                ],
              )
            )
          ],
        ),
      )
    );
  }

}

class PoiDetailsWidget extends StatefulWidget {

  final String id;
  final String title;
  final String description;

  PoiDetailsWidget({
    Key key,
    @required this.id,
    @required this.title,
    @required this.description
  });

  @override
  PoiDetailsState createState() => new PoiDetailsState(id, title, description);
}