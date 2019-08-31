import 'package:custom_video_player/ui/customVideoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: 'Custom Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CustomVideoPlayer('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
      debugShowCheckedModeBanner: false,
    );
  }
}

