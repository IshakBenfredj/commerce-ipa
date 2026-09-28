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

  /// Official 69 Algerian Wilayas mapping (Arabic, French)
  static const Map<int, (String, String)> defaultWilayaNames = {
    1: ('أدرار', 'Adrar'),
    2: ('الشلف', 'Chlef'),
    3: ('الأغواط', 'Laghouat'),
    4: ('أم البواقي', 'Oum El Bouaghi'),
    5: ('باتنة', 'Batna'),
    6: ('بجاية', 'Béjaïa'),
    7: ('بسكرة', 'Biskra'),
    8: ('بشار', 'Béchar'),
    9: ('البليدة', 'Blida'),
    10: ('البويرة', 'Bouira'),
    11: ('تمنراست', 'Tamanrasset'),
    12: ('تبسة', 'Tébessa'),
    13: ('تلمسان', 'Tlemcen'),
    14: ('تيارت', 'Tiaret'),
    15: ('تيزي وزو', 'Tizi Ouzou'),
    16: ('الجزائر العاصمة', 'Alger'),
    17: ('الجلفة', 'Djelfa'),
    18: ('جيجل', 'Jijel'),
    19: ('سطيف', 'Sétif'),
    20: ('سعيدة', 'Saïda'),
    21: ('سكيكدة', 'Skikda'),
    22: ('سيدي بلعباس', 'Sidi Bel Abbès'),
    23: ('عنابة', 'Annaba'),
    24: ('قالمة', 'Guelma'),
    25: ('قسنطينة', 'Constantine'),
    26: ('المدية', 'Médéa'),
    27: ('مستغانم', 'Mostaganem'),
    28: ('المسيلة', 'M\'Sila'),
    29: ('معسكر', 'Mascara'),
    30: ('ورقلة', 'Ouargla'),
    31: ('وهران', 'Oran'),
    32: ('البيض', 'El Bayadh'),
    33: ('إليزي', 'Illizi'),
    34: ('برج بوعريريج', 'Bordj Bou Arréridj'),
    35: ('بومرداس', 'Boumerdès'),
    36: ('الطارف', 'El Tarf'),
    37: ('تندوف', 'Tindouf'),
    38: ('تسمسيلت', 'Tissemsilt'),
    39: ('الوادي', 'El Oued'),
    40: ('خنشلة', 'Khenchela'),
    41: ('سوق أهراس', 'Souk Ahras'),
    42: ('تيبازة', 'Tipaza'),
    43: ('ميلة', 'Mila'),
    44: ('عين الدفلى', 'Aïn Defla'),
    45: ('النعامة', 'Naâma'),
    46: ('عين تموشنت', 'Aïn Témouchent'),
    47: ('غرداية', 'Ghardaïa'),
    48: ('غليزان', 'Relizane'),
    49: ('تيميمون', 'Timimoun'),
    50: ('برج باجي مختار', 'Bordj Badji Mokhtar'),
    51: ('أولاد جلال', 'Ouled Djellal'),
    52: ('بني عباس', 'Béni Abbès'),
    53: ('عين صالح', 'In Salah'),
    54: ('عين قزام', 'In Guezzam'),
    55: ('تقرت', 'Touggourt'),
    56: ('جانت', 'Djanet'),
    57: ('المغير', 'El M\'Ghair'),
    58: ('المنيعة', 'El Meniaa'),
    59: ('العلمة', 'El Eulma'),
    60: ('بوسعادة', 'Bou Saâda'),
    61: ('سور الغزلان', 'Sour El Ghozlane'),
    62: ('قصر الشلالة', 'Ksar Chellala'),
    63: ('بريكة', 'Barika'),
    64: ('عين وسارة', 'Aïn Oussara'),
    65: ('مسعد', 'Messaad'),
    66: ('أفلو', 'Aflou'),
    67: ('مغنية', 'Maghnia'),
    68: ('الأربعاء نايث إيراثن', 'Larbaâ Nath Irathen'),
    69: ('الدبيلة', 'Debila'),
  };

  /// Clean display name that never shows empty parentheses
  String get displayName {
    if (nameFr.isNotEmpty && nameFr.toLowerCase() != nameAr.toLowerCase()) {
      return '$nameAr ($nameFr)';
    }
    return nameAr.isNotEmpty ? nameAr : 'ولاية $code';
  }

  factory WilayaTarif.fromJson(Map<String, dynamic> json) {
    int codeVal = 1;
    if (json['code'] != null) {
      codeVal = int.tryParse(json['code'].toString()) ?? 1;
    } else if (json['id'] != null) {
      codeVal = int.tryParse(json['id'].toString()) ?? 1;
    }

    final defaultPair = defaultWilayaNames[codeVal];
    final defaultAr = defaultPair?.$1 ?? 'ولاية $codeVal';
    final defaultFr = defaultPair?.$2 ?? 'Wilaya $codeVal';

    // 1. Resolve Arabic name
    String resolvedAr = '';
    if (json['name_ar'] != null && json['name_ar'].toString().trim().isNotEmpty) {
      resolvedAr = json['name_ar'].toString().trim();
    } else if (json['name'] != null && json['name'].toString().trim().isNotEmpty) {
      final nameStr = json['name'].toString().trim();
      if (nameStr.contains('-')) {
        resolvedAr = nameStr.split('-')[0].trim();
      } else {
        resolvedAr = nameStr;
      }
    }
    if (resolvedAr.isEmpty) {
      resolvedAr = defaultAr;
    }

    // 2. Resolve French name
    String resolvedFr = '';
    if (json['name_fr'] != null && json['name_fr'].toString().trim().isNotEmpty) {
      resolvedFr = json['name_fr'].toString().trim();
    } else if (json['name'] != null && json['name'].toString().trim().isNotEmpty) {
      final nameStr = json['name'].toString().trim();
      if (nameStr.contains('-')) {
        final parts = nameStr.split('-');
        if (parts.length > 1 && parts[1].trim().isNotEmpty) {
          resolvedFr = parts[1].trim();
        }
      }
    }
    if (resolvedFr.isEmpty) {
      resolvedFr = defaultFr;
    }

    // 3. Resolve prices
    double home = 700;
    if (json['tarif_domicile'] != null) {
      home = (json['tarif_domicile'] as num).toDouble();
    } else if (json['home'] != null) {
      home = (json['home'] as num).toDouble();
    }

    double desk = 400;
    if (json['tarif_bureau'] != null) {
      desk = (json['tarif_bureau'] as num).toDouble();
    } else if (json['desk'] != null) {
      desk = (json['desk'] as num).toDouble();
    }

    bool isActive = true;
    if (json['active'] != null) {
      isActive = json['active'] == true;
    }

    return WilayaTarif(
      code: codeVal,
      nameAr: resolvedAr,
      nameFr: resolvedFr,
      tarifDomicile: home,
      tarifBureau: desk,
      active: isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'id': code,
    'name': '$nameAr - $nameFr',
    'name_ar': nameAr,
    'name_fr': nameFr,
    'tarif_domicile': tarifDomicile,
    'tarif_bureau': tarifBureau,
    'home': tarifDomicile,
    'desk': tarifBureau,
    'active': active,
  };
}
