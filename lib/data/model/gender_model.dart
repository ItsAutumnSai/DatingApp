class GenderModel {
  static const Map<int, String> genders = {1: 'Male', 2: 'Female', 3: 'Other'};

  static String getLabel(int? id) => genders[id] ?? 'Unknown';
}
