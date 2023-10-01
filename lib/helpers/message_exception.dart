class MessageException implements Exception {
  final String _message;
  MessageException(this._message);

  @override
  toString() => _message;

  String get message => _message;
}
