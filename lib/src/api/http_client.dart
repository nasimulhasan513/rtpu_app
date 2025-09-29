import 'dart:developer' as dev;
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HttpClientService {
  HttpClientService._internal();

  static final HttpClientService _instance = HttpClientService._internal();
  factory HttpClientService() => _instance;

  final String _baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://www.rtpu.shop/api',
  );

  final http.Client _client = http.Client();
  PersistCookieJar? _cookieJar;
  bool _initialized = false;

  String get baseUrl => _baseUrl;

  Future<void> init() async {
    if (_initialized) return;
    dev.log('HttpClientService baseUrl: $_baseUrl');
    final Directory appDocDir = await getApplicationSupportDirectory();
    final Directory cookieDir = Directory(
      '${appDocDir.path}${Platform.pathSeparator}cookies_http',
    );
    if (!cookieDir.existsSync()) {
      cookieDir.createSync(recursive: true);
    }
    _cookieJar = PersistCookieJar(storage: FileStorage(cookieDir.path));
    _initialized = true;
  }

  Uri _uri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    final String normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalized');
  }

  Future<Map<String, String>> _withCookies(Uri uri, Map<String, String> headers) async {
    final jar = _cookieJar;
    if (jar == null) return headers;
    final cookies = await jar.loadForRequest(uri);
    if (cookies.isEmpty) return headers;
    final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    return {
      ...headers,
      HttpHeaders.cookieHeader: cookieHeader,
    };
  }

  Future<void> _storeSetCookie(Uri uri, http.BaseResponse response) async {
    final jar = _cookieJar;
    if (jar == null) return;
    final setCookie = response.headers[HttpHeaders.setCookieHeader];
    if (setCookie == null || setCookie.isEmpty) return;
    // Multiple Set-Cookie headers may be concatenated by http into a single header separated by comma.
    final parts = setCookie.split(',');
    final List<Cookie> cookies = [];
    for (final part in parts) {
      try {
        cookies.add(Cookie.fromSetCookieValue(part.trim()));
      } catch (_) {}
    }
    if (cookies.isNotEmpty) {
      await jar.saveFromResponse(uri, cookies);
    }
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    await init();
    final uri = _uri(path);
    final merged = await _withCookies(uri, {
      HttpHeaders.acceptHeader: 'application/json',
      ...?headers,
    });
    final res = await _client.get(uri, headers: merged);
    await _storeSetCookie(uri, res);
    return res;
  }

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) async {
    await init();
    final uri = _uri(path);
    final merged = await _withCookies(uri, {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      ...?headers,
    });
    final res = await _client.post(uri, headers: merged, body: body);
    await _storeSetCookie(uri, res);
    return res;
  }

  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }
}


