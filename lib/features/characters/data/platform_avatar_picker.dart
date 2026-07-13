import 'package:flutter/services.dart';

import '../domain/avatar_picker.dart';

class PlatformAvatarPicker implements AvatarPicker {
  static const _channel = MethodChannel('byte_papo/avatar_picker');

  @override
  Future<String?> pickImagePath() =>
      _channel.invokeMethod<String>('pickAvatar');
}
