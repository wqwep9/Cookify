class Ingredient {
  final int id;
  final String name;
  final double amount;
  final String unit;
  final String? image;

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'image': image,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      unit: map['unit'],
      image: map['image'],
    );
  }
} 