import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:dt_aiui_plugin/dt_aiui_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _platformVersion = false;
  String _eventContent = "nothing";
  EventChannel _eventChannel;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    bool platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await DtAiuiPlugin.initAIUIAgent;
    } on PlatformException {
      platformVersion = false;
    }
  _eventChannel = DtAiuiPlugin.eventChannel;
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _onEvent(Object object){
    setState(() {
      if (object is String) {
        _eventContent = object;
      }
    });
  }

  void _onError(Object object){
    setState(() {
      if (object is String) {
        _eventContent = object;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: GestureDetector(
            onTap: (){
              DtAiuiPlugin.startVoiceNlp;
            },
            child: Text('Running on: $_platformVersion\n -- $_eventContent'),
          ),
        ),
      ),
    );
  }
}
