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
    _eventChannel = DtAiuiPlugin.eventChannel;

    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);

    try {
      platformVersion = await DtAiuiPlugin.initAIUIAgent("5f9628d0"); // 填写自己的appid
    } on PlatformException {
      platformVersion = false;
    }

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
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: (){
                      DtAiuiPlugin.startVoiceNlp;
                    },
                    child: Text('start voice nlp'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: (){
                      DtAiuiPlugin.stopVoiceNlp;
                    },
                    child: Text('stop voice nlp'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Text(_eventContent),
                )
              ],
            ),
          )
      ),
    );
  }
}
