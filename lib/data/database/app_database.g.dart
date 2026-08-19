// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StockPalletsTable extends StockPallets
    with TableInfo<$StockPalletsTable, StockPallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockPalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _locationCodeMeta = const VerificationMeta(
    'locationCode',
  );
  @override
  late final GeneratedColumn<String> locationCode = GeneratedColumn<String>(
    'location_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _pluMeta = const VerificationMeta('plu');
  @override
  late final GeneratedColumn<String> plu = GeneratedColumn<String>(
    'plu',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returHariMeta = const VerificationMeta(
    'returHari',
  );
  @override
  late final GeneratedColumn<int> returHari = GeneratedColumn<int>(
    'retur_hari',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conv2Meta = const VerificationMeta('conv2');
  @override
  late final GeneratedColumn<int> conv2 = GeneratedColumn<int>(
    'conv2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operatorNikMeta = const VerificationMeta(
    'operatorNik',
  );
  @override
  late final GeneratedColumn<String> operatorNik = GeneratedColumn<String>(
    'operator_nik',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sesuaiMasterMeta = const VerificationMeta(
    'sesuaiMaster',
  );
  @override
  late final GeneratedColumn<bool> sesuaiMaster = GeneratedColumn<bool>(
    'sesuai_master',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sesuai_master" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _tearMeta = const VerificationMeta('tear');
  @override
  late final GeneratedColumn<int> tear = GeneratedColumn<int>(
    'tear',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stackMeta = const VerificationMeta('stack');
  @override
  late final GeneratedColumn<int> stack = GeneratedColumn<int>(
    'stack',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyCtnMeta = const VerificationMeta('qtyCtn');
  @override
  late final GeneratedColumn<int> qtyCtn = GeneratedColumn<int>(
    'qty_ctn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyPcsMeta = const VerificationMeta('qtyPcs');
  @override
  late final GeneratedColumn<int> qtyPcs = GeneratedColumn<int>(
    'qty_pcs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiredDateMeta = const VerificationMeta(
    'expiredDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiredDate = GeneratedColumn<DateTime>(
    'expired_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locationCode,
    plu,
    barcode,
    description,
    price,
    returHari,
    conv2,
    type,
    operatorNik,
    sesuaiMaster,
    tear,
    stack,
    qtyCtn,
    qtyPcs,
    expiredDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_pallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockPallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('location_code')) {
      context.handle(
        _locationCodeMeta,
        locationCode.isAcceptableOrUnknown(
          data['location_code']!,
          _locationCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationCodeMeta);
    }
    if (data.containsKey('plu')) {
      context.handle(
        _pluMeta,
        plu.isAcceptableOrUnknown(data['plu']!, _pluMeta),
      );
    } else if (isInserting) {
      context.missing(_pluMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('retur_hari')) {
      context.handle(
        _returHariMeta,
        returHari.isAcceptableOrUnknown(data['retur_hari']!, _returHariMeta),
      );
    } else if (isInserting) {
      context.missing(_returHariMeta);
    }
    if (data.containsKey('conv2')) {
      context.handle(
        _conv2Meta,
        conv2.isAcceptableOrUnknown(data['conv2']!, _conv2Meta),
      );
    } else if (isInserting) {
      context.missing(_conv2Meta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('operator_nik')) {
      context.handle(
        _operatorNikMeta,
        operatorNik.isAcceptableOrUnknown(
          data['operator_nik']!,
          _operatorNikMeta,
        ),
      );
    }
    if (data.containsKey('sesuai_master')) {
      context.handle(
        _sesuaiMasterMeta,
        sesuaiMaster.isAcceptableOrUnknown(
          data['sesuai_master']!,
          _sesuaiMasterMeta,
        ),
      );
    }
    if (data.containsKey('tear')) {
      context.handle(
        _tearMeta,
        tear.isAcceptableOrUnknown(data['tear']!, _tearMeta),
      );
    } else if (isInserting) {
      context.missing(_tearMeta);
    }
    if (data.containsKey('stack')) {
      context.handle(
        _stackMeta,
        stack.isAcceptableOrUnknown(data['stack']!, _stackMeta),
      );
    } else if (isInserting) {
      context.missing(_stackMeta);
    }
    if (data.containsKey('qty_ctn')) {
      context.handle(
        _qtyCtnMeta,
        qtyCtn.isAcceptableOrUnknown(data['qty_ctn']!, _qtyCtnMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyCtnMeta);
    }
    if (data.containsKey('qty_pcs')) {
      context.handle(
        _qtyPcsMeta,
        qtyPcs.isAcceptableOrUnknown(data['qty_pcs']!, _qtyPcsMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyPcsMeta);
    }
    if (data.containsKey('expired_date')) {
      context.handle(
        _expiredDateMeta,
        expiredDate.isAcceptableOrUnknown(
          data['expired_date']!,
          _expiredDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expiredDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockPallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockPallet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      locationCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_code'],
      )!,
      plu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plu'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      returHari: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retur_hari'],
      )!,
      conv2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conv2'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      operatorNik: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_nik'],
      )!,
      sesuaiMaster: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sesuai_master'],
      )!,
      tear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tear'],
      )!,
      stack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack'],
      )!,
      qtyCtn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_ctn'],
      )!,
      qtyPcs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_pcs'],
      )!,
      expiredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expired_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StockPalletsTable createAlias(String alias) {
    return $StockPalletsTable(attachedDatabase, alias);
  }
}

class StockPallet extends DataClass implements Insertable<StockPallet> {
  final int id;
  final String locationCode;
  final String plu;
  final String barcode;
  final String description;
  final double price;
  final int returHari;
  final int conv2;
  final String type;
  final String operatorNik;
  final bool sesuaiMaster;
  final int tear;
  final int stack;
  final int qtyCtn;
  final int qtyPcs;
  final DateTime expiredDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StockPallet({
    required this.id,
    required this.locationCode,
    required this.plu,
    required this.barcode,
    required this.description,
    required this.price,
    required this.returHari,
    required this.conv2,
    required this.type,
    required this.operatorNik,
    required this.sesuaiMaster,
    required this.tear,
    required this.stack,
    required this.qtyCtn,
    required this.qtyPcs,
    required this.expiredDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['location_code'] = Variable<String>(locationCode);
    map['plu'] = Variable<String>(plu);
    map['barcode'] = Variable<String>(barcode);
    map['description'] = Variable<String>(description);
    map['price'] = Variable<double>(price);
    map['retur_hari'] = Variable<int>(returHari);
    map['conv2'] = Variable<int>(conv2);
    map['type'] = Variable<String>(type);
    map['operator_nik'] = Variable<String>(operatorNik);
    map['sesuai_master'] = Variable<bool>(sesuaiMaster);
    map['tear'] = Variable<int>(tear);
    map['stack'] = Variable<int>(stack);
    map['qty_ctn'] = Variable<int>(qtyCtn);
    map['qty_pcs'] = Variable<int>(qtyPcs);
    map['expired_date'] = Variable<DateTime>(expiredDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StockPalletsCompanion toCompanion(bool nullToAbsent) {
    return StockPalletsCompanion(
      id: Value(id),
      locationCode: Value(locationCode),
      plu: Value(plu),
      barcode: Value(barcode),
      description: Value(description),
      price: Value(price),
      returHari: Value(returHari),
      conv2: Value(conv2),
      type: Value(type),
      operatorNik: Value(operatorNik),
      sesuaiMaster: Value(sesuaiMaster),
      tear: Value(tear),
      stack: Value(stack),
      qtyCtn: Value(qtyCtn),
      qtyPcs: Value(qtyPcs),
      expiredDate: Value(expiredDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StockPallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockPallet(
      id: serializer.fromJson<int>(json['id']),
      locationCode: serializer.fromJson<String>(json['locationCode']),
      plu: serializer.fromJson<String>(json['plu']),
      barcode: serializer.fromJson<String>(json['barcode']),
      description: serializer.fromJson<String>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      returHari: serializer.fromJson<int>(json['returHari']),
      conv2: serializer.fromJson<int>(json['conv2']),
      type: serializer.fromJson<String>(json['type']),
      operatorNik: serializer.fromJson<String>(json['operatorNik']),
      sesuaiMaster: serializer.fromJson<bool>(json['sesuaiMaster']),
      tear: serializer.fromJson<int>(json['tear']),
      stack: serializer.fromJson<int>(json['stack']),
      qtyCtn: serializer.fromJson<int>(json['qtyCtn']),
      qtyPcs: serializer.fromJson<int>(json['qtyPcs']),
      expiredDate: serializer.fromJson<DateTime>(json['expiredDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'locationCode': serializer.toJson<String>(locationCode),
      'plu': serializer.toJson<String>(plu),
      'barcode': serializer.toJson<String>(barcode),
      'description': serializer.toJson<String>(description),
      'price': serializer.toJson<double>(price),
      'returHari': serializer.toJson<int>(returHari),
      'conv2': serializer.toJson<int>(conv2),
      'type': serializer.toJson<String>(type),
      'operatorNik': serializer.toJson<String>(operatorNik),
      'sesuaiMaster': serializer.toJson<bool>(sesuaiMaster),
      'tear': serializer.toJson<int>(tear),
      'stack': serializer.toJson<int>(stack),
      'qtyCtn': serializer.toJson<int>(qtyCtn),
      'qtyPcs': serializer.toJson<int>(qtyPcs),
      'expiredDate': serializer.toJson<DateTime>(expiredDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StockPallet copyWith({
    int? id,
    String? locationCode,
    String? plu,
    String? barcode,
    String? description,
    double? price,
    int? returHari,
    int? conv2,
    String? type,
    String? operatorNik,
    bool? sesuaiMaster,
    int? tear,
    int? stack,
    int? qtyCtn,
    int? qtyPcs,
    DateTime? expiredDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StockPallet(
    id: id ?? this.id,
    locationCode: locationCode ?? this.locationCode,
    plu: plu ?? this.plu,
    barcode: barcode ?? this.barcode,
    description: description ?? this.description,
    price: price ?? this.price,
    returHari: returHari ?? this.returHari,
    conv2: conv2 ?? this.conv2,
    type: type ?? this.type,
    operatorNik: operatorNik ?? this.operatorNik,
    sesuaiMaster: sesuaiMaster ?? this.sesuaiMaster,
    tear: tear ?? this.tear,
    stack: stack ?? this.stack,
    qtyCtn: qtyCtn ?? this.qtyCtn,
    qtyPcs: qtyPcs ?? this.qtyPcs,
    expiredDate: expiredDate ?? this.expiredDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StockPallet copyWithCompanion(StockPalletsCompanion data) {
    return StockPallet(
      id: data.id.present ? data.id.value : this.id,
      locationCode: data.locationCode.present
          ? data.locationCode.value
          : this.locationCode,
      plu: data.plu.present ? data.plu.value : this.plu,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      returHari: data.returHari.present ? data.returHari.value : this.returHari,
      conv2: data.conv2.present ? data.conv2.value : this.conv2,
      type: data.type.present ? data.type.value : this.type,
      operatorNik: data.operatorNik.present
          ? data.operatorNik.value
          : this.operatorNik,
      sesuaiMaster: data.sesuaiMaster.present
          ? data.sesuaiMaster.value
          : this.sesuaiMaster,
      tear: data.tear.present ? data.tear.value : this.tear,
      stack: data.stack.present ? data.stack.value : this.stack,
      qtyCtn: data.qtyCtn.present ? data.qtyCtn.value : this.qtyCtn,
      qtyPcs: data.qtyPcs.present ? data.qtyPcs.value : this.qtyPcs,
      expiredDate: data.expiredDate.present
          ? data.expiredDate.value
          : this.expiredDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockPallet(')
          ..write('id: $id, ')
          ..write('locationCode: $locationCode, ')
          ..write('plu: $plu, ')
          ..write('barcode: $barcode, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('returHari: $returHari, ')
          ..write('conv2: $conv2, ')
          ..write('type: $type, ')
          ..write('operatorNik: $operatorNik, ')
          ..write('sesuaiMaster: $sesuaiMaster, ')
          ..write('tear: $tear, ')
          ..write('stack: $stack, ')
          ..write('qtyCtn: $qtyCtn, ')
          ..write('qtyPcs: $qtyPcs, ')
          ..write('expiredDate: $expiredDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    locationCode,
    plu,
    barcode,
    description,
    price,
    returHari,
    conv2,
    type,
    operatorNik,
    sesuaiMaster,
    tear,
    stack,
    qtyCtn,
    qtyPcs,
    expiredDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockPallet &&
          other.id == this.id &&
          other.locationCode == this.locationCode &&
          other.plu == this.plu &&
          other.barcode == this.barcode &&
          other.description == this.description &&
          other.price == this.price &&
          other.returHari == this.returHari &&
          other.conv2 == this.conv2 &&
          other.type == this.type &&
          other.operatorNik == this.operatorNik &&
          other.sesuaiMaster == this.sesuaiMaster &&
          other.tear == this.tear &&
          other.stack == this.stack &&
          other.qtyCtn == this.qtyCtn &&
          other.qtyPcs == this.qtyPcs &&
          other.expiredDate == this.expiredDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StockPalletsCompanion extends UpdateCompanion<StockPallet> {
  final Value<int> id;
  final Value<String> locationCode;
  final Value<String> plu;
  final Value<String> barcode;
  final Value<String> description;
  final Value<double> price;
  final Value<int> returHari;
  final Value<int> conv2;
  final Value<String> type;
  final Value<String> operatorNik;
  final Value<bool> sesuaiMaster;
  final Value<int> tear;
  final Value<int> stack;
  final Value<int> qtyCtn;
  final Value<int> qtyPcs;
  final Value<DateTime> expiredDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const StockPalletsCompanion({
    this.id = const Value.absent(),
    this.locationCode = const Value.absent(),
    this.plu = const Value.absent(),
    this.barcode = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.returHari = const Value.absent(),
    this.conv2 = const Value.absent(),
    this.type = const Value.absent(),
    this.operatorNik = const Value.absent(),
    this.sesuaiMaster = const Value.absent(),
    this.tear = const Value.absent(),
    this.stack = const Value.absent(),
    this.qtyCtn = const Value.absent(),
    this.qtyPcs = const Value.absent(),
    this.expiredDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StockPalletsCompanion.insert({
    this.id = const Value.absent(),
    required String locationCode,
    required String plu,
    required String barcode,
    required String description,
    required double price,
    required int returHari,
    required int conv2,
    required String type,
    this.operatorNik = const Value.absent(),
    this.sesuaiMaster = const Value.absent(),
    required int tear,
    required int stack,
    required int qtyCtn,
    required int qtyPcs,
    required DateTime expiredDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : locationCode = Value(locationCode),
       plu = Value(plu),
       barcode = Value(barcode),
       description = Value(description),
       price = Value(price),
       returHari = Value(returHari),
       conv2 = Value(conv2),
       type = Value(type),
       tear = Value(tear),
       stack = Value(stack),
       qtyCtn = Value(qtyCtn),
       qtyPcs = Value(qtyPcs),
       expiredDate = Value(expiredDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StockPallet> custom({
    Expression<int>? id,
    Expression<String>? locationCode,
    Expression<String>? plu,
    Expression<String>? barcode,
    Expression<String>? description,
    Expression<double>? price,
    Expression<int>? returHari,
    Expression<int>? conv2,
    Expression<String>? type,
    Expression<String>? operatorNik,
    Expression<bool>? sesuaiMaster,
    Expression<int>? tear,
    Expression<int>? stack,
    Expression<int>? qtyCtn,
    Expression<int>? qtyPcs,
    Expression<DateTime>? expiredDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locationCode != null) 'location_code': locationCode,
      if (plu != null) 'plu': plu,
      if (barcode != null) 'barcode': barcode,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (returHari != null) 'retur_hari': returHari,
      if (conv2 != null) 'conv2': conv2,
      if (type != null) 'type': type,
      if (operatorNik != null) 'operator_nik': operatorNik,
      if (sesuaiMaster != null) 'sesuai_master': sesuaiMaster,
      if (tear != null) 'tear': tear,
      if (stack != null) 'stack': stack,
      if (qtyCtn != null) 'qty_ctn': qtyCtn,
      if (qtyPcs != null) 'qty_pcs': qtyPcs,
      if (expiredDate != null) 'expired_date': expiredDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StockPalletsCompanion copyWith({
    Value<int>? id,
    Value<String>? locationCode,
    Value<String>? plu,
    Value<String>? barcode,
    Value<String>? description,
    Value<double>? price,
    Value<int>? returHari,
    Value<int>? conv2,
    Value<String>? type,
    Value<String>? operatorNik,
    Value<bool>? sesuaiMaster,
    Value<int>? tear,
    Value<int>? stack,
    Value<int>? qtyCtn,
    Value<int>? qtyPcs,
    Value<DateTime>? expiredDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return StockPalletsCompanion(
      id: id ?? this.id,
      locationCode: locationCode ?? this.locationCode,
      plu: plu ?? this.plu,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      price: price ?? this.price,
      returHari: returHari ?? this.returHari,
      conv2: conv2 ?? this.conv2,
      type: type ?? this.type,
      operatorNik: operatorNik ?? this.operatorNik,
      sesuaiMaster: sesuaiMaster ?? this.sesuaiMaster,
      tear: tear ?? this.tear,
      stack: stack ?? this.stack,
      qtyCtn: qtyCtn ?? this.qtyCtn,
      qtyPcs: qtyPcs ?? this.qtyPcs,
      expiredDate: expiredDate ?? this.expiredDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (locationCode.present) {
      map['location_code'] = Variable<String>(locationCode.value);
    }
    if (plu.present) {
      map['plu'] = Variable<String>(plu.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (returHari.present) {
      map['retur_hari'] = Variable<int>(returHari.value);
    }
    if (conv2.present) {
      map['conv2'] = Variable<int>(conv2.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (operatorNik.present) {
      map['operator_nik'] = Variable<String>(operatorNik.value);
    }
    if (sesuaiMaster.present) {
      map['sesuai_master'] = Variable<bool>(sesuaiMaster.value);
    }
    if (tear.present) {
      map['tear'] = Variable<int>(tear.value);
    }
    if (stack.present) {
      map['stack'] = Variable<int>(stack.value);
    }
    if (qtyCtn.present) {
      map['qty_ctn'] = Variable<int>(qtyCtn.value);
    }
    if (qtyPcs.present) {
      map['qty_pcs'] = Variable<int>(qtyPcs.value);
    }
    if (expiredDate.present) {
      map['expired_date'] = Variable<DateTime>(expiredDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockPalletsCompanion(')
          ..write('id: $id, ')
          ..write('locationCode: $locationCode, ')
          ..write('plu: $plu, ')
          ..write('barcode: $barcode, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('returHari: $returHari, ')
          ..write('conv2: $conv2, ')
          ..write('type: $type, ')
          ..write('operatorNik: $operatorNik, ')
          ..write('sesuaiMaster: $sesuaiMaster, ')
          ..write('tear: $tear, ')
          ..write('stack: $stack, ')
          ..write('qtyCtn: $qtyCtn, ')
          ..write('qtyPcs: $qtyPcs, ')
          ..write('expiredDate: $expiredDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StorageLocationsTable extends StorageLocations
    with TableInfo<$StorageLocationsTable, StorageLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorageLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _locationCodeMeta = const VerificationMeta(
    'locationCode',
  );
  @override
  late final GeneratedColumn<String> locationCode = GeneratedColumn<String>(
    'location_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AVAILABLE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locationCode,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storage_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<StorageLocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('location_code')) {
      context.handle(
        _locationCodeMeta,
        locationCode.isAcceptableOrUnknown(
          data['location_code']!,
          _locationCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationCodeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StorageLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorageLocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      locationCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_code'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StorageLocationsTable createAlias(String alias) {
    return $StorageLocationsTable(attachedDatabase, alias);
  }
}

class StorageLocation extends DataClass implements Insertable<StorageLocation> {
  /// ----------------------------------------------------------
  /// ID database
  /// ----------------------------------------------------------
  ///
  /// Primary key otomatis.
  /// ----------------------------------------------------------
  final int id;

  /// ----------------------------------------------------------
  /// LOCATION CODE
  /// ----------------------------------------------------------
  ///
  /// Contoh:
  /// A01-01-01
  ///
  /// Dibuat unique agar satu kode lokasi tidak boleh
  /// muncul dua kali di database.
  /// ----------------------------------------------------------
  final String locationCode;

  /// ----------------------------------------------------------
  /// STATUS LOKASI
  /// ----------------------------------------------------------
  ///
  /// Nilai awal:
  /// AVAILABLE
  ///
  /// Status akan berubah ketika pallet masuk/keluar.
  /// ----------------------------------------------------------
  final String status;

  /// ----------------------------------------------------------
  /// CREATED AT
  /// ----------------------------------------------------------
  ///
  /// Waktu lokasi dibuat.
  /// ----------------------------------------------------------
  final DateTime createdAt;

  /// ----------------------------------------------------------
  /// UPDATED AT
  /// ----------------------------------------------------------
  ///
  /// Waktu terakhir lokasi diperbarui.
  /// ----------------------------------------------------------
  final DateTime updatedAt;
  const StorageLocation({
    required this.id,
    required this.locationCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['location_code'] = Variable<String>(locationCode);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StorageLocationsCompanion toCompanion(bool nullToAbsent) {
    return StorageLocationsCompanion(
      id: Value(id),
      locationCode: Value(locationCode),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StorageLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorageLocation(
      id: serializer.fromJson<int>(json['id']),
      locationCode: serializer.fromJson<String>(json['locationCode']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'locationCode': serializer.toJson<String>(locationCode),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StorageLocation copyWith({
    int? id,
    String? locationCode,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StorageLocation(
    id: id ?? this.id,
    locationCode: locationCode ?? this.locationCode,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StorageLocation copyWithCompanion(StorageLocationsCompanion data) {
    return StorageLocation(
      id: data.id.present ? data.id.value : this.id,
      locationCode: data.locationCode.present
          ? data.locationCode.value
          : this.locationCode,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorageLocation(')
          ..write('id: $id, ')
          ..write('locationCode: $locationCode, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locationCode, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageLocation &&
          other.id == this.id &&
          other.locationCode == this.locationCode &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StorageLocationsCompanion extends UpdateCompanion<StorageLocation> {
  final Value<int> id;
  final Value<String> locationCode;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const StorageLocationsCompanion({
    this.id = const Value.absent(),
    this.locationCode = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StorageLocationsCompanion.insert({
    this.id = const Value.absent(),
    required String locationCode,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : locationCode = Value(locationCode);
  static Insertable<StorageLocation> custom({
    Expression<int>? id,
    Expression<String>? locationCode,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locationCode != null) 'location_code': locationCode,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StorageLocationsCompanion copyWith({
    Value<int>? id,
    Value<String>? locationCode,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return StorageLocationsCompanion(
      id: id ?? this.id,
      locationCode: locationCode ?? this.locationCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (locationCode.present) {
      map['location_code'] = Variable<String>(locationCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorageLocationsCompanion(')
          ..write('id: $id, ')
          ..write('locationCode: $locationCode, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StockPalletsTable stockPallets = $StockPalletsTable(this);
  late final $StorageLocationsTable storageLocations = $StorageLocationsTable(
    this,
  );
  late final StockPalletDao stockPalletDao = StockPalletDao(
    this as AppDatabase,
  );
  late final StorageLocationDao storageLocationDao = StorageLocationDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    stockPallets,
    storageLocations,
  ];
}

typedef $$StockPalletsTableCreateCompanionBuilder =
    StockPalletsCompanion Function({
      Value<int> id,
      required String locationCode,
      required String plu,
      required String barcode,
      required String description,
      required double price,
      required int returHari,
      required int conv2,
      required String type,
      Value<String> operatorNik,
      Value<bool> sesuaiMaster,
      required int tear,
      required int stack,
      required int qtyCtn,
      required int qtyPcs,
      required DateTime expiredDate,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$StockPalletsTableUpdateCompanionBuilder =
    StockPalletsCompanion Function({
      Value<int> id,
      Value<String> locationCode,
      Value<String> plu,
      Value<String> barcode,
      Value<String> description,
      Value<double> price,
      Value<int> returHari,
      Value<int> conv2,
      Value<String> type,
      Value<String> operatorNik,
      Value<bool> sesuaiMaster,
      Value<int> tear,
      Value<int> stack,
      Value<int> qtyCtn,
      Value<int> qtyPcs,
      Value<DateTime> expiredDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$StockPalletsTableFilterComposer
    extends Composer<_$AppDatabase, $StockPalletsTable> {
  $$StockPalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationCode => $composableBuilder(
    column: $table.locationCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plu => $composableBuilder(
    column: $table.plu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get returHari => $composableBuilder(
    column: $table.returHari,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conv2 => $composableBuilder(
    column: $table.conv2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorNik => $composableBuilder(
    column: $table.operatorNik,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sesuaiMaster => $composableBuilder(
    column: $table.sesuaiMaster,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tear => $composableBuilder(
    column: $table.tear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stack => $composableBuilder(
    column: $table.stack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyCtn => $composableBuilder(
    column: $table.qtyCtn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyPcs => $composableBuilder(
    column: $table.qtyPcs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiredDate => $composableBuilder(
    column: $table.expiredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockPalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockPalletsTable> {
  $$StockPalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationCode => $composableBuilder(
    column: $table.locationCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plu => $composableBuilder(
    column: $table.plu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get returHari => $composableBuilder(
    column: $table.returHari,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conv2 => $composableBuilder(
    column: $table.conv2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorNik => $composableBuilder(
    column: $table.operatorNik,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sesuaiMaster => $composableBuilder(
    column: $table.sesuaiMaster,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tear => $composableBuilder(
    column: $table.tear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stack => $composableBuilder(
    column: $table.stack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyCtn => $composableBuilder(
    column: $table.qtyCtn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyPcs => $composableBuilder(
    column: $table.qtyPcs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiredDate => $composableBuilder(
    column: $table.expiredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockPalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockPalletsTable> {
  $$StockPalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationCode => $composableBuilder(
    column: $table.locationCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plu =>
      $composableBuilder(column: $table.plu, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get returHari =>
      $composableBuilder(column: $table.returHari, builder: (column) => column);

  GeneratedColumn<int> get conv2 =>
      $composableBuilder(column: $table.conv2, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get operatorNik => $composableBuilder(
    column: $table.operatorNik,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sesuaiMaster => $composableBuilder(
    column: $table.sesuaiMaster,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tear =>
      $composableBuilder(column: $table.tear, builder: (column) => column);

  GeneratedColumn<int> get stack =>
      $composableBuilder(column: $table.stack, builder: (column) => column);

  GeneratedColumn<int> get qtyCtn =>
      $composableBuilder(column: $table.qtyCtn, builder: (column) => column);

  GeneratedColumn<int> get qtyPcs =>
      $composableBuilder(column: $table.qtyPcs, builder: (column) => column);

  GeneratedColumn<DateTime> get expiredDate => $composableBuilder(
    column: $table.expiredDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StockPalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockPalletsTable,
          StockPallet,
          $$StockPalletsTableFilterComposer,
          $$StockPalletsTableOrderingComposer,
          $$StockPalletsTableAnnotationComposer,
          $$StockPalletsTableCreateCompanionBuilder,
          $$StockPalletsTableUpdateCompanionBuilder,
          (
            StockPallet,
            BaseReferences<_$AppDatabase, $StockPalletsTable, StockPallet>,
          ),
          StockPallet,
          PrefetchHooks Function()
        > {
  $$StockPalletsTableTableManager(_$AppDatabase db, $StockPalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockPalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockPalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockPalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> locationCode = const Value.absent(),
                Value<String> plu = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> returHari = const Value.absent(),
                Value<int> conv2 = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> operatorNik = const Value.absent(),
                Value<bool> sesuaiMaster = const Value.absent(),
                Value<int> tear = const Value.absent(),
                Value<int> stack = const Value.absent(),
                Value<int> qtyCtn = const Value.absent(),
                Value<int> qtyPcs = const Value.absent(),
                Value<DateTime> expiredDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StockPalletsCompanion(
                id: id,
                locationCode: locationCode,
                plu: plu,
                barcode: barcode,
                description: description,
                price: price,
                returHari: returHari,
                conv2: conv2,
                type: type,
                operatorNik: operatorNik,
                sesuaiMaster: sesuaiMaster,
                tear: tear,
                stack: stack,
                qtyCtn: qtyCtn,
                qtyPcs: qtyPcs,
                expiredDate: expiredDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String locationCode,
                required String plu,
                required String barcode,
                required String description,
                required double price,
                required int returHari,
                required int conv2,
                required String type,
                Value<String> operatorNik = const Value.absent(),
                Value<bool> sesuaiMaster = const Value.absent(),
                required int tear,
                required int stack,
                required int qtyCtn,
                required int qtyPcs,
                required DateTime expiredDate,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => StockPalletsCompanion.insert(
                id: id,
                locationCode: locationCode,
                plu: plu,
                barcode: barcode,
                description: description,
                price: price,
                returHari: returHari,
                conv2: conv2,
                type: type,
                operatorNik: operatorNik,
                sesuaiMaster: sesuaiMaster,
                tear: tear,
                stack: stack,
                qtyCtn: qtyCtn,
                qtyPcs: qtyPcs,
                expiredDate: expiredDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockPalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockPalletsTable,
      StockPallet,
      $$StockPalletsTableFilterComposer,
      $$StockPalletsTableOrderingComposer,
      $$StockPalletsTableAnnotationComposer,
      $$StockPalletsTableCreateCompanionBuilder,
      $$StockPalletsTableUpdateCompanionBuilder,
      (
        StockPallet,
        BaseReferences<_$AppDatabase, $StockPalletsTable, StockPallet>,
      ),
      StockPallet,
      PrefetchHooks Function()
    >;
typedef $$StorageLocationsTableCreateCompanionBuilder =
    StorageLocationsCompanion Function({
      Value<int> id,
      required String locationCode,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$StorageLocationsTableUpdateCompanionBuilder =
    StorageLocationsCompanion Function({
      Value<int> id,
      Value<String> locationCode,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$StorageLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $StorageLocationsTable> {
  $$StorageLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationCode => $composableBuilder(
    column: $table.locationCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StorageLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $StorageLocationsTable> {
  $$StorageLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationCode => $composableBuilder(
    column: $table.locationCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StorageLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StorageLocationsTable> {
  $$StorageLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationCode => $composableBuilder(
    column: $table.locationCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StorageLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StorageLocationsTable,
          StorageLocation,
          $$StorageLocationsTableFilterComposer,
          $$StorageLocationsTableOrderingComposer,
          $$StorageLocationsTableAnnotationComposer,
          $$StorageLocationsTableCreateCompanionBuilder,
          $$StorageLocationsTableUpdateCompanionBuilder,
          (
            StorageLocation,
            BaseReferences<
              _$AppDatabase,
              $StorageLocationsTable,
              StorageLocation
            >,
          ),
          StorageLocation,
          PrefetchHooks Function()
        > {
  $$StorageLocationsTableTableManager(
    _$AppDatabase db,
    $StorageLocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StorageLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StorageLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StorageLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> locationCode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StorageLocationsCompanion(
                id: id,
                locationCode: locationCode,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String locationCode,
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => StorageLocationsCompanion.insert(
                id: id,
                locationCode: locationCode,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StorageLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StorageLocationsTable,
      StorageLocation,
      $$StorageLocationsTableFilterComposer,
      $$StorageLocationsTableOrderingComposer,
      $$StorageLocationsTableAnnotationComposer,
      $$StorageLocationsTableCreateCompanionBuilder,
      $$StorageLocationsTableUpdateCompanionBuilder,
      (
        StorageLocation,
        BaseReferences<_$AppDatabase, $StorageLocationsTable, StorageLocation>,
      ),
      StorageLocation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StockPalletsTableTableManager get stockPallets =>
      $$StockPalletsTableTableManager(_db, _db.stockPallets);
  $$StorageLocationsTableTableManager get storageLocations =>
      $$StorageLocationsTableTableManager(_db, _db.storageLocations);
}
