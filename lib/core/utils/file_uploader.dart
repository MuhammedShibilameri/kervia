import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';

import '../config/cloudinary_options.dart';

/// Maximum file size accepted by Cloudinary unsigned uploads (10 MB).
const int kCloudinaryUnsignedLimitBytes = 10 * 1024 * 1024;

/// Uploads a local file to Cloudinary under the seeker's folder and returns its
/// secure (https) delivery URL.
///
/// [kind] must be a short label such as 'resume' or 'video' and only affects
/// the folder/resource type. Uploads are skipped (the value is returned
/// unchanged) when [localPath] is already an http(s) URL.
///
/// Returns null when the file is missing, larger than the unsigned upload
/// limit, Cloudinary is not configured, or the upload fails.
Future<String?> uploadSeekerFile({
  required String userId,
  required String localPath,
  required String kind,
}) async {
  if (localPath.isEmpty) return null;
  if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
    return localPath;
  }
  if (!_isConfigured) return null;

  final file = File(localPath);
  if (!await file.exists()) return null;

  try {
    if (await file.length() > kCloudinaryUnsignedLimitBytes) return null;
  } catch (_) {
    return null;
  }

  final ext = _safeExtension(localPath, kind);
  final publicId = '${DateTime.now().millisecondsSinceEpoch}$ext';

  final cloudinary = CloudinaryPublic(
    CloudinaryOptions.cloudName,
    CloudinaryOptions.uploadPreset,
    cache: false,
  );

  try {
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        localPath,
        resourceType: _resourceType(kind),
        folder: 'seeker_files/$userId',
        publicId: publicId,
      ),
    );
    // Keep the extension in the delivery URL so opening the file
    // (resume PDF / intro video) detects the correct format.
    return _withExtension(response.secureUrl, ext);
  } catch (_) {
    return null;
  }
}

bool get _isConfigured =>
    !CloudinaryOptions.cloudName.startsWith('YOUR_') &&
    !CloudinaryOptions.uploadPreset.startsWith('YOUR_');

CloudinaryResourceType _resourceType(String kind) {
  switch (kind) {
    case 'video':
      return CloudinaryResourceType.Video;
    case 'resume':
      return CloudinaryResourceType.Raw;
    default:
      return CloudinaryResourceType.Auto;
  }
}

/// Cloudinary raw assets may drop the extension from the delivery URL; append
/// it if it is missing so downstream viewers know the format.
String _withExtension(String url, String ext) {
  if (url.isEmpty || ext.isEmpty) return url;
  final path = url.split('?').first.toLowerCase();
  if (path.endsWith(ext)) return url;
  return '$url$ext';
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