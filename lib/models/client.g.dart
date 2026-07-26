// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClientCollection on Isar {
  IsarCollection<Client> get clients => this.collection();
}

const ClientSchema = CollectionSchema(
  name: r'Client',
  id: 1578245643436550370,
  properties: {
    r'aiAnalysisResult': PropertySchema(
      id: 0,
      name: r'aiAnalysisResult',
      type: IsarType.string,
    ),
    r'aiMatchLevel': PropertySchema(
      id: 1,
      name: r'aiMatchLevel',
      type: IsarType.string,
    ),
    r'aspects': PropertySchema(
      id: 2,
      name: r'aspects',
      type: IsarType.stringList,
    ),
    r'birthDate': PropertySchema(
      id: 3,
      name: r'birthDate',
      type: IsarType.dateTime,
    ),
    r'birthPlace': PropertySchema(
      id: 4,
      name: r'birthPlace',
      type: IsarType.string,
    ),
    r'birthTime': PropertySchema(
      id: 5,
      name: r'birthTime',
      type: IsarType.string,
    ),
    r'clinicalObservation': PropertySchema(
      id: 6,
      name: r'clinicalObservation',
      type: IsarType.string,
    ),
    r'clinicalTags': PropertySchema(
      id: 7,
      name: r'clinicalTags',
      type: IsarType.stringList,
    ),
    r'latitude': PropertySchema(
      id: 8,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 9,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 10,
      name: r'name',
      type: IsarType.string,
    ),
    r'needsReview': PropertySchema(
      id: 11,
      name: r'needsReview',
      type: IsarType.bool,
    ),
    r'note': PropertySchema(
      id: 12,
      name: r'note',
      type: IsarType.string,
    ),
    r'placements': PropertySchema(
      id: 13,
      name: r'placements',
      type: IsarType.stringList,
    ),
    r'timezoneOffset': PropertySchema(
      id: 14,
      name: r'timezoneOffset',
      type: IsarType.double,
    )
  },
  estimateSize: _clientEstimateSize,
  serialize: _clientSerialize,
  deserialize: _clientDeserialize,
  deserializeProp: _clientDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _clientGetId,
  getLinks: _clientGetLinks,
  attach: _clientAttach,
  version: '3.1.0+1',
);

int _clientEstimateSize(
  Client object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aiAnalysisResult.length * 3;
  bytesCount += 3 + object.aiMatchLevel.length * 3;
  bytesCount += 3 + object.aspects.length * 3;
  {
    for (var i = 0; i < object.aspects.length; i++) {
      final value = object.aspects[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.birthPlace.length * 3;
  bytesCount += 3 + object.birthTime.length * 3;
  bytesCount += 3 + object.clinicalObservation.length * 3;
  bytesCount += 3 + object.clinicalTags.length * 3;
  {
    for (var i = 0; i < object.clinicalTags.length; i++) {
      final value = object.clinicalTags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.note.length * 3;
  bytesCount += 3 + object.placements.length * 3;
  {
    for (var i = 0; i < object.placements.length; i++) {
      final value = object.placements[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _clientSerialize(
  Client object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiAnalysisResult);
  writer.writeString(offsets[1], object.aiMatchLevel);
  writer.writeStringList(offsets[2], object.aspects);
  writer.writeDateTime(offsets[3], object.birthDate);
  writer.writeString(offsets[4], object.birthPlace);
  writer.writeString(offsets[5], object.birthTime);
  writer.writeString(offsets[6], object.clinicalObservation);
  writer.writeStringList(offsets[7], object.clinicalTags);
  writer.writeDouble(offsets[8], object.latitude);
  writer.writeDouble(offsets[9], object.longitude);
  writer.writeString(offsets[10], object.name);
  writer.writeBool(offsets[11], object.needsReview);
  writer.writeString(offsets[12], object.note);
  writer.writeStringList(offsets[13], object.placements);
  writer.writeDouble(offsets[14], object.timezoneOffset);
}

Client _clientDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Client();
  object.aiAnalysisResult = reader.readString(offsets[0]);
  object.aiMatchLevel = reader.readString(offsets[1]);
  object.aspects = reader.readStringList(offsets[2]) ?? [];
  object.birthDate = reader.readDateTime(offsets[3]);
  object.birthPlace = reader.readString(offsets[4]);
  object.birthTime = reader.readString(offsets[5]);
  object.clinicalObservation = reader.readString(offsets[6]);
  object.clinicalTags = reader.readStringList(offsets[7]) ?? [];
  object.id = id;
  object.latitude = reader.readDouble(offsets[8]);
  object.longitude = reader.readDouble(offsets[9]);
  object.name = reader.readString(offsets[10]);
  object.needsReview = reader.readBool(offsets[11]);
  object.note = reader.readString(offsets[12]);
  object.placements = reader.readStringList(offsets[13]) ?? [];
  object.timezoneOffset = reader.readDouble(offsets[14]);
  return object;
}

P _clientDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringList(offset) ?? []) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _clientGetId(Client object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _clientGetLinks(Client object) {
  return [];
}

void _clientAttach(IsarCollection<dynamic> col, Id id, Client object) {
  object.id = id;
}

extension ClientQueryWhereSort on QueryBuilder<Client, Client, QWhere> {
  QueryBuilder<Client, Client, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Client, Client, QAfterWhere> anyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'name'),
      );
    });
  }
}

extension ClientQueryWhere on QueryBuilder<Client, Client, QWhereClause> {
  QueryBuilder<Client, Client, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Client, Client, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> idBetween(
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

  QueryBuilder<Client, Client, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> nameGreaterThan(
    String name, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [name],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> nameLessThan(
    String name, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [],
        upper: [name],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> nameBetween(
    String lowerName,
    String upperName, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [lowerName],
        includeLower: includeLower,
        upper: [upperName],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> nameStartsWith(
      String NamePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [NamePrefix],
        upper: ['$NamePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [''],
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterWhereClause> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name',
              upper: [''],
            ));
      }
    });
  }
}

extension ClientQueryFilter on QueryBuilder<Client, Client, QFilterCondition> {
  QueryBuilder<Client, Client, QAfterFilterCondition> aiAnalysisResultEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiAnalysisResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      aiAnalysisResultGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiAnalysisResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiAnalysisResultLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiAnalysisResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiAnalysisResultBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiAnalysisResult',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      aiAnalysisResultStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiAnalysisResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiAnalysisResultEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiAnalysisResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiAnalysisResultContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiAnalysisResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiAnalysisResultMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiAnalysisResult',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      aiAnalysisResultIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiAnalysisResult',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      aiAnalysisResultIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiAnalysisResult',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiMatchLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiMatchLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiMatchLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiMatchLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiMatchLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiMatchLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiMatchLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiMatchLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiMatchLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aiMatchLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiMatchLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aspects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aspects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aspects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aspects',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aspects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aspects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aspects',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aspects',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aspects',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      aspectsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aspects',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aspects',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aspects',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aspects',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aspects',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aspects',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> aspectsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aspects',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'birthDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthPlace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'birthPlace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'birthPlace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'birthPlace',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'birthPlace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'birthPlace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'birthPlace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'birthPlace',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthPlace',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthPlaceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'birthPlace',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'birthTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'birthTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'birthTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'birthTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'birthTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'birthTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'birthTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthTime',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> birthTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'birthTime',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clinicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clinicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clinicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clinicalObservation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clinicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clinicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clinicalObservation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clinicalObservation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clinicalObservation',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalObservationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clinicalObservation',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clinicalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clinicalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clinicalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clinicalTags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clinicalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clinicalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clinicalTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clinicalTags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clinicalTags',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clinicalTags',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> clinicalTagsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clinicalTags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> clinicalTagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clinicalTags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> clinicalTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clinicalTags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clinicalTags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      clinicalTagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clinicalTags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> clinicalTagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clinicalTags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Client, Client, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Client, Client, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Client, Client, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> needsReviewEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'placements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      placementsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'placements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'placements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'placements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      placementsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'placements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'placements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'placements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'placements',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      placementsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'placements',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      placementsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'placements',
        value: '',
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'placements',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'placements',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'placements',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'placements',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition>
      placementsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'placements',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> placementsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'placements',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> timezoneOffsetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timezoneOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> timezoneOffsetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timezoneOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> timezoneOffsetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timezoneOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Client, Client, QAfterFilterCondition> timezoneOffsetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timezoneOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ClientQueryObject on QueryBuilder<Client, Client, QFilterCondition> {}

extension ClientQueryLinks on QueryBuilder<Client, Client, QFilterCondition> {}

extension ClientQuerySortBy on QueryBuilder<Client, Client, QSortBy> {
  QueryBuilder<Client, Client, QAfterSortBy> sortByAiAnalysisResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysisResult', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByAiAnalysisResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysisResult', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByAiMatchLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiMatchLevel', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByAiMatchLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiMatchLevel', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByBirthDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByBirthPlace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthPlace', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByBirthPlaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthPlace', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByBirthTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthTime', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByBirthTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthTime', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByClinicalObservation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalObservation', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByClinicalObservationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalObservation', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByTimezoneOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezoneOffset', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> sortByTimezoneOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezoneOffset', Sort.desc);
    });
  }
}

extension ClientQuerySortThenBy on QueryBuilder<Client, Client, QSortThenBy> {
  QueryBuilder<Client, Client, QAfterSortBy> thenByAiAnalysisResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysisResult', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByAiAnalysisResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysisResult', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByAiMatchLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiMatchLevel', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByAiMatchLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiMatchLevel', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByBirthDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByBirthPlace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthPlace', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByBirthPlaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthPlace', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByBirthTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthTime', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByBirthTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthTime', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByClinicalObservation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalObservation', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByClinicalObservationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clinicalObservation', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByTimezoneOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezoneOffset', Sort.asc);
    });
  }

  QueryBuilder<Client, Client, QAfterSortBy> thenByTimezoneOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezoneOffset', Sort.desc);
    });
  }
}

extension ClientQueryWhereDistinct on QueryBuilder<Client, Client, QDistinct> {
  QueryBuilder<Client, Client, QDistinct> distinctByAiAnalysisResult(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiAnalysisResult',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByAiMatchLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiMatchLevel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByAspects() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aspects');
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'birthDate');
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByBirthPlace(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'birthPlace', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByBirthTime(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'birthTime', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByClinicalObservation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clinicalObservation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByClinicalTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clinicalTags');
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsReview');
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByPlacements() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'placements');
    });
  }

  QueryBuilder<Client, Client, QDistinct> distinctByTimezoneOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timezoneOffset');
    });
  }
}

extension ClientQueryProperty on QueryBuilder<Client, Client, QQueryProperty> {
  QueryBuilder<Client, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Client, String, QQueryOperations> aiAnalysisResultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiAnalysisResult');
    });
  }

  QueryBuilder<Client, String, QQueryOperations> aiMatchLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiMatchLevel');
    });
  }

  QueryBuilder<Client, List<String>, QQueryOperations> aspectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aspects');
    });
  }

  QueryBuilder<Client, DateTime, QQueryOperations> birthDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'birthDate');
    });
  }

  QueryBuilder<Client, String, QQueryOperations> birthPlaceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'birthPlace');
    });
  }

  QueryBuilder<Client, String, QQueryOperations> birthTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'birthTime');
    });
  }

  QueryBuilder<Client, String, QQueryOperations> clinicalObservationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clinicalObservation');
    });
  }

  QueryBuilder<Client, List<String>, QQueryOperations> clinicalTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clinicalTags');
    });
  }

  QueryBuilder<Client, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<Client, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<Client, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Client, bool, QQueryOperations> needsReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsReview');
    });
  }

  QueryBuilder<Client, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<Client, List<String>, QQueryOperations> placementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'placements');
    });
  }

  QueryBuilder<Client, double, QQueryOperations> timezoneOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timezoneOffset');
    });
  }
}
