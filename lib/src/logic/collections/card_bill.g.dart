// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_bill.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCardBillCollection on Isar {
  IsarCollection<CardBill> get cardBills => this.collection();
}

const CardBillSchema = CollectionSchema(
  name: r'CardBill',
  id: 7821449647159063594,
  properties: {
    r'cardId': PropertySchema(
      id: 0,
      name: r'cardId',
      type: IsarType.long,
    ),
    r'confirmed': PropertySchema(
      id: 1,
      name: r'confirmed',
      type: IsarType.bool,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'installmentIdList': PropertySchema(
      id: 3,
      name: r'installmentIdList',
      type: IsarType.longList,
    ),
    r'minimal': PropertySchema(
      id: 4,
      name: r'minimal',
      type: IsarType.double,
    )
  },
  estimateSize: _cardBillEstimateSize,
  serialize: _cardBillSerialize,
  deserialize: _cardBillDeserialize,
  deserializeProp: _cardBillDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cardBillGetId,
  getLinks: _cardBillGetLinks,
  attach: _cardBillAttach,
  version: '3.1.0',
);

int _cardBillEstimateSize(
  CardBill object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.installmentIdList.length * 8;
  return bytesCount;
}

void _cardBillSerialize(
  CardBill object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cardId);
  writer.writeBool(offsets[1], object.confirmed);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeLongList(offsets[3], object.installmentIdList);
  writer.writeDouble(offsets[4], object.minimal);
}

CardBill _cardBillDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CardBill(
    cardId: reader.readLong(offsets[0]),
    confirmed: reader.readBoolOrNull(offsets[1]) ?? false,
    date: reader.readDateTime(offsets[2]),
    id: id,
    installmentIdList: reader.readLongList(offsets[3]) ?? [],
    minimal: reader.readDoubleOrNull(offsets[4]),
  );
  return object;
}

P _cardBillDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongList(offset) ?? []) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cardBillGetId(CardBill object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cardBillGetLinks(CardBill object) {
  return [];
}

void _cardBillAttach(IsarCollection<dynamic> col, Id id, CardBill object) {}

extension CardBillQueryWhereSort on QueryBuilder<CardBill, CardBill, QWhere> {
  QueryBuilder<CardBill, CardBill, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CardBillQueryWhere on QueryBuilder<CardBill, CardBill, QWhereClause> {
  QueryBuilder<CardBill, CardBill, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CardBillQueryFilter
    on QueryBuilder<CardBill, CardBill, QFilterCondition> {
  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> cardIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardId',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> cardIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardId',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> cardIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardId',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> cardIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> confirmedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmed',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installmentIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installmentIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installmentIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installmentIdList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'installmentIdList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'installmentIdList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'installmentIdList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'installmentIdList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'installmentIdList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition>
      installmentIdListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'installmentIdList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> minimalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'minimal',
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> minimalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'minimal',
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> minimalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minimal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> minimalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minimal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> minimalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minimal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterFilterCondition> minimalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minimal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension CardBillQueryObject
    on QueryBuilder<CardBill, CardBill, QFilterCondition> {}

extension CardBillQueryLinks
    on QueryBuilder<CardBill, CardBill, QFilterCondition> {}

extension CardBillQuerySortBy on QueryBuilder<CardBill, CardBill, QSortBy> {
  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByMinimal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimal', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> sortByMinimalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimal', Sort.desc);
    });
  }
}

extension CardBillQuerySortThenBy
    on QueryBuilder<CardBill, CardBill, QSortThenBy> {
  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByCardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardId', Sort.desc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByMinimal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimal', Sort.asc);
    });
  }

  QueryBuilder<CardBill, CardBill, QAfterSortBy> thenByMinimalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minimal', Sort.desc);
    });
  }
}

extension CardBillQueryWhereDistinct
    on QueryBuilder<CardBill, CardBill, QDistinct> {
  QueryBuilder<CardBill, CardBill, QDistinct> distinctByCardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardId');
    });
  }

  QueryBuilder<CardBill, CardBill, QDistinct> distinctByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmed');
    });
  }

  QueryBuilder<CardBill, CardBill, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<CardBill, CardBill, QDistinct> distinctByInstallmentIdList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installmentIdList');
    });
  }

  QueryBuilder<CardBill, CardBill, QDistinct> distinctByMinimal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minimal');
    });
  }
}

extension CardBillQueryProperty
    on QueryBuilder<CardBill, CardBill, QQueryProperty> {
  QueryBuilder<CardBill, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CardBill, int, QQueryOperations> cardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardId');
    });
  }

  QueryBuilder<CardBill, bool, QQueryOperations> confirmedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmed');
    });
  }

  QueryBuilder<CardBill, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<CardBill, List<int>, QQueryOperations>
      installmentIdListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentIdList');
    });
  }

  QueryBuilder<CardBill, double?, QQueryOperations> minimalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minimal');
    });
  }
}
