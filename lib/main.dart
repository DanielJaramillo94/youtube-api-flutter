import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xA1CB00),
    ),
  );
  runApp(YoutubePlayerDemoApp());
}

/// Creates [YoutubePlayerDemoApp] widget.
class YoutubePlayerDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtube Player Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Color(0xFFA1CB00),
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 20.0,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.blueAccent,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

/// Homepage
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;

  final searchController = TextEditingController();

  StreamController<dynamic> thumbnailsStream = StreamController();

  YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;

  List<dynamic> _ids = [
    'KzTeWPkUxQs',
    'cILHRB8Syng',
    'D77DeiIOv14',
    'Qely-s0qRaY',
    '14ORlUCJhm4',
    'XHsrxgoESz8',
  ];

  List<dynamic> _thumbnails = [
    'https://i.ytimg.com/vi/KzTeWPkUxQs/mqdefault.jpg',
    'https://i.ytimg.com/vi/cILHRB8Syng/mqdefault.jpg',
    'https://i.ytimg.com/vi/D77DeiIOv14/mqdefault.jpg',
    'https://i.ytimg.com/vi/Qely-s0qRaY/mqdefault.jpg',
    'https://i.ytimg.com/vi/14ORlUCJhm4/mqdefault.jpg',
    'https://i.ytimg.com/vi/XHsrxgoESz8/mqdefault.jpg',
  ];

  String videoTitle = 'Flutter Presentación en Español';
  String videoDescription =
      'Martin Aguinis presenta sobre Flutter en Español durante México Partner Day. Flutter es el kit UI portátil de Google para crear aplicaciones nativas para móvil, web, y desktop desde una sola código base. Esta utilizado por marcas globalmente para aplicaciones con cientos de millones de usuarios. Ésta sesión presenta a Flutter, muestra la codificación en vivo de una aplicación, habla sobre casos de éxito de marcas que utilizan Flutter y mostrará el futuro del producto';

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _ids.first,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();

    thumbnailsStream.sink.add(_thumbnails);
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Comfortaa',
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: 40,
                height: 35,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/exp-logo.png'),
                      fit: BoxFit.contain),
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Container(
                width: 200,
                height: 30,
                child: TextField(
                  controller: searchController,
                  onSubmitted: (value) {
                    searchSubmit(value);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                      left: 10,
                      bottom: 13,
                    ),
                    border: InputBorder.none,
                    hintText: 'Search',
                    fillColor: Colors.white.withAlpha(80),
                    filled: true,
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.white,
                      onPressed: () => {},
                      padding: EdgeInsets.only(
                        bottom: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          addAutomaticKeepAlives: false,
          cacheExtent: 9999,
          children: [
            _space,
            // 6 videos pannel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StreamBuilder(
                      stream: thumbnailsStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  onClickThumbnail(0);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 120,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(snapshot.data[0]),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  onClickThumbnail(1);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 120,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(snapshot.data[1]),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  onClickThumbnail(2);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 120,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(snapshot.data[2]),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  onClickThumbnail(3);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 120,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(snapshot.data[3]),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  onClickThumbnail(4);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 120,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(snapshot.data[4]),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  onClickThumbnail(5);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 120,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(snapshot.data[5]),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      })),
            ),
            _space,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: player,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 35.0, top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _space,
                  Text(
                    videoTitle,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 23.0,
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _space,
                  _space,
                  Text(
                    videoDescription,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18.0,
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  _space,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);

  searchSubmit(String keyword) async {
    String url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$keyword&type=video&key=AIzaSyDttOKxJNffVQ2D5R1zSHz_2vozDHfEFBM&maxResults=6';
    http.Response response = await http.get(url);

    Map data = json.decode(response.body);
    List<dynamic> items = data['items'];

    List<dynamic> thumbs =
        items.map((e) => e['snippet']['thumbnails']['medium']['url']).toList();
    _thumbnails = thumbs;

    List<dynamic> ids = items.map((e) => e['id']['videoId']).toList();
    _ids = ids;

    thumbnailsStream.sink.add(thumbs);
    _isPlayerReady ? _controller.load(items[0]['id']['videoId']) : null;

    onClickThumbnail(0);
  }

  onClickThumbnail(int index) async {
    _isPlayerReady ? _controller.load(_ids[index]) : null;
    String videoInfoUrl =
        'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=${_ids[index]}&key=AIzaSyDttOKxJNffVQ2D5R1zSHz_2vozDHfEFBM';

    http.Response response = await http.get(videoInfoUrl);

    Map data = json.decode(response.body);
    Map item = data['items'][0]['snippet'];

    String title = item['title'];
    String description = item['description'];

    videoTitle = title;
    videoDescription = description;
  }
}
