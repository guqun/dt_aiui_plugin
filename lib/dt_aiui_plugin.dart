
import 'dart:async';

import 'package:flutter/services.dart';

class DtAiuiPlugin {
  static const MethodChannel _channel =
      const MethodChannel('dt_aiui_plugin');
  static const EventChannel eventChannel = EventChannel("dt_aiui_plugin_event");

  static Future<bool> get initAIUIAgent async {
    final bool isSuccess = await _channel.invokeMethod('initAIUIAgent');
    return isSuccess;
  }

  static Future<void> get startVoiceNlp async {
     _channel.invokeMethod('startVoiceNlp');
    return;
  }

}
