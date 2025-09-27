import 'package:guia_05/libros.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Clase "singleton" sirve para manejar todas las operaciones de la base de datos
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance; // Patrón singleton: una sola instancia

  static Database? _database; // Instancia de la base de datos

  DatabaseHelper._internal(); // Constructor interno

  // Getter que asegura que la BD esté inicializada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la BD y crea la tabla en caso de que no exista
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bdlibros.db'); // Ruta de la BD
    return await openDatabase(
      path,
      onCreate: (db, version) {
        // Crea la tabla 'libros' cuando la BD se crea por primera vez
        return db.execute(
          // Crea la tabla libros con los campos (id, tituloLibro)
          "CREATE TABLE libros (id INTEGER PRIMARY KEY AUTOINCREMENT, tituloLibro TEXT)", 
        );
      },
      version: 1
    );
  }

  // Inserta un nuevo libro en la BD
  Future<void> insertLibro(Libro item) async {
    final db = await database;
    await db.insert('libros', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Obtiene todos los libros de la BD
  Future<List<Libro>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('libros');
    // Convierte cada Map de la base de datos a un objeto Libro
    return List.generate(maps.length, (i) {
      return Libro(
        id: maps[i]['id'], 
        tituloLibro: maps[i]['tituloLibro']
      );
    });
  }

  // Elimina un libro de la BD según condiciones específicas
  Future<int> eliminar(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
  
  // Actualiza un libro existente en la BD
  Future<int> actualizar(String table, Map<String, dynamic> values,
  {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }
}