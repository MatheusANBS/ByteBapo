import 'package:byte_papo/features/characters/data/platform_avatar_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('byte_papo/avatar_picker');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('returns the path selected by the Android channel', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'pickAvatar');
          return '/tmp/avatar.png';
        });

    final path = await PlatformAvatarPicker().pickImagePath();

    expect(path, '/tmp/avatar.png');
  });

  test('returns null when the picker is cancelled', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);

    final path = await PlatformAvatarPicker().pickImagePath();

    expect(path, isNull);
  });
}
