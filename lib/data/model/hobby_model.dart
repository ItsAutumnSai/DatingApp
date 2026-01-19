class HobbyModel {
  static const Map<int, String> hobbies = {
    1: 'Photography',
    2: 'Cooking',
    3: 'Video Games',
    4: 'Music',
    5: 'Traveling',
    6: 'Reading',
    7: 'Fitness',
    8: 'Movies',
    9: 'Art',
    10: 'Hiking',
    11: 'Dancing',
    12: 'Writing',
    13: 'Coding',
    14: 'Animals',
    15: 'Fashion',
    16: 'Foodie',
    17: 'Sports',
    18: 'Technology',
    19: 'Nature',
    20: 'Cars',
  };

  static String getLabel(int? id) => hobbies[id] ?? '';
}
