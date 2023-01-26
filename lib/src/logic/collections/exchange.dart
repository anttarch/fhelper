import 'package:isar/isar.dart';

part 'exchange.g.dart';

enum EType { income, expense }

@Collection()
class Exchange {
  Exchange({
    this.id = Isar.autoIncrement,
    required this.account,
    this.cardId,
    required this.description,
    this.installments,
    this.installmentValue,
    required this.eType,
    required this.type,
    required this.value,
  });

  final Id id; // Isar id
  final String account; // Account linked
  final int? cardId; // Card linked
  final String description; // Name
  final int? installments; // Installments amount
  final double? installmentValue; // Value of each installment

  @enumerated
  final EType eType; // Exchange type
  final String type; // Type (category)
  final double value; // Monetary value
}
