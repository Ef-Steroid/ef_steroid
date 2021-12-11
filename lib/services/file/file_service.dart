abstract class FileService {
  /// The path returned from [file_picker] contains Disc information on Mac. This
  /// method can strips it off.
  String stripMacDiscFromPath({
    required String path,
  });
}
