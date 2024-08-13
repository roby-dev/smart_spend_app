import 'package:smart_spend_app/models/compra_detalle_model.dart';
import 'package:smart_spend_app/models/compra_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'compras.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE compra (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            fecha TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE compra_detalle (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            precio REAL,
            compra_id INTEGER,
            fecha TEXT,
            FOREIGN KEY (compra_id) REFERENCES compra (id)
          )
        ''');
      },
    );
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<int> insertCompra(Compra compra) async {
    final db = await database;
    return await db.insert(
      'compra',
      compra.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCompraDetalle(CompraDetalle detalle) async {
    final db = await database;
    await db.insert(
      'compra_detalle',
      detalle.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Compra>> getCompras() async {
    final db = await database;
    final List<Map<String, dynamic>> compraMaps = await db.query('compra');

    List<Compra> comprasConDetalles = [];

    for (var compraMap in compraMaps) {
      Compra compra = Compra.fromJson(compraMap);
      final List<CompraDetalle> detalles =
          await getCompraDetalleDeCompra(compra.id!);
      Compra compraConDetalles = compra.copyWith(detalles: detalles);
      comprasConDetalles.add(compraConDetalles);
    }

    return comprasConDetalles;
  }

  Future<List<CompraDetalle>> getCompraDetalleDeCompra(int compraId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'compra_detalle',
      where: 'compra_id = ?',
      whereArgs: [compraId],
    );

    return maps.map((map) => CompraDetalle.fromJson(map)).toList();
  }

  Future<List<CompraDetalle>> getCompraDetalles(int compraId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'compra_detalle',
      where: 'compra_id = ?',
      whereArgs: [compraId],
    );

    return maps.map((map) => CompraDetalle.fromJson(map)).toList();
  }

  Future<void> deleteCompra(int id) async {
    final db = await database;
    await db.delete(
      'compra',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'compra_detalle',
      where: 'compra_id = ?',
      whereArgs: [id],
    );
  }

  // Add this method to delete a specific CompraDetalle by its id
  Future<void> deleteCompraDetalle(int id) async {
    final db = await database;
    await db.delete(
      'compra_detalle',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
