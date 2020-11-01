import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:http/http.dart' as http;


class FoxBase {
  int id;
  String imageUrl;
  String name;

  FoxBase({this.id, this.imageUrl, this.name});

  FoxBase.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        imageUrl = json['imageUrl'];
        name = json['name'];
  }
}

class FoxStatus {
  int loves;
  int hates;

  FoxStatus({this.loves, this.hates});

  FoxStatus.fromJson(Map<String, dynamic> json) {
    loves = json['loves'];
    hates = json['hates'];
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoXinder',
      theme: ThemeData(

        primarySwatch: Colors.pink,

        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
      home: MyHomePage(title: 'Find Your True Fox 🦊'),

    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<FoxBase> _foxes = List<FoxBase>();
  FoxStatus _foxStatus = FoxStatus();

  int _foxIndex = 0;
  String _imageUrl = "https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/237/fox-face_1f98a.png";
  String _name = "name";
  int _like = 0;
  int _dislike = 0;

  var  _URL_API = 'https://foxapi.ktos.dev/api/fox';
  String _AUTH = 'Basic ' + base64Encode(utf8.encode('user:password'));

  Future<List<FoxBase>> fetchFoxBase() async {
    var response = await http.get(_URL_API);
    var foxes = List<FoxBase>();

    if (response.statusCode == 200) {
      var foxesJson = json.decode(response.body);
      for (var foxJson in foxesJson) {
        foxes.add(FoxBase.fromJson(foxJson));
      }
    }
    return foxes;
  }

  Future<FoxStatus> fetchFoxStatus() async {
    String url = _URL_API + "/" + _foxes[_foxIndex].id.toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return FoxStatus.fromJson(json.decode(response.body));
    }
  }

  void _showFox() {
    setState(() {
      _imageUrl = _foxes[_foxIndex].imageUrl;
      _name = _foxes[_foxIndex].name;
      _like = _foxStatus.loves;
      _dislike = _foxStatus.hates;
    });
  }

  void _updateStatus() {
    fetchFoxStatus().then((value) {
      _foxStatus = value;
      setState(() {
        _like = _foxStatus.loves;
        _dislike = _foxStatus.hates;
      });
    });
  }


  void _swipeLeft() {
    setState(() {
      if (_foxIndex > 0 ) {
        _foxIndex--;
        _updateStatus();
        _showFox();
      }
    });
  }

  void _swipeRight() {
    setState(() {
      if (_foxIndex < _foxes.length-1) {
        _foxIndex++;
        _updateStatus();
        _showFox();
      }
    });
  }

  void _likeAction() {
    http.put(_URL_API + "/love/" + _foxes[_foxIndex].id.toString(),
      headers: {HttpHeaders.authorizationHeader: _AUTH},
    );
      _updateStatus();
  }

  void _dislikeAction() {
    http.put(_URL_API + "/hate/" + _foxes[_foxIndex].id.toString(),
      headers: {HttpHeaders.authorizationHeader: _AUTH},
    );
    _updateStatus();
  }

  @override
  void initState() {
    super.initState();
    fetchFoxBase().then((value) {
      setState(() {
        _foxes.addAll(value);
        _showFox();
        _updateStatus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SwipeDetector(
              child: Image.network(_imageUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  fit: BoxFit.fitWidth),
              onSwipeLeft: _swipeLeft,
              onSwipeRight: _swipeRight,
            ),
            Text(
              _name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '❤️ $_like',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                Text(
                  '💔️ $_dislike',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                )
              ]
            ),
              Expanded(child:
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      color: Colors.green,
                      iconSize: 120,
                      onPressed: _likeAction,
                    ),
                    IconButton(
                      icon: Icon(Icons.thumb_down),
                      color: Colors.black,
                      iconSize: 120,
                      onPressed: _dislikeAction,
                    )
                  ]
              ),)
          ],
        ),
      ),
    );
  }
}


