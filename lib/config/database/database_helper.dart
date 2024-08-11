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
            FOREIGN KEY (compra_id) REFERENCES compra (id)
          )
        ''');
      },
    );
  }

  Future<void> initDatabase() async {
    // Llama a database para asegurarte de que la base de datos está inicializada
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

    // Lista para almacenar las compras con nombres de detalles
    List<Compra> comprasConDetalles = [];

    // Itera sobre cada compra recuperada
    for (var compraMap in compraMaps) {
      // Crea una instancia de Compra desde el mapa
      Compra compra = Compra.fromJson(compraMap);

      // Obtén los nombres de los detalles para esta compra
      final List<String> nombresDetalles =
          await getCompraDetalleNombres(compra.id!);

      // Crea una nueva instancia de Compra con la lista de nombres de detalles
      Compra compraConDetalles =
          compra.copyWith(nombresDetalles: nombresDetalles);

      // Añade la compra con detalles a la lista
      comprasConDetalles.add(compraConDetalles);
    }

    return comprasConDetalles;
  }

  Future<List<String>> getCompraDetalleNombres(int compraId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'compra_detalle',
      columns: ['nombre'],
      where: 'compra_id = ?',
      whereArgs: [compraId],
    );

    // Extraer los nombres de los mapas y devolverlos como una lista de strings
    return maps.map((map) => map['nombre'] as String).toList();
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
    // Opcionalmente elimina los detalles asociados
    await db.delete(
      'compra_detalle',
      where: 'compra_id = ?',
      whereArgs: [id],
    );
  }
}
