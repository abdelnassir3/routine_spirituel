// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_collections.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContentDocCollection on Isar {
  IsarCollection<ContentDoc> get contentDocs => this.collection();
}

const ContentDocSchema = CollectionSchema(
  name: r'ContentDoc',
  id: 499403715871065180,
  properties: {
    r'body': PropertySchema(
      id: 0,
      name: r'body',
      type: IsarType.string,
    ),
    r'correctedBody': PropertySchema(
      id: 1,
      name: r'correctedBody',
      type: IsarType.string,
    ),
    r'diacritizedBody': PropertySchema(
      id: 2,
      name: r'diacritizedBody',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 3,
      name: r'kind',
      type: IsarType.string,
    ),
    r'locale': PropertySchema(
      id: 4,
      name: r'locale',
      type: IsarType.string,
    ),
    r'rawBody': PropertySchema(
      id: 5,
      name: r'rawBody',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 6,
      name: r'source',
      type: IsarType.string,
    ),
    r'taskId': PropertySchema(
      id: 7,
      name: r'taskId',
      type: IsarType.string,
    ),
    r'taskLocale': PropertySchema(
      id: 8,
      name: r'taskLocale',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 9,
      name: r'title',
      type: IsarType.string,
    ),
    r'validated': PropertySchema(
      id: 10,
      name: r'validated',
      type: IsarType.bool,
    )
  },
  estimateSize: _contentDocEstimateSize,
  serialize: _contentDocSerialize,
  deserialize: _contentDocDeserialize,
  deserializeProp: _contentDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'taskLocale_locale': IndexSchema(
      id: 2717473081959043035,
      name: r'taskLocale_locale',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskLocale',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'locale',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _contentDocGetId,
  getLinks: _contentDocGetLinks,
  attach: _contentDocAttach,
  version: '3.1.0+1',
);

int _contentDocEstimateSize(
  ContentDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.body;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.correctedBody;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.diacritizedBody;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.locale.length * 3;
  {
    final value = object.rawBody;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.source;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.taskId.length * 3;
  bytesCount += 3 + object.taskLocale.length * 3;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _contentDocSerialize(
  ContentDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.body);
  writer.writeString(offsets[1], object.correctedBody);
  writer.writeString(offsets[2], object.diacritizedBody);
  writer.writeString(offsets[3], object.kind);
  writer.writeString(offsets[4], object.locale);
  writer.writeString(offsets[5], object.rawBody);
  writer.writeString(offsets[6], object.source);
  writer.writeString(offsets[7], object.taskId);
  writer.writeString(offsets[8], object.taskLocale);
  writer.writeString(offsets[9], object.title);
  writer.writeBool(offsets[10], object.validated);
}

ContentDoc _contentDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContentDoc();
  object.body = reader.readStringOrNull(offsets[0]);
  object.correctedBody = reader.readStringOrNull(offsets[1]);
  object.diacritizedBody = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.kind = reader.readString(offsets[3]);
  object.locale = reader.readString(offsets[4]);
  object.rawBody = reader.readStringOrNull(offsets[5]);
  object.source = reader.readStringOrNull(offsets[6]);
  object.taskId = reader.readString(offsets[7]);
  object.title = reader.readStringOrNull(offsets[9]);
  object.validated = reader.readBool(offsets[10]);
  return object;
}

P _contentDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _contentDocGetId(ContentDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contentDocGetLinks(ContentDoc object) {
  return [];
}

void _contentDocAttach(IsarCollection<dynamic> col, Id id, ContentDoc object) {
  object.id = id;
}

extension ContentDocQueryWhereSort
    on QueryBuilder<ContentDoc, ContentDoc, QWhere> {
  QueryBuilder<ContentDoc, ContentDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ContentDocQueryWhere
    on QueryBuilder<ContentDoc, ContentDoc, QWhereClause> {
  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause> idBetween(
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

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause>
      taskLocaleEqualToAnyLocale(String taskLocale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskLocale_locale',
        value: [taskLocale],
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause>
      taskLocaleNotEqualToAnyLocale(String taskLocale) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [],
              upper: [taskLocale],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [taskLocale],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [taskLocale],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [],
              upper: [taskLocale],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause>
      taskLocaleLocaleEqualTo(String taskLocale, String locale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskLocale_locale',
        value: [taskLocale, locale],
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterWhereClause>
      taskLocaleEqualToLocaleNotEqualTo(String taskLocale, String locale) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [taskLocale],
              upper: [taskLocale, locale],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [taskLocale, locale],
              includeLower: false,
              upper: [taskLocale],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [taskLocale, locale],
              includeLower: false,
              upper: [taskLocale],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskLocale_locale',
              lower: [taskLocale],
              upper: [taskLocale, locale],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ContentDocQueryFilter
    on QueryBuilder<ContentDoc, ContentDoc, QFilterCondition> {
  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'body',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'body',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'body',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'body',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correctedBody',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correctedBody',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctedBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'correctedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'correctedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correctedBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedBody',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      correctedBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctedBody',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'diacritizedBody',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'diacritizedBody',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diacritizedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diacritizedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diacritizedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diacritizedBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'diacritizedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'diacritizedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'diacritizedBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'diacritizedBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diacritizedBody',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      diacritizedBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'diacritizedBody',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rawBody',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      rawBodyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rawBody',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      rawBodyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> rawBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawBody',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      rawBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawBody',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      sourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskLocaleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskLocaleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskLocaleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskLocaleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskLocale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskLocaleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskLocaleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskLocaleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskLocale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> taskLocaleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskLocale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskLocaleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskLocale',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      taskLocaleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskLocale',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterFilterCondition> validatedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'validated',
        value: value,
      ));
    });
  }
}

extension ContentDocQueryObject
    on QueryBuilder<ContentDoc, ContentDoc, QFilterCondition> {}

extension ContentDocQueryLinks
    on QueryBuilder<ContentDoc, ContentDoc, QFilterCondition> {}

extension ContentDocQuerySortBy
    on QueryBuilder<ContentDoc, ContentDoc, QSortBy> {
  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByCorrectedBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedBody', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByCorrectedBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedBody', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByDiacritizedBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diacritizedBody', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy>
      sortByDiacritizedBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diacritizedBody', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByRawBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawBody', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByRawBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawBody', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByTaskLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskLocale', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByTaskLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskLocale', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByValidated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validated', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> sortByValidatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validated', Sort.desc);
    });
  }
}

extension ContentDocQuerySortThenBy
    on QueryBuilder<ContentDoc, ContentDoc, QSortThenBy> {
  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByCorrectedBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedBody', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByCorrectedBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedBody', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByDiacritizedBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diacritizedBody', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy>
      thenByDiacritizedBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diacritizedBody', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByRawBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawBody', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByRawBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawBody', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByTaskLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskLocale', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByTaskLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskLocale', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByValidated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validated', Sort.asc);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QAfterSortBy> thenByValidatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validated', Sort.desc);
    });
  }
}

extension ContentDocQueryWhereDistinct
    on QueryBuilder<ContentDoc, ContentDoc, QDistinct> {
  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByCorrectedBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctedBody',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByDiacritizedBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diacritizedBody',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByKind(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByLocale(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByRawBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawBody', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByTaskId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByTaskLocale(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskLocale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentDoc, ContentDoc, QDistinct> distinctByValidated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validated');
    });
  }
}

extension ContentDocQueryProperty
    on QueryBuilder<ContentDoc, ContentDoc, QQueryProperty> {
  QueryBuilder<ContentDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContentDoc, String?, QQueryOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<ContentDoc, String?, QQueryOperations> correctedBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctedBody');
    });
  }

  QueryBuilder<ContentDoc, String?, QQueryOperations>
      diacritizedBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diacritizedBody');
    });
  }

  QueryBuilder<ContentDoc, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<ContentDoc, String, QQueryOperations> localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<ContentDoc, String?, QQueryOperations> rawBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawBody');
    });
  }

  QueryBuilder<ContentDoc, String?, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<ContentDoc, String, QQueryOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }

  QueryBuilder<ContentDoc, String, QQueryOperations> taskLocaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskLocale');
    });
  }

  QueryBuilder<ContentDoc, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ContentDoc, bool, QQueryOperations> validatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validated');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVerseDocCollection on Isar {
  IsarCollection<VerseDoc> get verseDocs => this.collection();
}

const VerseDocSchema = CollectionSchema(
  name: r'VerseDoc',
  id: 846191029309258258,
  properties: {
    r'ayah': PropertySchema(
      id: 0,
      name: r'ayah',
      type: IsarType.long,
    ),
    r'surah': PropertySchema(
      id: 1,
      name: r'surah',
      type: IsarType.long,
    ),
    r'surahAyah': PropertySchema(
      id: 2,
      name: r'surahAyah',
      type: IsarType.long,
    ),
    r'textAr': PropertySchema(
      id: 3,
      name: r'textAr',
      type: IsarType.string,
    ),
    r'textFr': PropertySchema(
      id: 4,
      name: r'textFr',
      type: IsarType.string,
    )
  },
  estimateSize: _verseDocEstimateSize,
  serialize: _verseDocSerialize,
  deserialize: _verseDocDeserialize,
  deserializeProp: _verseDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'surahAyah_ayah': IndexSchema(
      id: -153484365502118240,
      name: r'surahAyah_ayah',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'surahAyah',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'ayah',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _verseDocGetId,
  getLinks: _verseDocGetLinks,
  attach: _verseDocAttach,
  version: '3.1.0+1',
);

int _verseDocEstimateSize(
  VerseDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.textAr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.textFr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _verseDocSerialize(
  VerseDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.ayah);
  writer.writeLong(offsets[1], object.surah);
  writer.writeLong(offsets[2], object.surahAyah);
  writer.writeString(offsets[3], object.textAr);
  writer.writeString(offsets[4], object.textFr);
}

VerseDoc _verseDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VerseDoc();
  object.ayah = reader.readLong(offsets[0]);
  object.id = id;
  object.surah = reader.readLong(offsets[1]);
  object.textAr = reader.readStringOrNull(offsets[3]);
  object.textFr = reader.readStringOrNull(offsets[4]);
  return object;
}

P _verseDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _verseDocGetId(VerseDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _verseDocGetLinks(VerseDoc object) {
  return [];
}

void _verseDocAttach(IsarCollection<dynamic> col, Id id, VerseDoc object) {
  object.id = id;
}

extension VerseDocQueryWhereSort on QueryBuilder<VerseDoc, VerseDoc, QWhere> {
  QueryBuilder<VerseDoc, VerseDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhere> anySurahAyahAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'surahAyah_ayah'),
      );
    });
  }
}

extension VerseDocQueryWhere on QueryBuilder<VerseDoc, VerseDoc, QWhereClause> {
  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> idBetween(
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

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> surahAyahEqualToAnyAyah(
      int surahAyah) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'surahAyah_ayah',
        value: [surahAyah],
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause>
      surahAyahNotEqualToAnyAyah(int surahAyah) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [],
              upper: [surahAyah],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [surahAyah],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [surahAyah],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [],
              upper: [surahAyah],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause>
      surahAyahGreaterThanAnyAyah(
    int surahAyah, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahAyah_ayah',
        lower: [surahAyah],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> surahAyahLessThanAnyAyah(
    int surahAyah, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahAyah_ayah',
        lower: [],
        upper: [surahAyah],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> surahAyahBetweenAnyAyah(
    int lowerSurahAyah,
    int upperSurahAyah, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahAyah_ayah',
        lower: [lowerSurahAyah],
        includeLower: includeLower,
        upper: [upperSurahAyah],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause> surahAyahAyahEqualTo(
      int surahAyah, int ayah) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'surahAyah_ayah',
        value: [surahAyah, ayah],
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause>
      surahAyahEqualToAyahNotEqualTo(int surahAyah, int ayah) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [surahAyah],
              upper: [surahAyah, ayah],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [surahAyah, ayah],
              includeLower: false,
              upper: [surahAyah],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [surahAyah, ayah],
              includeLower: false,
              upper: [surahAyah],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'surahAyah_ayah',
              lower: [surahAyah],
              upper: [surahAyah, ayah],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause>
      surahAyahEqualToAyahGreaterThan(
    int surahAyah,
    int ayah, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahAyah_ayah',
        lower: [surahAyah, ayah],
        includeLower: include,
        upper: [surahAyah],
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause>
      surahAyahEqualToAyahLessThan(
    int surahAyah,
    int ayah, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahAyah_ayah',
        lower: [surahAyah],
        upper: [surahAyah, ayah],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterWhereClause>
      surahAyahEqualToAyahBetween(
    int surahAyah,
    int lowerAyah,
    int upperAyah, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'surahAyah_ayah',
        lower: [surahAyah, lowerAyah],
        includeLower: includeLower,
        upper: [surahAyah, upperAyah],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension VerseDocQueryFilter
    on QueryBuilder<VerseDoc, VerseDoc, QFilterCondition> {
  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> ayahEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ayah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> ayahGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ayah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> ayahLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ayah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> ayahBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ayah',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surah',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahAyahEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surahAyah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahAyahGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surahAyah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahAyahLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surahAyah',
        value: value,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> surahAyahBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surahAyah',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'textAr',
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'textAr',
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textAr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textAr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textAr',
        value: '',
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textArIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textAr',
        value: '',
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'textFr',
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'textFr',
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textFr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textFr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textFr',
        value: '',
      ));
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterFilterCondition> textFrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textFr',
        value: '',
      ));
    });
  }
}

extension VerseDocQueryObject
    on QueryBuilder<VerseDoc, VerseDoc, QFilterCondition> {}

extension VerseDocQueryLinks
    on QueryBuilder<VerseDoc, VerseDoc, QFilterCondition> {}

extension VerseDocQuerySortBy on QueryBuilder<VerseDoc, VerseDoc, QSortBy> {
  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortByAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayah', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortByAyahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayah', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortBySurah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surah', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortBySurahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surah', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortBySurahAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahAyah', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortBySurahAyahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahAyah', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortByTextAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortByTextArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortByTextFr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> sortByTextFrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.desc);
    });
  }
}

extension VerseDocQuerySortThenBy
    on QueryBuilder<VerseDoc, VerseDoc, QSortThenBy> {
  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenByAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayah', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenByAyahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayah', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenBySurah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surah', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenBySurahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surah', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenBySurahAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahAyah', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenBySurahAyahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahAyah', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenByTextAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenByTextArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.desc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenByTextFr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.asc);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QAfterSortBy> thenByTextFrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.desc);
    });
  }
}

extension VerseDocQueryWhereDistinct
    on QueryBuilder<VerseDoc, VerseDoc, QDistinct> {
  QueryBuilder<VerseDoc, VerseDoc, QDistinct> distinctByAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ayah');
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QDistinct> distinctBySurah() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surah');
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QDistinct> distinctBySurahAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surahAyah');
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QDistinct> distinctByTextAr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textAr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerseDoc, VerseDoc, QDistinct> distinctByTextFr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textFr', caseSensitive: caseSensitive);
    });
  }
}

extension VerseDocQueryProperty
    on QueryBuilder<VerseDoc, VerseDoc, QQueryProperty> {
  QueryBuilder<VerseDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VerseDoc, int, QQueryOperations> ayahProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ayah');
    });
  }

  QueryBuilder<VerseDoc, int, QQueryOperations> surahProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surah');
    });
  }

  QueryBuilder<VerseDoc, int, QQueryOperations> surahAyahProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surahAyah');
    });
  }

  QueryBuilder<VerseDoc, String?, QQueryOperations> textArProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textAr');
    });
  }

  QueryBuilder<VerseDoc, String?, QQueryOperations> textFrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textFr');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskContentCollection on Isar {
  IsarCollection<TaskContent> get taskContents => this.collection();
}

const TaskContentSchema = CollectionSchema(
  name: r'TaskContent',
  id: -6872450083196725702,
  properties: {
    r'ayahEnd': PropertySchema(
      id: 0,
      name: r'ayahEnd',
      type: IsarType.long,
    ),
    r'ayahStart': PropertySchema(
      id: 1,
      name: r'ayahStart',
      type: IsarType.long,
    ),
    r'category': PropertySchema(
      id: 2,
      name: r'category',
      type: IsarType.string,
    ),
    r'defaultRepetitions': PropertySchema(
      id: 3,
      name: r'defaultRepetitions',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.string,
    ),
    r'nameAr': PropertySchema(
      id: 5,
      name: r'nameAr',
      type: IsarType.string,
    ),
    r'nameFr': PropertySchema(
      id: 6,
      name: r'nameFr',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 7,
      name: r'notes',
      type: IsarType.string,
    ),
    r'surahNumber': PropertySchema(
      id: 8,
      name: r'surahNumber',
      type: IsarType.long,
    ),
    r'taskId': PropertySchema(
      id: 9,
      name: r'taskId',
      type: IsarType.string,
    ),
    r'textAr': PropertySchema(
      id: 10,
      name: r'textAr',
      type: IsarType.string,
    ),
    r'textFr': PropertySchema(
      id: 11,
      name: r'textFr',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 12,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _taskContentEstimateSize,
  serialize: _taskContentSerialize,
  deserialize: _taskContentDeserialize,
  deserializeProp: _taskContentDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'taskId': IndexSchema(
      id: -6391211041487498726,
      name: r'taskId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _taskContentGetId,
  getLinks: _taskContentGetLinks,
  attach: _taskContentAttach,
  version: '3.1.0+1',
);

int _taskContentEstimateSize(
  TaskContent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.category;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.nameAr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nameFr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.taskId.length * 3;
  {
    final value = object.textAr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.textFr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _taskContentSerialize(
  TaskContent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.ayahEnd);
  writer.writeLong(offsets[1], object.ayahStart);
  writer.writeString(offsets[2], object.category);
  writer.writeLong(offsets[3], object.defaultRepetitions);
  writer.writeString(offsets[4], object.id);
  writer.writeString(offsets[5], object.nameAr);
  writer.writeString(offsets[6], object.nameFr);
  writer.writeString(offsets[7], object.notes);
  writer.writeLong(offsets[8], object.surahNumber);
  writer.writeString(offsets[9], object.taskId);
  writer.writeString(offsets[10], object.textAr);
  writer.writeString(offsets[11], object.textFr);
  writer.writeString(offsets[12], object.type);
}

TaskContent _taskContentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskContent();
  object.ayahEnd = reader.readLongOrNull(offsets[0]);
  object.ayahStart = reader.readLongOrNull(offsets[1]);
  object.category = reader.readStringOrNull(offsets[2]);
  object.defaultRepetitions = reader.readLongOrNull(offsets[3]);
  object.id = reader.readString(offsets[4]);
  object.isarId = id;
  object.nameAr = reader.readStringOrNull(offsets[5]);
  object.nameFr = reader.readStringOrNull(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.surahNumber = reader.readLongOrNull(offsets[8]);
  object.textAr = reader.readStringOrNull(offsets[10]);
  object.textFr = reader.readStringOrNull(offsets[11]);
  object.type = reader.readString(offsets[12]);
  return object;
}

P _taskContentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _taskContentGetId(TaskContent object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _taskContentGetLinks(TaskContent object) {
  return [];
}

void _taskContentAttach(
    IsarCollection<dynamic> col, Id id, TaskContent object) {
  object.isarId = id;
}

extension TaskContentQueryWhereSort
    on QueryBuilder<TaskContent, TaskContent, QWhere> {
  QueryBuilder<TaskContent, TaskContent, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TaskContentQueryWhere
    on QueryBuilder<TaskContent, TaskContent, QWhereClause> {
  QueryBuilder<TaskContent, TaskContent, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterWhereClause> taskIdEqualTo(
      String taskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskId',
        value: [taskId],
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterWhereClause> taskIdNotEqualTo(
      String taskId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TaskContentQueryFilter
    on QueryBuilder<TaskContent, TaskContent, QFilterCondition> {
  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ayahEnd',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ayahEnd',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> ayahEndEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ayahEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahEndGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ayahEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> ayahEndLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ayahEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> ayahEndBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ayahEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ayahStart',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ayahStart',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahStartEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ayahStart',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahStartGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ayahStart',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahStartLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ayahStart',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      ayahStartBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ayahStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> categoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> categoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      defaultRepetitionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'defaultRepetitions',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      defaultRepetitionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'defaultRepetitions',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      defaultRepetitionsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      defaultRepetitionsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      defaultRepetitionsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      defaultRepetitionsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultRepetitions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameArIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nameAr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameArIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nameAr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameArEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameArGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameArLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameArBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameAr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameArStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameArEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameArContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameArMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameAr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameArIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameAr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameArIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameAr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameFrIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nameFr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameFrIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nameFr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameFrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameFrGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameFrLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameFrBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameFr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameFrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameFrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameFrContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> nameFrMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameFr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameFrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameFr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      nameFrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameFr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      surahNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'surahNumber',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      surahNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'surahNumber',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      surahNumberEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      surahNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      surahNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      surahNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surahNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> taskIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      taskIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> taskIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> taskIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      taskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> taskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> taskIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> taskIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textArIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'textAr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textArIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'textAr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textArEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textArGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textArLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textArBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textAr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textArStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textArEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textArContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textArMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textAr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textArIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textAr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textArIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textAr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textFrIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'textFr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textFrIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'textFr',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textFrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textFrGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textFrLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textFrBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textFr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textFrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textFrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textFrContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textFr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> textFrMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textFr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textFrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textFr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      textFrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textFr',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension TaskContentQueryObject
    on QueryBuilder<TaskContent, TaskContent, QFilterCondition> {}

extension TaskContentQueryLinks
    on QueryBuilder<TaskContent, TaskContent, QFilterCondition> {}

extension TaskContentQuerySortBy
    on QueryBuilder<TaskContent, TaskContent, QSortBy> {
  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByAyahEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahEnd', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByAyahEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahEnd', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByAyahStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahStart', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByAyahStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahStart', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy>
      sortByDefaultRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultRepetitions', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy>
      sortByDefaultRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultRepetitions', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByNameAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameAr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByNameArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameAr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByNameFr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameFr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByNameFrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameFr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortBySurahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByTextAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByTextArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByTextFr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByTextFrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TaskContentQuerySortThenBy
    on QueryBuilder<TaskContent, TaskContent, QSortThenBy> {
  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByAyahEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahEnd', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByAyahEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahEnd', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByAyahStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahStart', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByAyahStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahStart', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy>
      thenByDefaultRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultRepetitions', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy>
      thenByDefaultRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultRepetitions', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByNameAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameAr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByNameArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameAr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByNameFr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameFr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByNameFrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameFr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenBySurahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByTextAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByTextArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textAr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByTextFr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByTextFrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textFr', Sort.desc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TaskContentQueryWhereDistinct
    on QueryBuilder<TaskContent, TaskContent, QDistinct> {
  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByAyahEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ayahEnd');
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByAyahStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ayahStart');
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct>
      distinctByDefaultRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultRepetitions');
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByNameAr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameAr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByNameFr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameFr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surahNumber');
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByTaskId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByTextAr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textAr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByTextFr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textFr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskContent, TaskContent, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension TaskContentQueryProperty
    on QueryBuilder<TaskContent, TaskContent, QQueryProperty> {
  QueryBuilder<TaskContent, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<TaskContent, int?, QQueryOperations> ayahEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ayahEnd');
    });
  }

  QueryBuilder<TaskContent, int?, QQueryOperations> ayahStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ayahStart');
    });
  }

  QueryBuilder<TaskContent, String?, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<TaskContent, int?, QQueryOperations>
      defaultRepetitionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultRepetitions');
    });
  }

  QueryBuilder<TaskContent, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskContent, String?, QQueryOperations> nameArProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameAr');
    });
  }

  QueryBuilder<TaskContent, String?, QQueryOperations> nameFrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameFr');
    });
  }

  QueryBuilder<TaskContent, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<TaskContent, int?, QQueryOperations> surahNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surahNumber');
    });
  }

  QueryBuilder<TaskContent, String, QQueryOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }

  QueryBuilder<TaskContent, String?, QQueryOperations> textArProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textAr');
    });
  }

  QueryBuilder<TaskContent, String?, QQueryOperations> textFrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textFr');
    });
  }

  QueryBuilder<TaskContent, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
