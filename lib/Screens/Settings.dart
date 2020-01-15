import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Models/ProfileTextEditor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/UserData.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class Settings extends StatefulWidget {
  static final PERFER_NOT_TO_SAY = 0;
  static final FEMALE = 1;
  static final MALE = 2;

  Settings({Key key, this.title}) : super(key: key);
  final String title;


  @override
  _Settings createState() {
    return _Settings();
  }
}

class _Settings extends State<Settings> {
  final _descriptionController = TextEditingController();
  final _workExperiencesController = TextEditingController();
  final _educationController = TextEditingController();
  String _firstName;

  int _gender = PERFER_NOT_TO_SAY;
  String _lastName;

  String _userName;

  String _description;
  String _education;
  String _experience;
  UserData userData;
  Future<String> _profile;
  final globalData = SharedPreferences.getInstance();

  initUserData() async {
    _profile = globalData.then((res) {
      return UserData.toUserData(res.getString('UserData')).profile;
    });
    userData = UserData.toUserData((await globalData).getString("UserData"));
    _firstName = userData.firstName;
    _lastName = userData.lastName;
    _userName = userData.userName;
    _gender = userData.gender;
     _descriptionController.text = userData.description;
    _educationController.text = userData.education;
    _workExperiencesController.text= userData.experience;
    setState(() {});
  }


  ProgressDialog pr;
  static final PERFER_NOT_TO_SAY = 0;
  static final FEMALE = 1;
  static final MALE = 2;

  @override
  void initState() {
    initUserData();
    super.initState();
  }


  leavePage() {
    Navigator.pop(context);
  }

  double _height;
  double _width;

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, isDismissible: false);
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    double _topHeight = _height * 0.25;
    double _middleHeight = _height * 0.68;
    double _bottomHeight = _height - _topHeight - _middleHeight;
    return new WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Color.fromARGB(255, 31, 34, 52),
          body: Column(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 20),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            color: Colors.white,
                            iconSize: 30,
                            onPressed: leavePage,
                          ),
                          Text(
                            'Your Profile',
                            style: TextStyle(
                              fontSize: 36,
                              fontFamily: "IBM Plex Sans",
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 65),
                      child: Row(
                        children: <Widget>[
                          FutureBuilder<String>(
                            future: _profile, // a Future<String> or null
                            builder: (BuildContext _context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasError ||
                                  snapshot.connectionState !=
                                      ConnectionState.done) {
                                return SizedBox(
                                  child: CircularProgressIndicator(),
                                  height: 70.0,
                                  width: 70.0,
                                );
                              } else {
                                if(snapshot.data == null || snapshot.data==""){
                                  return SizedBox(
                                    child: CircularProgressIndicator(),
                                    height: 70.0,
                                    width: 70.0,
                                  );
                                }
                                return SizedBox(
                                  child: ClipRRect(
                                    borderRadius: new BorderRadius.all(
                                        const Radius.circular(40.0)),
                                    child: Image.network(
                                      snapshot.data,
                                    ),
                                  ),
                                  height: 70.0,
                                  width: 70.0,
                                );
                              }
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: _width * 0.4,
                                  child: AutoSizeText(
                                    _firstName.toString() + " " + _lastName.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40),
                                    minFontSize: 20,
                                    maxFontSize: 30,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/images/small_linkdin_logo.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: SizedBox(
                                        width: _width * 0.4,
                                        child: AutoSizeText(
                                          _userName,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          minFontSize: 15,
                                          maxFontSize: 20,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Icon(
                                Icons.file_download,
                                color: Colors.white,
                                size: 40,
                              ),
                              Text(
                                'QR',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                color: Color.fromARGB(255, 41, 43, 66),
                height: _topHeight,
              ),
              Container(
                height: _middleHeight,
                width: _width * 0.88,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Opacity(
                        opacity: 0.38,
                        child: Text(
                          'Write down the information you want other people to know about you, choose your 3D avatar, customise your own AR business card below!  ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: ProfileTextEditor(
                        Text(
                          'Gender',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                        ProfileTextEditor.DROPDOWN,
                        _descriptionController,
                        hint: 'Tell us more about yourself',
                        dropContent: ["Perfer not to say", "Female", "Male"],
                        currentSelect: _gender ==
                                ProfileTextEditor.PERFER_NOT_TO_SAY
                            ? 'Perfer not to say'
                            : _gender == FEMALE ? 'Female' : 'Male',
                        dropOnChange: (value) {
                          if (value == 'Perfer not to say') {
                            _gender = PERFER_NOT_TO_SAY;
                          } else if (value == 'Female') {
                            _gender = FEMALE;
                          } else if (value == 'Male') {
                            _gender = MALE;
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: ProfileTextEditor(
                          Text(
                            'One-Sentence Description',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          ProfileTextEditor.TEXTBOX,
                          _descriptionController,
                          hint: 'Tell us more about yourself'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: ProfileTextEditor(
                          Text(
                            'Work Experiences',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          ProfileTextEditor.TEXTBOX,
                          _workExperiencesController,
                          hint:
                              'Where do you currently work? How about 3 years ago?'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: ProfileTextEditor(
                          Text(
                            'Education',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          ProfileTextEditor.TEXTBOX,
                          _educationController,
                          hint:
                              'Where did you attend your uni and high school? How was your grade?'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Opacity(
                        opacity: 0.38,
                        child: Text(
                          'You can download your QR code for printing on your physical business card by tap the button at the top right corner.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Opacity(
                        opacity: 0.38,
                        child: Text(
                          'Change your name and profile picture in your LinkedIn account.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: FlatButton(
                            child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 61, 63, 83),
                            borderRadius:
                                BorderRadius.all(const Radius.circular(30.0)),
                          ),
                          width: 150,
                          height: 40,
                          child: Center(
                              child: Text(
                            'Open',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          )),
                        ))),
                    Padding(
                      padding: EdgeInsets.only(top: 6, bottom: 80),
                      child: FlatButton(
                        child: Text(
                          'Logout LinkedIn',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: _bottomHeight,
                color: Color.fromARGB(255, 41, 43, 66),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 61, 63, 83),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(30.0)),
                        ),
                        width: 150,
                        height: 40,
                        child: Center(
                            child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        )),
                      ),
                      onPressed: _onLeaving,
                    ),
                    FlatButton(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 61, 63, 83),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(30.0)),
                        ),
                        width: 150,
                        height: 40,
                        child: Center(
                            child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        )),
                      ),
                      onPressed: () {
                        contentOnSave();
                        Navigator.of(context).pop(true);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        onWillPop: _onLeaving);
  }

  contentOnSave()async {
    userData.experience = _workExperiencesController.text;
    userData.gender = _gender;
    userData.education = _educationController.text;
    userData.description = _descriptionController.text;
    String userJson = userData.getJson();
    await storeValue(userJson);
    return;
  }

  storeValue(userJson) async {
    (await globalData).setString("UserData", userJson);
    pr.show();
    http
        .post('http://51.11.45.102:8080/profile/update',
            headers: {"Content-Type": "application/json"}, body: userJson)
        .timeout(const Duration(seconds: 5))
        .catchError((err) {
      pr.hide();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Network Error"),
              content: new Text("please contact admin"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                    pr.hide();
                  },
                ),
              ],
            );
          });
    }).then((http.Response response) {
      if (response.statusCode != null && response.statusCode == 200) {
        pr.hide();
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Network Error"),
                content: new Text("please contact admin"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("Close"),
                    onPressed: () {
                      pr.hide();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    });
  }

  contentOnExit() {
    return;
  }

  Future<bool> _onLeaving() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to keep you change?'),
            actions: <Widget>[
              new FlatButton(
                  child: new Text("Discard"),
                  onPressed: () {
                    contentOnExit();
                    Navigator.of(context).pop(true);
                  }),
              new FlatButton(
                  child: new Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
            ],
          ),
        )) ??
        false;
  }
}
