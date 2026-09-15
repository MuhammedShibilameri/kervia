/// Cloudinary configuration for unsigned (client-side) uploads.
///
/// These two values are PUBLIC and safe to ship inside the app (that is the
/// whole point of an *unsigned* upload preset — no API secret is needed):
///
/// [cloudName]  -> your Cloudinary dashboard URL:
///    https://res.cloudinary.com/CLOUD_NAME
/// [uploadPreset] -> an UNSIGNED preset created in Cloudinary dashboard:
///    Settings -> Upload -> Upload presets -> "Add upload preset"
///    -> Signing Mode: **Unsigned**.
///
/// Remember: unsigned uploads are limited to 10 MB per file, so intro videos
/// should be kept small/compressed.
class CloudinaryOptions {
  CloudinaryOptions._();

  static const String cloudName = 'si1ucf3p';

  static const String uploadPreset = 'kervia_app';
}