import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Ответ, который «вернёт» фейковый HTTP-сервер.
class FakeHttpResponse {
  FakeHttpResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

/// Записанный запрос: метод, URL и тело (как строка).
class FakeHttpRequest {
  FakeHttpRequest(this.method, this.url, this.body);

  final String method;
  final Uri url;
  final String body;

  /// Тело запроса, разобранное как JSON-объект.
  Map<String, dynamic> get json => jsonDecode(body) as Map<String, dynamic>;
}

typedef FakeHttpHandler = Future<FakeHttpResponse> Function(
  FakeHttpRequest request,
);

/// Фейковый [HttpClient]: в сеть не ходит, каждый запрос отдаёт
/// [handler] и записывает в [requests] для проверок.
///
/// Подключается через `HttpOverrides.runZoned(..., createHttpClient: ...)`.
class FakeHttpClient implements HttpClient {
  FakeHttpClient(this.handler);

  final FakeHttpHandler handler;
  final requests = <FakeHttpRequest>[];

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest(this, method, url);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
      'В тесте не используется: ${invocation.memberName}');
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this._client, this.method, this.uri);

  final FakeHttpClient _client;
  final _body = BytesBuilder();
  final _headers = _FakeHttpHeaders();

  @override
  final String method;

  @override
  final Uri uri;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  int contentLength = -1;

  @override
  bool persistentConnection = true;

  @override
  HttpHeaders get headers => _headers;

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _body.add(chunk);
    }
  }

  @override
  Future<HttpClientResponse> close() async {
    final request = FakeHttpRequest(
      method,
      uri,
      utf8.decode(_body.takeBytes(), allowMalformed: true),
    );
    _client.requests.add(request);
    return _FakeHttpClientResponse(await _client.handler(request));
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
      'В тесте не используется: ${invocation.memberName}');
}

class _FakeHttpClientResponse implements HttpClientResponse {
  _FakeHttpClientResponse(this._response)
      : _bytes = utf8.encode(_response.body) {
    // Без charset пакет `http` декодирует тело как latin1 и ломает
    // кириллицу в тестовых ответах.
    _headers.set('content-type', 'application/json; charset=utf-8');
  }

  final FakeHttpResponse _response;
  final List<int> _bytes;
  final _headers = _FakeHttpHeaders();

  @override
  int get statusCode => _response.statusCode;

  @override
  int get contentLength => _bytes.length;

  @override
  String get reasonPhrase => '';

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  HttpHeaders get headers => _headers;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      Stream<List<int>>.value(_bytes).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
      'В тесте не используется: ${invocation.memberName}');
}

class _FakeHttpHeaders implements HttpHeaders {
  final _values = <String, List<String>>{};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = [value.toString()];
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    (_values[name.toLowerCase()] ??= []).add(value.toString());
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
      'В тесте не используется: ${invocation.memberName}');
}
