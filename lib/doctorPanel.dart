import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medkit/customWidgets/addDisease.dart';
import 'package:medkit/customWidgets/customListTiles.dart';
import 'package:toast/toast.dart';
import 'animations/listViewAnimation.dart';
import 'doctor.dart';

class DoctorPanel extends StatefulWidget {
  final UserDetails detailsUser;

  DoctorPanel({Key key, @required this.detailsUser}) : super(key: key);

  @override
  _DoctorPanelState createState() => _DoctorPanelState();
}

class _DoctorPanelState extends State<DoctorPanel> {
  Future getDiseaseInfo() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("Diseases").getDocuments();
    return qn.documents;
  }

  final GoogleSignIn _gSignIn = GoogleSignIn();

  bool editPanel = false;


  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(
          "Log Out",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: new Text("Are You Sure?"),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new RaisedButton(
            shape: StadiumBorder(),
            color: Colors.white,
            child: new Text(
              "Close",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new RaisedButton(
            shape: StadiumBorder(),
            color: Colors.white,
            child: new Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              _gSignIn.signOut();
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 3);
            },
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          key: _scaffoldKey,
          drawer: new Drawer(
              child: Stack(
            children: <Widget>[
              Positioned(
                left: -80,
                child: Opacity(
                  opacity: 0.4,
                  child: CircleAvatar(
                    radius: 130,
                    backgroundColor: Colors.black.withOpacity(0.2),
                    child: Image(image: AssetImage('assets/bigDoc.png')),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 220, 0, 0),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      backgroundImage: NetworkImage(widget.detailsUser.photoUrl),
                      radius: 60.0,
                    ),
                    SizedBox(height: 10),
                    Text("Dr. " + widget.detailsUser.userName,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black.withOpacity(0.5),
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(widget.detailsUser.userEmail,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 30,
                    ),
                    RaisedButton.icon(
                        color: Colors.white,
                        onPressed: () {
                          _logOutAlertBox(context);
                        },
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                        label: Text(
                          'Log Out',
                          style: TextStyle(color: Colors.red),
                        )),
                    SizedBox(height: 200,),
                    Text('Version', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('v 0.1')
                  ],
                )),
              ),
            ],
          )),
          body: Stack(
            children: <Widget>[
              Positioned(
                  top: 50,
                  right: -20,
                  child: Image(
                      height: 190,
                      image: AssetImage('assets/bigDoc.png'))),
              Positioned(
                top: 40,
                child: FlatButton(
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                      size: 30,
                    )),
              ),
              Positioned(
                top: 200,
                left: 20,
                child: editPanel
                    ? Container(
                        height: 35,
                        child: WidgetAnimator(
                          RawMaterialButton(
                            shape: StadiumBorder(),
                            fillColor: Colors.blue,
                            child: Text('Add More', style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => AddDisease()));
                            },
                          ),
                        ),
                      )
                    : Text(''),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 150, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 35,
                        child: FloatingActionButton(
                          heroTag: 'editBtn',
                          tooltip: 'Edit Panel',
                          backgroundColor:
                              editPanel ? Colors.green : Colors.white,
                          child: editPanel
                              ? WidgetAnimator(
                                  Icon(
                                    Icons.done,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                )
                              : WidgetAnimator(
                                  Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                ),
                          onPressed: () {
                            setState(() {
                              editPanel = !editPanel;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        "Doctor's",
                        style: GoogleFonts.abel(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 180,
                  left: 110,
                  child: Text('Panel', style: TextStyle(fontSize: 18),)),
              FutureBuilder(
                future: getDiseaseInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    );
                  }
                   else {
                    return Container(
                      margin: EdgeInsets.fromLTRB(0, 240, 0, 0),
                      child: ListView.separated(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.transparent,
                        ),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return WidgetAnimator(CustomTile(
                            delBtn: editPanel,
                            snapshot: snapshot.data[index],

                          ));
                        },
                      ),
                    );
                  }
                },
              )
            ],
          )),
    );
  }

  void _logOutAlertBox(context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Log Out",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: new Text("Are You Sure?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new RaisedButton(
              shape: StadiumBorder(),
              color: Colors.white,
              child: new Text(
                "Close",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new RaisedButton(
              shape: StadiumBorder(),
              color: Colors.white,
              child: new Text(
                "Log Out",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _gSignIn.signOut();
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 3);
              },
            ),
          ],
        );
      },
    );
  }
}
