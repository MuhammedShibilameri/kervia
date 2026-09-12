import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads a local file to Firebase Storage under the seeker's folder and
/// returns its download URL.
///
/// [kind] must be a short label such as 'resume' or 'video' and only affects
/// the storage path. Uploads are skipped (the value is returned unchanged)
/// when [localPath] is already an http(s) URL.
Future<String?> uploadSeekerFile({
  required String userId,
  required String localPath,
  required String kind,
}) async {
  if (localPath.isEmpty) return null;
  if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
    return localPath;
  }
  final file = File(localPath);
  if (!await file.exists()) return null;

  FirebaseStorage? storage;
  try {
    storage = FirebaseStorage.instance;
  } catch (_) {
    return null;
  }

  final ext = _safeExtension(localPath, kind);
  try {
    final ref = storage.ref('seeker_files/$userId/$kind$ext');
    await ref.putFile(
      file,
      SettableMetadata(contentType: _contentType(kind, ext)),
    );
    return await ref.getDownloadURL();
  } catch (_) {
    return null;
  }
}

String _safeExtension(String path, String kind) {
  final dot = path.lastIndexOf('.');
  if (dot > 0 && dot < path.length - 1) {
    final ext = path.substring(dot).toLowerCase();
    final cleaned = ext.replaceAll(RegExp(r'[^a-z0-9.]'), '');
    if (cleaned.isNotEmpty && cleaned.length <= 12) return cleaned;
  }
  return kind == 'resume' ? '.pdf' : '.mp4';
}

String _contentType(String kind, String ext) {
  if (kind == 'video') {
    switch (ext) {
      case '.3gp':
        return 'video/3gpp';
      case '.avi':
        return 'video/x-msvideo';
      case '.mov':
        return 'video/quicktime';
      case '.mkv':
        return 'video/x-matroska';
      case '.webm':
        return 'video/webm';
      default:
        return 'video/mp4';
    }
  }
  switch (ext) {
    case '.doc':
      return 'application/msword';
    case '.docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case '.txt':
      return 'text/plain';
    case '.rtf':
      return 'application/rtf';
    case '.png':
      return 'image/png';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    default:
      return 'application/pdf';
  }
}
