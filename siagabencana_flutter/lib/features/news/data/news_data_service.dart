import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../app/network/api_config.dart';

class NewsCategories {
  static const String disaster = 'Bencana';
  static const String disasterLegacy = 'Berita Bencana';
  static const String earlyWarning = 'Peringatan Dini';
  static const String education = 'Edukasi Kebencanaan';
  static const String regionalInfo = 'Informasi Wilayah';

  static const List<String> all = [
    disaster,
    earlyWarning,
    education,
  ];

  static bool isDisasterCategory(String category) {
    final normalized = category.trim().toLowerCase();
    return normalized == disaster.toLowerCase() ||
        normalized == disasterLegacy.toLowerCase();
  }
}

class NewsDataService {
  NewsDataService({
    required this.apiConfig,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final ApiConfig apiConfig;
  final http.Client _client;
  final bool _ownsClient;

  Future<NewsFeedResult> fetchNews({
    String? search,
    String? category,
  }) async {
    final queryParameters = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      queryParameters['category'] = category.trim();
    }

    late final Uri uri;
    try {
      final baseEndpoint = apiConfig.endpoint('api/berita');
      uri = queryParameters.isEmpty
          ? baseEndpoint
          : baseEndpoint.replace(queryParameters: queryParameters);
    } catch (_) {
      throw const NewsDataException(
        'Layanan berita belum dapat dijangkau. Periksa konfigurasi API_BASE_URL.',
      );
    }

    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
          )
          .timeout(const Duration(seconds: 15));

      final decoded = _decodeJson(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NewsDataException(_extractError(response.statusCode, decoded));
      }

      final rawList = decoded['data'];
      if (rawList is! List) {
        throw const NewsDataException(
          'Format daftar berita dari server tidak valid.',
        );
      }

      final articles = rawList
          .whereType<Map>()
          .map((item) => NewsArticleItem.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.isPublished)
          .toList();

      NewsArticleItem? featured;
      final rawHeadline = decoded['headline'] ?? decoded['featured'];
      if (rawHeadline is Map) {
        final parsedFeatured = NewsArticleItem.fromJson(
          Map<String, dynamic>.from(rawHeadline),
        );
        if (parsedFeatured.isPublished) {
          featured = parsedFeatured;
        }
      }
      if (featured == null && articles.isNotEmpty) {
        featured = articles.firstWhere(
          (item) => item.isFeatured,
          orElse: () => articles.first,
        );
      }

      final rawCategories = decoded['categories'];
      final parsedCategories = rawCategories is List
          ? rawCategories
                .map((e) => e?.toString().trim() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
          : <String>[];

      final mergedCategories = <String>[
        ...NewsCategories.all,
        for (final item in parsedCategories)
          if (!NewsCategories.all.contains(item) &&
              item != NewsCategories.disasterLegacy)
            item,
      ];

      return NewsFeedResult(
        articles: articles,
        featured: featured,
        categories: mergedCategories,
      );
    } on NewsDataException {
      rethrow;
    } on TimeoutException {
      throw const NewsDataException(
        'Waktu koneksi habis saat memuat daftar berita. Coba lagi.',
      );
    } catch (_) {
      throw const NewsDataException(
        'Daftar berita belum dapat dimuat dari server. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  Future<NewsArticleItem> fetchNewsDetail(String slug) async {
    late final Uri uri;
    try {
      uri = apiConfig.endpoint('api/berita/${Uri.encodeComponent(slug)}');
    } catch (_) {
      throw const NewsDataException(
        'Layanan berita belum dapat dijangkau. Periksa konfigurasi API_BASE_URL.',
      );
    }

    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
          )
          .timeout(const Duration(seconds: 15));

      final decoded = _decodeJson(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NewsDataException(_extractError(response.statusCode, decoded));
      }

      final rawItem = decoded['data'];
      if (rawItem is! Map) {
        throw const NewsDataException(
          'Format detail berita dari server tidak valid.',
        );
      }

      final item = NewsArticleItem.fromJson(Map<String, dynamic>.from(rawItem));
      if (!item.isPublished) {
        throw const NewsDataException(
          'Berita tidak ditemukan atau belum dipublikasikan.',
        );
      }

      return item;
    } on NewsDataException {
      rethrow;
    } on TimeoutException {
      throw const NewsDataException(
        'Waktu koneksi habis saat memuat detail berita. Coba lagi.',
      );
    } catch (_) {
      throw const NewsDataException(
        'Detail berita tidak dapat dimuat saat ini. Coba lagi.',
      );
    }
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('Not a JSON object');
    } on FormatException {
      throw NewsDataException(
        'Server mengembalikan respons yang tidak dapat dibaca (HTTP ${response.statusCode}).',
      );
    }
  }

  String _extractError(int statusCode, Map<String, dynamic> response) {
    if (response['message'] is String &&
        (response['message'] as String).trim().isNotEmpty) {
      return response['message'] as String;
    }
    return switch (statusCode) {
      404 => 'Berita tidak ditemukan atau belum dipublikasikan.',
      _ => 'Permintaan berita belum berhasil diproses ($statusCode).',
    };
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

class NewsFeedResult {
  const NewsFeedResult({
    required this.articles,
    required this.featured,
    required this.categories,
  });

  final List<NewsArticleItem> articles;
  final NewsArticleItem? featured;
  final List<String> categories;

  NewsArticleItem? get headline => featured;
}

class NewsArticleItem {
  const NewsArticleItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.imageUrl,
    required this.summary,
    required this.content,
    required this.source,
    required this.publishedAt,
    required this.publishedFormatted,
    required this.status,
    required this.statusLabel,
    required this.isFeatured,
    this.authorName,
  });

  factory NewsArticleItem.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final title = json['title']?.toString().trim() ?? '';
    final slug = json['slug']?.toString().trim() ?? '$id';
    final category =
        json['category']?.toString().trim() ?? NewsCategories.disaster;
    final rawImage = json['image_url']?.toString().trim();
    final summary = json['summary']?.toString().trim() ?? '';
    final content = json['content']?.toString().trim() ?? '';
    final source = json['source']?.toString().trim() ?? 'SiagaBencana';
    final publishedAt = DateTime.tryParse(
      json['published_at']?.toString() ?? '',
    );
    final rawFormatted = json['published_formatted']?.toString().trim();
    final status = (json['status']?.toString().trim() ?? 'published')
        .toLowerCase();
    final statusLabel =
        json['status_label']?.toString().trim() ??
        (status == 'published' ? 'Dipublikasikan' : 'Draf');
    final isFeatured =
        json['is_headline'] == true ||
        json['is_headline'] == 1 ||
        json['is_featured'] == true ||
        json['is_featured'] == 1;
    final rawAuthor = json['author_name']?.toString().trim();

    return NewsArticleItem(
      id: id,
      title: title,
      slug: slug,
      category: category,
      imageUrl: (rawImage == null || rawImage.isEmpty) ? null : rawImage,
      summary: summary,
      content: content,
      source: source,
      publishedAt: publishedAt,
      publishedFormatted: (rawFormatted != null && rawFormatted.isNotEmpty)
          ? rawFormatted
          : _fallbackFormatDate(publishedAt),
      status: status,
      statusLabel: statusLabel,
      isFeatured: isFeatured,
      authorName: (rawAuthor == null || rawAuthor.isEmpty) ? null : rawAuthor,
    );
  }

  final int id;
  final String title;
  final String slug;
  final String category;
  final String? imageUrl;
  final String summary;
  final String content;
  final String source;
  final DateTime? publishedAt;
  final String publishedFormatted;
  final String status;
  final String statusLabel;
  final bool isFeatured;
  final String? authorName;

  bool get isHeadline => isFeatured;

  bool get isPublished => status == 'published';

  static String _fallbackFormatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day $month ${local.year} • $hour:$minute WIB';
  }
}

class NewsDataException implements Exception {
  const NewsDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

