import 'package:isar/isar.dart';

part 'card.g.dart';

@Collection()
class Card {
  Card({
    required this.name,
    required this.statementClosure,
    required this.paymentDue,
    required this.limit,
    this.id = Isar.autoIncrement,
  });

  final Id id; // Isar id
  final String name; // Name
  final int statementClosure; // Closure of statement day
  final int paymentDue; // Payment day
  final double limit; // Card limit

  Card copyWith({
    Id? id,
    String? name,
    int? statementClosure,
    int? paymentDue,
    double? limit,
  }) {
    return Card(
      id: id ?? this.id,
      name: name ?? this.name,
      statementClosure: statementClosure ?? this.statementClosure,
      paymentDue: paymentDue ?? this.paymentDue,
      limit: limit ?? this.limit,
    );
  }
}

Future<List<Card>> getCards(Isar isar) async {
  final cards = await isar.cards.where().findAll();
  return cards;
}

Future<Card?> getCardFromId(Isar isar, int? id) async {
  if (id != null) {
    final card = await isar.cards.get(id);
    return card;
  }
  return null;
}
