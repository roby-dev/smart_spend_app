// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_helper_drift.dart';

// ignore_for_file: type=lint
class $ComprasTable extends Compras with TableInfo<$ComprasTable, Compra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
      'titulo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, titulo, fecha];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras';
  @override
  VerificationContext validateIntegrity(Insertable<Compra> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('titulo')) {
      context.handle(_tituloMeta,
          titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta));
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Compra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Compra(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      titulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titulo'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
    );
  }

  @override
  $ComprasTable createAlias(String alias) {
    return $ComprasTable(attachedDatabase, alias);
  }
}

class Compra extends DataClass implements Insertable<Compra> {
  final int id;
  final String titulo;
  final String fecha;
  const Compra({required this.id, required this.titulo, required this.fecha});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['titulo'] = Variable<String>(titulo);
    map['fecha'] = Variable<String>(fecha);
    return map;
  }

  ComprasCompanion toCompanion(bool nullToAbsent) {
    return ComprasCompanion(
      id: Value(id),
      titulo: Value(titulo),
      fecha: Value(fecha),
    );
  }

  factory Compra.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Compra(
      id: serializer.fromJson<int>(json['id']),
      titulo: serializer.fromJson<String>(json['titulo']),
      fecha: serializer.fromJson<String>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titulo': serializer.toJson<String>(titulo),
      'fecha': serializer.toJson<String>(fecha),
    };
  }

  Compra copyWith({int? id, String? titulo, String? fecha}) => Compra(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        fecha: fecha ?? this.fecha,
      );
  Compra copyWithCompanion(ComprasCompanion data) {
    return Compra(
      id: data.id.present ? data.id.value : this.id,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Compra(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, titulo, fecha);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Compra &&
          other.id == this.id &&
          other.titulo == this.titulo &&
          other.fecha == this.fecha);
}

class ComprasCompanion extends UpdateCompanion<Compra> {
  final Value<int> id;
  final Value<String> titulo;
  final Value<String> fecha;
  const ComprasCompanion({
    this.id = const Value.absent(),
    this.titulo = const Value.absent(),
    this.fecha = const Value.absent(),
  });
  ComprasCompanion.insert({
    this.id = const Value.absent(),
    required String titulo,
    required String fecha,
  })  : titulo = Value(titulo),
        fecha = Value(fecha);
  static Insertable<Compra> custom({
    Expression<int>? id,
    Expression<String>? titulo,
    Expression<String>? fecha,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titulo != null) 'titulo': titulo,
      if (fecha != null) 'fecha': fecha,
    });
  }

  ComprasCompanion copyWith(
      {Value<int>? id, Value<String>? titulo, Value<String>? fecha}) {
    return ComprasCompanion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasCompanion(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }
}

class $CompraDetallesTable extends CompraDetalles
    with TableInfo<$CompraDetallesTable, CompraDetalle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompraDetallesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
      'precio', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _compraMeta = const VerificationMeta('compra');
  @override
  late final GeneratedColumn<int> compra = GeneratedColumn<int>(
      'compra', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES compras (id)'));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
      'fecha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, nombre, precio, compra, fecha];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compra_detalles';
  @override
  VerificationContext validateIntegrity(Insertable<CompraDetalle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(_precioMeta,
          precio.isAcceptableOrUnknown(data['precio']!, _precioMeta));
    } else if (isInserting) {
      context.missing(_precioMeta);
    }
    if (data.containsKey('compra')) {
      context.handle(_compraMeta,
          compra.isAcceptableOrUnknown(data['compra']!, _compraMeta));
    } else if (isInserting) {
      context.missing(_compraMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompraDetalle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompraDetalle(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      precio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio'])!,
      compra: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}compra'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fecha'])!,
    );
  }

  @override
  $CompraDetallesTable createAlias(String alias) {
    return $CompraDetallesTable(attachedDatabase, alias);
  }
}

class CompraDetalle extends DataClass implements Insertable<CompraDetalle> {
  final int id;
  final String nombre;
  final double precio;
  final int compra;
  final String fecha;
  const CompraDetalle(
      {required this.id,
      required this.nombre,
      required this.precio,
      required this.compra,
      required this.fecha});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['precio'] = Variable<double>(precio);
    map['compra'] = Variable<int>(compra);
    map['fecha'] = Variable<String>(fecha);
    return map;
  }

  CompraDetallesCompanion toCompanion(bool nullToAbsent) {
    return CompraDetallesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      precio: Value(precio),
      compra: Value(compra),
      fecha: Value(fecha),
    );
  }

  factory CompraDetalle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompraDetalle(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      precio: serializer.fromJson<double>(json['precio']),
      compra: serializer.fromJson<int>(json['compra']),
      fecha: serializer.fromJson<String>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'precio': serializer.toJson<double>(precio),
      'compra': serializer.toJson<int>(compra),
      'fecha': serializer.toJson<String>(fecha),
    };
  }

  CompraDetalle copyWith(
          {int? id,
          String? nombre,
          double? precio,
          int? compra,
          String? fecha}) =>
      CompraDetalle(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        precio: precio ?? this.precio,
        compra: compra ?? this.compra,
        fecha: fecha ?? this.fecha,
      );
  CompraDetalle copyWithCompanion(CompraDetallesCompanion data) {
    return CompraDetalle(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      precio: data.precio.present ? data.precio.value : this.precio,
      compra: data.compra.present ? data.compra.value : this.compra,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompraDetalle(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precio: $precio, ')
          ..write('compra: $compra, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, precio, compra, fecha);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompraDetalle &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.precio == this.precio &&
          other.compra == this.compra &&
          other.fecha == this.fecha);
}

class CompraDetallesCompanion extends UpdateCompanion<CompraDetalle> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<double> precio;
  final Value<int> compra;
  final Value<String> fecha;
  const CompraDetallesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.precio = const Value.absent(),
    this.compra = const Value.absent(),
    this.fecha = const Value.absent(),
  });
  CompraDetallesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required double precio,
    required int compra,
    required String fecha,
  })  : nombre = Value(nombre),
        precio = Value(precio),
        compra = Value(compra),
        fecha = Value(fecha);
  static Insertable<CompraDetalle> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<double>? precio,
    Expression<int>? compra,
    Expression<String>? fecha,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (precio != null) 'precio': precio,
      if (compra != null) 'compra': compra,
      if (fecha != null) 'fecha': fecha,
    });
  }

  CompraDetallesCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<double>? precio,
      Value<int>? compra,
      Value<String>? fecha}) {
    return CompraDetallesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      compra: compra ?? this.compra,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (compra.present) {
      map['compra'] = Variable<int>(compra.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompraDetallesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precio: $precio, ')
          ..write('compra: $compra, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ComprasTable compras = $ComprasTable(this);
  late final $CompraDetallesTable compraDetalles = $CompraDetallesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [compras, compraDetalles];
}

typedef $$ComprasTableCreateCompanionBuilder = ComprasCompanion Function({
  Value<int> id,
  required String titulo,
  required String fecha,
});
typedef $$ComprasTableUpdateCompanionBuilder = ComprasCompanion Function({
  Value<int> id,
  Value<String> titulo,
  Value<String> fecha,
});

final class $$ComprasTableReferences
    extends BaseReferences<_$AppDatabase, $ComprasTable, Compra> {
  $$ComprasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompraDetallesTable, List<CompraDetalle>>
      _compraDetallesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.compraDetalles,
              aliasName: $_aliasNameGenerator(
                  db.compras.id, db.compraDetalles.compra));

  $$CompraDetallesTableProcessedTableManager get compraDetallesRefs {
    final manager = $$CompraDetallesTableTableManager($_db, $_db.compraDetalles)
        .filter((f) => f.compra.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_compraDetallesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ComprasTableFilterComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  Expression<bool> compraDetallesRefs(
      Expression<bool> Function($$CompraDetallesTableFilterComposer f) f) {
    final $$CompraDetallesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.compraDetalles,
        getReferencedColumn: (t) => t.compra,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CompraDetallesTableFilterComposer(
              $db: $db,
              $table: $db.compraDetalles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ComprasTableOrderingComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));
}

class $$ComprasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  Expression<T> compraDetallesRefs<T extends Object>(
      Expression<T> Function($$CompraDetallesTableAnnotationComposer a) f) {
    final $$CompraDetallesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.compraDetalles,
        getReferencedColumn: (t) => t.compra,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CompraDetallesTableAnnotationComposer(
              $db: $db,
              $table: $db.compraDetalles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ComprasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ComprasTable,
    Compra,
    $$ComprasTableFilterComposer,
    $$ComprasTableOrderingComposer,
    $$ComprasTableAnnotationComposer,
    $$ComprasTableCreateCompanionBuilder,
    $$ComprasTableUpdateCompanionBuilder,
    (Compra, $$ComprasTableReferences),
    Compra,
    PrefetchHooks Function({bool compraDetallesRefs})> {
  $$ComprasTableTableManager(_$AppDatabase db, $ComprasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> titulo = const Value.absent(),
            Value<String> fecha = const Value.absent(),
          }) =>
              ComprasCompanion(
            id: id,
            titulo: titulo,
            fecha: fecha,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String titulo,
            required String fecha,
          }) =>
              ComprasCompanion.insert(
            id: id,
            titulo: titulo,
            fecha: fecha,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ComprasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({compraDetallesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (compraDetallesRefs) db.compraDetalles
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (compraDetallesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ComprasTableReferences
                            ._compraDetallesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ComprasTableReferences(db, table, p0)
                                .compraDetallesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.compra == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ComprasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ComprasTable,
    Compra,
    $$ComprasTableFilterComposer,
    $$ComprasTableOrderingComposer,
    $$ComprasTableAnnotationComposer,
    $$ComprasTableCreateCompanionBuilder,
    $$ComprasTableUpdateCompanionBuilder,
    (Compra, $$ComprasTableReferences),
    Compra,
    PrefetchHooks Function({bool compraDetallesRefs})>;
typedef $$CompraDetallesTableCreateCompanionBuilder = CompraDetallesCompanion
    Function({
  Value<int> id,
  required String nombre,
  required double precio,
  required int compra,
  required String fecha,
});
typedef $$CompraDetallesTableUpdateCompanionBuilder = CompraDetallesCompanion
    Function({
  Value<int> id,
  Value<String> nombre,
  Value<double> precio,
  Value<int> compra,
  Value<String> fecha,
});

final class $$CompraDetallesTableReferences
    extends BaseReferences<_$AppDatabase, $CompraDetallesTable, CompraDetalle> {
  $$CompraDetallesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ComprasTable _compraTable(_$AppDatabase db) => db.compras.createAlias(
      $_aliasNameGenerator(db.compraDetalles.compra, db.compras.id));

  $$ComprasTableProcessedTableManager get compra {
    final manager = $$ComprasTableTableManager($_db, $_db.compras)
        .filter((f) => f.id($_item.compra!));
    final item = $_typedResult.readTableOrNull(_compraTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CompraDetallesTableFilterComposer
    extends Composer<_$AppDatabase, $CompraDetallesTable> {
  $$CompraDetallesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  $$ComprasTableFilterComposer get compra {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.compra,
        referencedTable: $db.compras,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ComprasTableFilterComposer(
              $db: $db,
              $table: $db.compras,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CompraDetallesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompraDetallesTable> {
  $$CompraDetallesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precio => $composableBuilder(
      column: $table.precio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  $$ComprasTableOrderingComposer get compra {
    final $$ComprasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.compra,
        referencedTable: $db.compras,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ComprasTableOrderingComposer(
              $db: $db,
              $table: $db.compras,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CompraDetallesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompraDetallesTable> {
  $$CompraDetallesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$ComprasTableAnnotationComposer get compra {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.compra,
        referencedTable: $db.compras,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ComprasTableAnnotationComposer(
              $db: $db,
              $table: $db.compras,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CompraDetallesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CompraDetallesTable,
    CompraDetalle,
    $$CompraDetallesTableFilterComposer,
    $$CompraDetallesTableOrderingComposer,
    $$CompraDetallesTableAnnotationComposer,
    $$CompraDetallesTableCreateCompanionBuilder,
    $$CompraDetallesTableUpdateCompanionBuilder,
    (CompraDetalle, $$CompraDetallesTableReferences),
    CompraDetalle,
    PrefetchHooks Function({bool compra})> {
  $$CompraDetallesTableTableManager(
      _$AppDatabase db, $CompraDetallesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompraDetallesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompraDetallesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompraDetallesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<double> precio = const Value.absent(),
            Value<int> compra = const Value.absent(),
            Value<String> fecha = const Value.absent(),
          }) =>
              CompraDetallesCompanion(
            id: id,
            nombre: nombre,
            precio: precio,
            compra: compra,
            fecha: fecha,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
            required double precio,
            required int compra,
            required String fecha,
          }) =>
              CompraDetallesCompanion.insert(
            id: id,
            nombre: nombre,
            precio: precio,
            compra: compra,
            fecha: fecha,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CompraDetallesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({compra = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (compra) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.compra,
                    referencedTable:
                        $$CompraDetallesTableReferences._compraTable(db),
                    referencedColumn:
                        $$CompraDetallesTableReferences._compraTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CompraDetallesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CompraDetallesTable,
    CompraDetalle,
    $$CompraDetallesTableFilterComposer,
    $$CompraDetallesTableOrderingComposer,
    $$CompraDetallesTableAnnotationComposer,
    $$CompraDetallesTableCreateCompanionBuilder,
    $$CompraDetallesTableUpdateCompanionBuilder,
    (CompraDetalle, $$CompraDetallesTableReferences),
    CompraDetalle,
    PrefetchHooks Function({bool compra})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db, _db.compras);
  $$CompraDetallesTableTableManager get compraDetalles =>
      $$CompraDetallesTableTableManager(_db, _db.compraDetalles);
}
