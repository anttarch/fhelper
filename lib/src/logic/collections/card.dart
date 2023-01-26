import 'package:isar/isar.dart';
part 'card.g.dart';

@Collection()
class Card {
  Card({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.brand,
    required this.billingCycle,
    required this.paymentDue,
    required this.limit,
    required this.account,
  });

  final Id id; // Isar id
  final String name; // Name
  final String brand; // Brand of the card
  final int billingCycle; // Closure of statement day
  final int paymentDue; // Payment day
  final double limit; // Card limit
  final String account; // Account linked
}
