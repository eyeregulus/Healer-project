// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConsultationCollection on Isar {
  IsarCollection<Consultation> get consultations => this.collection();
}

const ConsultationSchema = CollectionSchema(
  name: r'Consultation',
  id: 7048702844559806430,
  properties: {
    r'aiOpinion': PropertySchema(
      id: 0,
      name: r'aiOpinion',
      type: IsarType.string,
    ),
    r'clientId': PropertySchema(
      id: 1,
      name: r'clientId',
      type: IsarType.long,
    ),
    r'clientName': PropertySchema(
      id: 2,
      name: r'clientName',
      type: IsarType.string,
    ),
    r'complaint': PropertySchema(
      id: 3,
      name: r'complaint',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'finalTags': PropertySchema(
      id: 5,
      name: r'finalTags',
      type: IsarType.stringList,
    )
  },
  estimateSize: _consultationEstimateSize,
  serialize: _consultationSerialize,
  deserialize: _consultationDeserialize,
  deserializeProp: _consultationDeserializeProp,
  idName: r'id',
  indexes: {
    r'clientId': IndexSchema(
      id: 2639372232964765565,
      name: r'clientId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'clientId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'finalTags': IndexSchema(
      id: 1633948710017175928,
      name: r'finalTags',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'finalTags',
          type: IndexType.hashElements,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _consultationGetId,
  getLinks: _consultationGetLinks,
  attach: _consultationAttach,
  version: '3.1.0+1',
);

int _consultationEstimateSize(
  Consultation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aiOpinion.length * 3;
  bytesCount += 3 + object.clientName.length * 3;
  bytesCount += 3 + object.complaint.length * 3;
  bytesCount += 3 + object.finalTags.length * 3;
  {
    for (var i = 0; i < object.finalTags.length; i++) {
      final value = object.finalTags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _consultationSerialize(
  Consultation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiOpinion);
  writer.writeLong(offsets[1], object.clientId);
  writer.writeString(offsets[2], object.clientName);
  writer.writeString(offsets[3], object.complaint);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeStringList(offsets[5], object.finalTags);
}

Consultation _consultationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Consultation();
  object.aiOpinion = reader.readString(offsets[0]);
  object.clientId = reader.readLong(offsets[1]);
  object.clientName = reader.readString(offsets[2]);
  object.complaint = reader.readString(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.finalTags = reader.readStringList(offsets[5]) ?? [];
  object.id = id;
  return object;
}

P _consultationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _consultationGetId(Consultation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _consultationGetLinks(Consultation object) {
  return [];
}

void _consultationAttach(
    IsarCollection<dynamic> col, Id id, Consultation object) {
  object.id = id;
}

extension ConsultationQueryWhereSort
    on QueryBuilder<Consultation, Consultation, QWhere> {
  QueryBuilder<Consultation, Consultation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhere> anyClientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'clientId'),
      );
    });
  }
}

extension ConsultationQueryWhere
    on QueryBuilder<Consultation, Consultation, QWhereClause> {
  QueryBuilder<Consultation, Consultation, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<Consultation, Consultation, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause> idBetween(
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

  QueryBuilder<Consultation, Consultation, QAfterWhereClause> clientIdEqualTo(
      int clientId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'clientId',
        value: [clientId],
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause>
      clientIdNotEqualTo(int clientId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientId',
              lower: [],
              upper: [clientId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientId',
              lower: [clientId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientId',
              lower: [clientId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientId',
              lower: [],
              upper: [clientId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause>
      clientIdGreaterThan(
    int clientId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'clientId',
        lower: [clientId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause> clientIdLessThan(
    int clientId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'clientId',
        lower: [],
        upper: [clientId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause> clientIdBetween(
    int lowerClientId,
    int upperClientId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'clientId',
        lower: [lowerClientId],
        includeLower: includeLower,
        upper: [upperClientId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause>
      finalTagsElementEqualTo(String finalTagsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'finalTags',
        value: [finalTagsElement],
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterWhereClause>
      finalTagsElementNotEqualTo(String finalTagsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finalTags',
              lower: [],
              upper: [finalTagsElement],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finalTags',
              lower: [finalTagsElement],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finalTags',
              lower: [finalTagsElement],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'finalTags',
              lower: [],
              upper: [finalTagsElement],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ConsultationQueryFilter
    on QueryBuilder<Consultation, Consultation, QFilterCondition> {
  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiOpinion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiOpinion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiOpinion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiOpinion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiOpinion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiOpinion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiOpinion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiOpinion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiOpinion',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      aiOpinionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiOpinion',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientId',
        value: value,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clientId',
        value: value,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clientId',
        value: value,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clientId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clientName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clientName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientName',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      clientNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clientName',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'complaint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'complaint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'complaint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'complaint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'complaint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'complaint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'complaint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'complaint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'complaint',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      complaintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'complaint',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finalTags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'finalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'finalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'finalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'finalTags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finalTags',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'finalTags',
        value: '',
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'finalTags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'finalTags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'finalTags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'finalTags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'finalTags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition>
      finalTagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'finalTags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Consultation, Consultation, QAfterFilterCondition> idBetween(
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
}

extension ConsultationQueryObject
    on QueryBuilder<Consultation, Consultation, QFilterCondition> {}

extension ConsultationQueryLinks
    on QueryBuilder<Consultation, Consultation, QFilterCondition> {}

extension ConsultationQuerySortBy
    on QueryBuilder<Consultation, Consultation, QSortBy> {
  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByAiOpinion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiOpinion', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByAiOpinionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiOpinion', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByClientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientId', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByClientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientId', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByClientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy>
      sortByClientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByComplaint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complaint', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByComplaintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complaint', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }
}

extension ConsultationQuerySortThenBy
    on QueryBuilder<Consultation, Consultation, QSortThenBy> {
  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByAiOpinion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiOpinion', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByAiOpinionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiOpinion', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByClientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientId', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByClientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientId', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByClientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy>
      thenByClientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientName', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByComplaint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complaint', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByComplaintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'complaint', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Consultation, Consultation, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension ConsultationQueryWhereDistinct
    on QueryBuilder<Consultation, Consultation, QDistinct> {
  QueryBuilder<Consultation, Consultation, QDistinct> distinctByAiOpinion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiOpinion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Consultation, Consultation, QDistinct> distinctByClientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientId');
    });
  }

  QueryBuilder<Consultation, Consultation, QDistinct> distinctByClientName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Consultation, Consultation, QDistinct> distinctByComplaint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'complaint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Consultation, Consultation, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Consultation, Consultation, QDistinct> distinctByFinalTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finalTags');
    });
  }
}

extension ConsultationQueryProperty
    on QueryBuilder<Consultation, Consultation, QQueryProperty> {
  QueryBuilder<Consultation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Consultation, String, QQueryOperations> aiOpinionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiOpinion');
    });
  }

  QueryBuilder<Consultation, int, QQueryOperations> clientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientId');
    });
  }

  QueryBuilder<Consultation, String, QQueryOperations> clientNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientName');
    });
  }

  QueryBuilder<Consultation, String, QQueryOperations> complaintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'complaint');
    });
  }

  QueryBuilder<Consultation, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Consultation, List<String>, QQueryOperations>
      finalTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finalTags');
    });
  }
}
