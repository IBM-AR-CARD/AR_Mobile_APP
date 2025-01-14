import 'dart:convert';
import 'dart:ui';
import 'package:flutter_app/Models/ImageScannerWidget.dart';
import 'package:flutter_app/Request/request.dart';
import 'package:flutter_app/Screens/Login.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../Models/SlideRoute.dart';
import '../Screens/MyCards.dart';
import '../Screens/Settings.dart';
import '../Models/GlobalData.dart';
import 'package:swipedetector/swipedetector.dart';
import '../Models/UserData.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Config.dart';
import 'package:vibration/vibration.dart';
import 'package:icon_shadow/icon_shadow.dart';

class ScanQR extends StatefulWidget {
  ScanQR({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ScanQR createState() => _ScanQR();
}

class _ScanQR extends State<ScanQR> with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;
  bool _find = false;
  GlobalData globalData;
  var fetchUserData;
  UserData userData;
  AnimationController _animationController;
  Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: new Duration(seconds: 2), vsync: this);
    scaleAnimation = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(new CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut));
    globalData = GlobalData();
    if (!globalData.hasLogin) {
      globalData.hasData = true;
    }
    _animationController.repeat(reverse: true);
//    _animationController.forward();
//    animateScanAnimation(false);
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          child: SwipeDetector(
            onSwipeLeft: navigateToSetting,
            onSwipeRight: navigateToMyCards,
            child: Stack(
              children: <Widget>[
                Container(
                  height: _height,
                  width: _width,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0, 1.0],
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(230, 10, 10, 10)
                        ],
                      ),
                    ),
                    height: _height * 0.17,
                    width: _width,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.help_outline,
                            size: 50,
                            color: Colors.white,
                          ),
                          Padding(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Scan a card to begin',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ),
                                Text.rich(TextSpan(
                                        text: 'Doesn’t have a card? Try a ',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                        children: <TextSpan>[
                                      TextSpan(
                                          text: 'demo',
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              print(
                                                  'this is scan route context $context');
                                              _find = true;
                                              await setScannedUserData(
                                                  '${Config.baseURl}/profile/get?username=jonmcnamara');
                                              print('pop');
//                                            Navigator.popUntil(context,ModalRoute.withName('/'));
                                              Navigator.popUntil(context,
                                                  (route) {
                                                print(route.settings.name);
                                                return ModalRoute.withName('/')(
                                                    route);
                                              });
//                                            Navigator.pop(context);
//                                            Navigator.pop(context);
                                            }),
                                      TextSpan(
                                        text: ' here.',
                                      ),
                                    ])
//                                  'Doesn’t have a card? Try a demo here.',
                                    ),
                              ],
                            ),
                            padding: EdgeInsets.only(left: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment(0, 0.5),
                    child: Opacity(
                      opacity: 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(50.0)),
                        ),
                        width: 280,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.center_focus_weak,
                              size: 35,
                              color: Colors.white,
                            ),
                            Padding(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Point the camera to the QR\nCode on the business card',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(left: 10),
                            )
                          ],
                        ),
                      ),
                    )),
                ImageScannerAnimation(
                  false,
                  _width * 0.8,
                  animation: scaleAnimation,
                ),
              ],
            ),
          ),
          onWillPop: () async {
            return false;
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: bottomRow());
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    globalData.qrViewController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!mounted) {
        return;
      }
      if (!_find) {
        _find = true;
        if (scanData.startsWith("${Config.baseURl}/profile/get") ||
            scanData.contains("/profile/get")) {
          Vibration.vibrate(duration: 300);
          await setScannedUserData(scanData);
          Navigator.popUntil(context, (route) {
            print(route.settings.name);
            return ModalRoute.withName('/')(route);
          });
        } else {
//          Vibration.vibrate(duration: 300);
//          await setScannedUserData(
//              '${Config.baseURl}/profile/get?username=jonmcnamara');
//          Navigator.popUntil(context, (route) {
//            print(route.settings.name);
//            return ModalRoute.withName('/')(route);
//          });
        }
//        Navigator.pop(context);
//        Navigator.pop(context);
//        Navigator.popUntil(context,ModalRoute.withName('/'));
//        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    });
  }

  setScannedUserData(scanData) async {
    ProgressDialog pr = new ProgressDialog(context, isDismissible: false);
    try {
      print('request');
      String id;
      if (globalData.hasLogin) {
        JsonEncoder jsonEncoder = JsonEncoder();
        id = jsonEncoder.convert({"_id": globalData.userData.id});
      }
      pr.show();
      final response = await http
          .post(scanData,
              headers: {"Content-Type": "application/json"}, body: id)
          .timeout(Duration(seconds: 5));
      pr.hide();
      print('request finished');
      if (response.statusCode == 200) {
        UserData userData = UserData.toUserData(response.body);
        globalData.scanData = userData;
        if (globalData.hasLogin) {
//          final scanId = jsonEncoder.convert({
//            "userid": userData.id
//          });
          final responseAddHistory = await RequestCards.historyAdd(userData.id);
          if (responseAddHistory.statusCode != 200) {
            throw new Exception();
          }
        }
      } else {
        throw new Exception();
      }
    } catch (err) {
      pr.hide();
      print(err);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Can not find that person"),
              content: new Text("please contact admin"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      _find = false;
    }
  }

  Widget bottomRow() {
    return new Padding(
        padding: const EdgeInsets.all(50.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: navigateToMyCards,
                tooltip: 'List',
                iconSize: 40.0,
                icon: IconShadowWidget(
                  Icon(
                    Icons.list,
                    size: 40,
                    color: Colors.white,
                  ),
                  shadowColor: Colors.black,
                ),
//                icon: Icon(
//                  Icons.list,
//                  color: Colors.white,
//                ),
              ),
              IconButton(
                onPressed: navigateToSetting,
                tooltip: 'Person',
                iconSize: 40.0,
                icon: IconShadowWidget(
                  Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                  shadowColor: Colors.black,
                ),
//                icon: Icon(
//                  Icons.person,
//                  color: Colors.white,
//                ),
              ),
            ]));
  }

  navigateToSetting() async {
    if (!globalData.hasLogin) {
      globalData.wantLogin = true;
      controller.pauseCamera();
      await Navigator.push(
          context,
          FadeRoute(
            page: Login(),
          ));
      controller.resumeCamera();
    } else {
      controller.pauseCamera();
      var isPop = await Navigator.push(
          context,
          SlideLeftRoute(
            page: Settings(),
          ));
      if (isPop is UserData) {
        print('is userdata');
        globalData.scanData = isPop;
        Navigator.popUntil(context, (route) {
          print(route.settings.name);
          return ModalRoute.withName('/')(route);
        });
      } else {
        controller.resumeCamera();
      }
    }
  }

  navigateToMyCards() async {
    if (!globalData.hasLogin) {
      globalData.wantLogin = true;
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool('wantLogin', true);
      controller.pauseCamera();
      await Navigator.push(
          context,
          FadeRoute(
            page: Login(),
          ));
      controller.resumeCamera();
    } else {
      controller.pauseCamera();
      final data = await Navigator.push(
        context,
        SlideRightRoute(page: MyCards()),
      );
      if (data is UserData) {
        globalData.scanData = data;
        Navigator.popUntil(context, (route) {
          print(route.settings.name);
          return ModalRoute.withName('/')(route);
        });
      } else {
        controller.resumeCamera();
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
