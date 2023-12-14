import 'package:segadi/model/status_support.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class StatusDatabase {
  static final StatusDatabase instance = StatusDatabase._init();

  static Database? _database;
  StatusDatabase._init();

  final String tableStatusSupport = 'status_support';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('test.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE  $tableStatusSupport( service_id TEXT NULL, status_id TEXT NULL, type TEXT NULL)''');
  }

  Future<List<StatusSupport>> getAllStatus() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableStatusSupport);

    var listResult = List.generate(maps.length, (i) {
      return StatusSupport(
          serviceId: maps[i]['service_id'],
          statusId: maps[i]['status_id'],
          type: maps[i]['type']);
    });

    return listResult;
  }

  Future<List<StatusSupport>> getStatus(serviceId) async {
    // get a reference to the database
    final db = await instance.database;

    // get all rows
    List<Map<String, dynamic>> maps =
        await db.query("$tableStatusSupport WHERE service_id=$serviceId");
    /*List<StatusSupport> list = res.isNotEmpty
        ? res.map((c) => StatusSupport.fromJson(c)).toList()
        : [];

    return list;*/

    return List.generate(maps.length, (i) {
      return StatusSupport(
          serviceId: maps[i]['service_id'],
          statusId: maps[i]['status_id'],
          type: maps[i]['type']);
    });
  }

  Future<void> insert(StatusSupport status) async {
    final db = await instance.database;
    await db.insert(tableStatusSupport, status.toMap());
  }

  Future<int> deleteStatus(int id) async {
    final db = await instance.database;
    return await db
        .delete(tableStatusSupport, where: 'service_id=?', whereArgs: [id]);
  }
}
