import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SessionCookieClient extends http.BaseClient {
  SessionCookieClient({http.Client? innerClient})
    : _innerClient = innerClient ?? IOClient(),
      _ownsClient = innerClient == null;

  final http.Client _innerClient;
  final bool _ownsClient;
  final Map<String, _StoredCookie> _cookies = {};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final cookies = _cookiesFor(request.url);
    if (cookies.isNotEmpty) {
      request.headers['Cookie'] = cookies
          .map((cookie) => '${cookie.name}=${cookie.value}')
          .join('; ');
    }
    final response = await _innerClient.send(request);
    _storeCookies(response, request.url);
    return response;
  }

  List<_StoredCookie> _cookiesFor(Uri uri) {
    final now = DateTime.now();
    _cookies.removeWhere(
      (_, cookie) =>
          cookie.expiresAt != null && !cookie.expiresAt!.isAfter(now),
    );
    return _cookies.values.where((cookie) {
      final hostMatches = cookie.hostOnly
          ? uri.host == cookie.domain
          : uri.host == cookie.domain || uri.host.endsWith('.${cookie.domain}');
      final pathMatches =
          uri.path == cookie.path ||
          (uri.path.startsWith(cookie.path) &&
              (cookie.path.endsWith('/') ||
                  uri.path.length > cookie.path.length &&
                      uri.path[cookie.path.length] == '/'));
      return hostMatches &&
          pathMatches &&
          (!cookie.secure || uri.scheme == 'https');
    }).toList()..sort((a, b) => b.path.length.compareTo(a.path.length));
  }

  void _storeCookies(http.StreamedResponse response, Uri uri) {
    for (final value in response.headersSplitValues['set-cookie'] ?? const []) {
      try {
        final cookie = Cookie.fromSetCookieValue(value);
        final rawDomain = cookie.domain;
        final domain = (rawDomain ?? uri.host).toLowerCase().replaceFirst(
          RegExp(r'^\.'),
          '',
        );
        if (uri.host != domain && !uri.host.endsWith('.$domain')) {
          continue;
        }
        final path = cookie.path ?? _defaultPath(uri.path);
        final key = '$domain|$path|${cookie.name}';
        final expiresAt = cookie.maxAge == null
            ? cookie.expires
            : DateTime.now().add(Duration(seconds: cookie.maxAge!));
        if (cookie.maxAge != null && cookie.maxAge! <= 0 ||
            expiresAt != null && !expiresAt.isAfter(DateTime.now())) {
          _cookies.remove(key);
          continue;
        }
        _cookies[key] = _StoredCookie(
          name: cookie.name,
          value: cookie.value,
          domain: domain,
          path: path,
          hostOnly: rawDomain == null,
          secure: cookie.secure,
          expiresAt: expiresAt,
        );
      } on FormatException {
        continue;
      }
    }
  }

  String _defaultPath(String requestPath) {
    final lastSlash = requestPath.lastIndexOf('/');
    return lastSlash <= 0 ? '/' : requestPath.substring(0, lastSlash);
  }

  @override
  void close() {
    _cookies.clear();
    if (_ownsClient) {
      _innerClient.close();
    }
  }
}

class _StoredCookie {
  const _StoredCookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.path,
    required this.hostOnly,
    required this.secure,
    required this.expiresAt,
  });

  final String name;
  final String value;
  final String domain;
  final String path;
  final bool hostOnly;
  final bool secure;
  final DateTime? expiresAt;
}

http.Client createSessionHttpClient() => SessionCookieClient();
