extension UriExt on Uri {
  /// Return path that has percent decoded.
  ///
  /// See [Uri.decodeFull] for detail.
  String toDecodedString() {
    return Uri.decodeFull(toString());
  }
}
