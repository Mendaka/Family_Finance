class User {
  String id;
  String name;
  double totalIncome;
  double totalExpense;

  User({
    required this.id,
    required this.name,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
    };
  }

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      name: map['name'] ?? '',
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      totalExpense: (map['totalExpense'] ?? 0).toDouble(),
    );
  }
}
