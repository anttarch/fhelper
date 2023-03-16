import 'package:isar/isar.dart';

part 'card.g.dart';

@Collection()
class Card {
  Card({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.statementClosure,
    required this.paymentDue,
    required this.limit,
    required this.accountId,
  });

  final Id id; // Isar id
  final String name; // Name
  // final String brand; Brand of the card (being removed)
  final int statementClosure; // Closure of statement day
  final int paymentDue; // Payment day
  final double limit; // Card limit
  final int accountId; // Account linked

  Card copyWith({
    Id? id,
    String? name,
    int? statementClosure,
    int? paymentDue,
    double? limit,
    int? accountId,
  }) {
    return Card(
      id: id ?? this.id,
      name: name ?? this.name,
      statementClosure: statementClosure ?? this.statementClosure,
      paymentDue: paymentDue ?? this.paymentDue,
      limit: limit ?? this.limit,
      accountId: accountId ?? this.accountId,
    );
  }
}

Future<List<Card>> getCards(Isar isar) async {
  final List<Card> cards = await isar.cards.where().findAll();
  return cards;
}

Future<Card?> getCardFromId(Isar isar, int? id) async {
  if (id != null) {
    final Card? card = await isar.cards.get(id);
    return card;
  }
  return null;
}
