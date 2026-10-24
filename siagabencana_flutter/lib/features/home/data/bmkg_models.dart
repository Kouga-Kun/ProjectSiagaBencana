enum AlertCoverage {
  kotaPadang,
  sumbarLainnya,
  provinsiLain,
  tidakDiketahui;

  static AlertCoverage parse(Object? value) => switch (value) {
    'kota_padang' => AlertCoverage.kotaPadang,
    'sumbar_lainnya' => AlertCoverage.sumbarLainnya,
    'provinsi_lain' => AlertCoverage.provinsiLain,
    'tidak_diketahui' => AlertCoverage.tidakDiketahui,
    _ => AlertCoverage.tidakDiketahui,
  };

  String get label => switch (this) {
    AlertCoverage.kotaPadang => 'Kota Padang',
    AlertCoverage.sumbarLainnya => 'Sumatera Barat di luar Kota Padang',
    AlertCoverage.provinsiLain => 'Provinsi lain',
    AlertCoverage.tidakDiketahui => 'Cakupan belum dipastikan',
  };
}

class BmkgAlert {
  const BmkgAlert({
    required this.title,
    required this.description,
    required this.publishedFormatted,
    required this.link,
    required this.coverage,
    required this.isSpecificToPadang,
  });

  factory BmkgAlert.fromJson(Map<String, dynamic> json) {
    String readString(String key) {
      final value = json[key];
      if (value == null) return '';
      if (value is! String) {
        throw FormatException('Field $key pada peringatan BMKG harus teks.');
      }
      return value;
    }

    return BmkgAlert(
      title: readString('title'),
      description: readString('description'),
      publishedFormatted: readString('published_formatted'),
      link: readString('link'),
      coverage: AlertCoverage.parse(json['coverage']),
      isSpecificToPadang: json['is_specific_to_padang'] == true,
    );
  }

  final String title;
  final String description;
  final String publishedFormatted;
  final String link;
  final AlertCoverage coverage;
  final bool isSpecificToPadang;

  Uri? get officialLink {
    final uri = Uri.tryParse(link);
    final host = uri?.host.toLowerCase() ?? '';
    final isBmkgHost = host == 'bmkg.go.id' || host.endsWith('.bmkg.go.id');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        !isBmkgHost) {
      return null;
    }
    return uri;
  }
}

class BmkgAlertResponse {
  const BmkgAlertResponse({
    required this.source,
    required this.checkedAt,
    required this.alerts,
  });

  factory BmkgAlertResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] != true) {
      throw const FormatException('Backend tidak mengembalikan data BMKG.');
    }
    final rawAlerts = json['alerts'];
    if (rawAlerts is! List) {
      throw const FormatException(
        'Field alerts pada respons BMKG tidak valid.',
      );
    }

    final rawSource = json['source'];
    final rawCheckedAt = json['checked_at'];
    if (rawSource != null && rawSource is! String) {
      throw const FormatException(
        'Field source pada respons BMKG tidak valid.',
      );
    }
    if (rawCheckedAt != null && rawCheckedAt is! String) {
      throw const FormatException(
        'Field checked_at pada respons BMKG tidak valid.',
      );
    }

    return BmkgAlertResponse(
      source: rawSource as String? ?? 'BMKG',
      checkedAt: DateTime.tryParse(rawCheckedAt as String? ?? ''),
      alerts: rawAlerts
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Item peringatan BMKG tidak valid.');
            }
            return BmkgAlert.fromJson(item);
          })
          .toList(growable: false),
    );
  }

  final String source;
  final DateTime? checkedAt;
  final List<BmkgAlert> alerts;
}
