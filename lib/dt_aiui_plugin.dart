import 'dart:async';

import 'package:flutter/services.dart';

class DtAiuiPlugin {

  /// flutter端主动调用原生端方法
  static const MethodChannel _channel =
  const MethodChannel('dt_aiui_plugin');

  /// 原生端主动回传结果数据到flutter端
  static const EventChannel _stream =
  const EventChannel("dt_aiui_plugin_event");


  /// 初始化
  static Future<bool> initAIUIAgent(String appId) async {
    Map<String, String> map = {"appId": appId};
    final bool isSuccess = await _channel.invokeMethod('initAIUIAgent', map);
    return isSuccess;
  }

  ///开始监听
  void startVoiceNlp() {
    _channel.invokeMethod('startVoiceNlp');
    return;
  }

  ///停止监听
  void stopVoiceNlp() {
    _channel.invokeMethod('stopVoiceNlp');
    return;
  }

  /// 原生端回传键值对map到flutter端
  Stream<Map<String, Object>> onResultCallback() {
    Stream<Map<String, Object>> _resultMap;
    if (_resultMap == null) {
      _resultMap = _stream.receiveBroadcastStream().map<Map<String, Object>>(
              (element) => element.cast<String, Object>());
    }
    return _resultMap;
  }


}
