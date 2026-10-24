class ApiConfig {
  const ApiConfig({required this.baseUrl});

  const ApiConfig.fromEnvironment()
    : baseUrl = const String.fromEnvironment('API_BASE_URL');

  final String baseUrl;

  Uri endpoint(String path) {
    final configuredUrl = baseUrl.trim();
    if (configuredUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL belum diatur. Gunakan --dart-define=API_BASE_URL=https://alamat-laravel-anda.',
      );
    }

    final baseUri = Uri.tryParse(configuredUrl);
    if (baseUri == null ||
        !{'http', 'https'}.contains(baseUri.scheme) ||
        baseUri.host.isEmpty ||
        baseUri.query.isNotEmpty ||
        baseUri.fragment.isNotEmpty) {
      throw const FormatException(
        'API_BASE_URL harus berupa alamat HTTP(S) tanpa query atau fragment.',
      );
    }

    return baseUri.resolve(path.replaceFirst(RegExp(r'^/+'), ''));
  }
}
