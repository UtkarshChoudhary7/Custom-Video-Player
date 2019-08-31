import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:wakelock/wakelock.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String url;

  CustomVideoPlayer(this.url);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with TickerProviderStateMixin {
  VideoPlayerController _controller;
  VoidCallback _listener;
  Future<void> _initializeVideoPlayerFuture;

  AnimationController _playPauseAnimController, _forAnimController, _revAnimController;
  Animation _forwardAnim, _revAnim;

  double _aspectRatio(context) {
    return MediaQuery.of(context).size.aspectRatio;
  }

  // static const platform = MethodChannel('fullscreen');
  bool isFullscreen = true;
  bool isVisible = false;
  bool isCompleted = false;
  var _opacity = 0.0;

  // Future<void> _fullscreen() async {
  //   try {
  //     isFullscreen ? print(await platform.invokeMethod('goNormal')) : print(await platform.invokeMethod('goFullscreen'));
  //     isFullscreen = !isFullscreen;
  //   } catch(e) {
  //     print(e);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _listener = () {
      setState(() {
        if (_controller.value.position.inMilliseconds >=
            _controller.value.duration.inMilliseconds - 1000)
          isCompleted = true;
      });
    };
    _controller = VideoPlayerController.network(widget.url)
      ..addListener(_listener);
    _initializeVideoPlayerFuture = _controller.initialize().then((value) {
      _controller.play();
    });
    _playPauseAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _forAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    _forwardAnim = Tween(begin: 0.0, end: 1.0).animate(_forAnimController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          _forAnimController.reverse();
      })
      ..addListener(() {
        setState(() {});
      });
    _revAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    _revAnim = Tween(begin: 0.0, end: 1.0).animate(_revAnimController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _revAnimController.reverse();
      })
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    _playPauseAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                Center(
                  child: AspectRatio(
                    aspectRatio: !isFullscreen
                        ? _controller.value.aspectRatio
                        : _aspectRatio(context),
                    child: VideoPlayer(_controller),
                  ),
                ),
                buildOverlay('left'),
                buildOverlay('right'),
                buildControls(),
                Positioned(
                right: MediaQuery.of(context).size.width / 8,
                top: MediaQuery.of(context).size.height / 2 - 16,
                child: Opacity(
                  opacity: _forwardAnim.value,
                  child: Text(
                    '+10',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300),
                  ),
                )),
            Positioned(
                left: MediaQuery.of(context).size.width / 8,
                top: MediaQuery.of(context).size.height / 2 - 16,
                child: Opacity(
                  opacity: _revAnim.value,
                  child: Text(
                    '-10',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300),
                  ),
                )),
              ],
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ));
          }
        },
      ),
    );
  }

  Widget buildControls() {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 250),
        opacity: _opacity,
        child: Stack(
          children: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.fast_rewind),
                    onPressed: () {
                      int seekPos = _controller.value.position.inMilliseconds-10000;
                _seekTo(seekPos);
                      _revAnimController.forward();
                    },
                    color: Colors.white,
                    iconSize: 48.0,
                  ),
                  IconButton(
                    icon: isCompleted
                        ? Icon(Icons.refresh)
                        : AnimatedIcon(
                            icon: AnimatedIcons.pause_play,
                            progress: _playPauseAnimController,
                          ),
                    color: Colors.white,
                    iconSize: 64.0,
                    onPressed: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                        _playPauseAnimController.forward();
                      } else {
                        if (isCompleted) {
                          setState(() {
                            _controller.seekTo(Duration.zero).then((value) {
                              isCompleted = false;
                            });
                          });
                        }
                        _controller.play();
                        _playPauseAnimController.reverse();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.fast_forward),
                    onPressed: () {
                      int seekPos = _controller.value.position.inMilliseconds+10000;
                _seekTo(seekPos);
                      _forAnimController.forward();
                    },
                    color: Colors.white,
                    iconSize: 48.0,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: _controller.value.duration.inMilliseconds
                            .toDouble(),
                        activeColor: Colors.white,
                        inactiveColor: Colors.white24,
                        value: _controller.value.position.inMilliseconds
                            .toDouble(),
                        onChanged: (value) {
                          _seekTo(value.toInt());
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        '${_getRemTime()}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: IconButton(
                        icon: Icon(Icons.aspect_ratio),
                        color: Colors.white,
                        iconSize: 28.0,
                        onPressed: _fullscreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOverlay(String pos) {
    return Positioned(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width / 2,
      left: pos == 'left' ? 0 : MediaQuery.of(context).size.width / 2,
      child: AnimatedOpacity(
          duration: Duration(milliseconds: 250),
          opacity: _opacity,
          child: GestureDetector(
              onTap: _toggleControls,
              onLongPress: () {
                int seekPos = _controller.value.position.inMilliseconds +
                    (pos == 'left' ? -80000 : 80000);
                _seekTo(seekPos);
              },
              onDoubleTap: () {
                int seekPos = _controller.value.position.inMilliseconds +
                    (pos == 'left' ? -10000 : 10000);
                _seekTo(seekPos);
                pos == 'left' ? _revAnimController.forward() : _forAnimController.forward();
              },
              child: Container(
                color: Color(0xff121212).withOpacity(0.5),
              ))),
    );
  }

  void _seekTo(int duration) async {
    await _controller.seekTo(Duration(milliseconds: duration));
    setState(() {});
  }

  void _fullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });
  }

  void _toggleControls() {
    setState(() {
      _opacity = isVisible ? 0.0 : 1.0;
      isVisible = !isVisible;
    });
  }

  String _getRemTime() {
    int t = _controller.value.duration.inSeconds - _controller.value.position.inSeconds;
    var f = NumberFormat('00');
    String hh = f.format(t/3600);
    String mm = f.format(t/60);
    String ss = f.format(t%60);
    if (hh != '00') {
      return '$hh:$mm:$ss';
    } else {
      return '$mm:$ss';
    }
  }
}
