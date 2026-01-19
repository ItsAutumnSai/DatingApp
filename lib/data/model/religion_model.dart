class ReligionModel {
  static const Map<int, String> religions = {
    1: 'Agnostic',
    2: 'Atheist',
    3: 'Buddhist',
    4: 'Catholic',
    5: 'Christian',
    6: 'Hindu',
    7: 'Jewish',
    8: 'Muslim',
    9: 'Spiritual',
    10: 'Other',
  };

  static String getLabel(int? id) => religions[id] ?? '';
}
