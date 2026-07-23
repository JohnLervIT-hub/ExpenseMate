import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  bool get _mobileOnly => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get supportsCamera => _mobileOnly;

  Future<String?> pickReceipt({bool fromCamera = false}) async {
    if (fromCamera && !_mobileOnly) {
      debugPrint('Camera capture is not supported on this platform.');
      return null;
    }
    try {
      final xfile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (xfile == null) return null;
      final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'receipts'));
      if (!await dir.exists()) await dir.create(recursive: true);
      final ext = p.extension(xfile.path).isNotEmpty ? p.extension(xfile.path) : '.jpg';
      final destPath = p.join(dir.path, 'receipt_${DateTime.now().millisecondsSinceEpoch}$ext');
      final saved = await File(xfile.path).copy(destPath);
      return saved.path;
    } catch (e) {
      debugPrint('pickReceipt error: $e');
      return null;
    }
  }

  Future<void> deleteReceipt(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (e) {
      debugPrint('deleteReceipt error: $e');
    }
  }
}
