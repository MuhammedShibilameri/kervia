import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';

import '../theme/app_colors.dart';

/// True when [value] looks like a remote link rather than a local path.
bool isRemotePath(String? value) {
  return value != null &&
      (value.startsWith('http://') || value.startsWith('https://'));
}

/// Downloads a remote file into the app's temporary directory and returns the
/// local path, or null when the download fails.
Future<String?> downloadRemoteFile(String url, String? name) async {
  try {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final builder = BytesBuilder(copy: false);
      await response.forEach(builder.add);
      final bytes = builder.takeBytes();
      if (bytes.isEmpty) return null;

      final dir = await _tempDir();
      final ext = _extensionFor(url, name);
      final file = File(
        '${dir.path}/kervia_${DateTime.now().millisecondsSinceEpoch}$ext',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } finally {
      client.close();
    }
  } catch (_) {
    return null;
  }
}

Future<Directory> _tempDir() async => Directory.systemTemp;

String _extensionFor(String url, String? name) {
  final target = (name != null && name.isNotEmpty) ? name : url;
  final lower = target.toLowerCase();
  for (final ext in const [
    '.pdf',
    '.doc',
    '.docx',
    '.txt',
    '.rtf',
    '.png',
    '.jpg',
    '.jpeg',
    '.mp4',
    '.3gp',
    '.mov',
    '.mkv',
    '.webm',
    '.avi',
  ]) {
    if (lower.endsWith(ext)) return ext;
  }
  final query = lower.split('?').first;
  final match = RegExp(r'\.([a-z0-9]{1,5})$').firstMatch(query);
  if (match != null) return '.${match.group(1)}';
  return '.bin';
}

/// Opens a stored file securely: remote links are downloaded first and then
/// opened with the system viewer. Local paths are opened directly.
/// True is returned when the file was successfully opened.
Future<bool> openStoredFile(
  BuildContext context,
  String? path,
  String? name,
) async {
  if (path == null || path.isEmpty) return false;
  if (isRemotePath(path)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading, please wait...'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    final localPath = await downloadRemoteFile(path, name);
    if (localPath == null) {
      await Clipboard.setData(ClipboardData(text: path));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed. Link copied to clipboard.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
    try {
      await OpenFilex.open(localPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  final file = File(path);
  if (!await file.exists()) return false;
  try {
    await OpenFilex.open(path);
    return true;
  } catch (_) {
    return false;
  }
}
