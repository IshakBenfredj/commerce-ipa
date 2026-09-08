class WilayaTarif {
  final int code;
  final String nameAr;
  final String nameFr;
  double tarifDomicile;
  double tarifBureau;
  bool active;

  WilayaTarif({
    required this.code,
    required this.nameAr,
    required this.nameFr,
    required this.tarifDomicile,
    required this.tarifBureau,
    this.active = true,
  });

  factory WilayaTarif.fromJson(Map<String, dynamic> json) {
    int codeVal = 1;
    if (json['code'] != null) {
      codeVal = int.tryParse(json['code'].toString()) ?? 1;
    }

    return WilayaTarif(
      code: codeVal,
      nameAr: json['name_ar'] ?? json['name'] ?? 'ولاية $codeVal',
      nameFr: json['name_fr'] ?? json['name'] ?? 'Wilaya $codeVal',
      tarifDomicile: (json['tarif_domicile'] ?? json['home'] ?? 700).toDouble(),
      tarifBureau: (json['tarif_bureau'] ?? json['desk'] ?? 400).toDouble(),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name_ar': nameAr,
    'name_fr': nameFr,
    'tarif_domicile': tarifDomicile,
    'tarif_bureau': tarifBureau,
    'active': active,
  };
}
