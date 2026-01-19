class RelationshipInterestModel {
  static const Map<int, String> interests = {
    1: 'Committed relationship',
    2: 'Fun dates',
    3: 'Figuring it out',
  };

  static String getLabel(int? id) => interests[id] ?? 'Unknown';
}
