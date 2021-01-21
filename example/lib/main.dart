import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dt_aiui_plugin/dt_aiui_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Map<String, Object> _listenResult;

  StreamSubscription<Map<String, Object>> _DtListener;

  DtAiuiPlugin _DtPlugin = DtAiuiPlugin();

  @override
  void initState() {
    super.initState();

    // 填写自己的appid
    DtAiuiPlugin.initAIUIAgent("5f9628d0");

    _DtListener =
        _DtPlugin.onResultCallback().listen((Map<String, Object> result) {
          setState(() {
            _listenResult = result;
            try {
              print(result);
            } catch (e) {
              print(e);
            }
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (null != _DtListener) {
      _DtListener.cancel();
    }
  }

  /// 启动定位
  void _startLocation() {
    if (null != _DtPlugin) {
      _DtPlugin.startVoiceNlp();
    }
  }

  /// 停止定位
  void _stopLocation() {
    if (null != _DtPlugin) {
      _DtPlugin.stopVoiceNlp();
    }
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
                      _startLocation();
                    },
                    child: Text('start voice nlp'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: (){
                      _stopLocation();
                    },
                    child: Text('stop voice nlp'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Text(_listenResult == null ? "看我七十二变" : _listenResult['msg']),
                )
              ],
            ),
          )
      ),
    );
  }

}
