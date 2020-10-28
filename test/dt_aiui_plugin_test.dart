import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_aiui_plugin/dt_aiui_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('dt_aiui_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DtAiuiPlugin.platformVersion, '42');
  });
}
