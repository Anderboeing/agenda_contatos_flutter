import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imageColumn = "imageColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  //criando banco de dados
  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async {
    String databasesPath;

    if (kIsWeb) {
      // Web não é suportado. Rode o app em Windows ou Android.
      throw UnsupportedError(
        'SQLite não é suportado no navegador. Use flutter run -d windows ou um emulador Android.',
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop: usa sqflite_common_ffi
      sqfliteFfiInit();
      databasesPath = await databaseFactoryFfi.getDatabasesPath();
      final path = join(databasesPath, "contactsNew.db");
      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int newerVersion) async {
            await db.execute(
              "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imageColumn TEXT)",
            );
          },
        ),
      );
    } else {
      // Mobile (Android / iOS): usa sqflite nativo
      databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "contactsNew.db");
      return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int newerVersion) async {
          await db.execute(
            "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imageColumn TEXT)",
          );
        },
      );
    }
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    List<Map<String, Object?>> result = await dbContact.rawQuery(
      'SELECT COUNT(*) FROM $contactTable',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id = 0;
  String name = "";
  String email = "";
  String phone = "";
  String image = "";

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn] ?? 0;
    name = map[nameColumn] ?? "";
    email = map[emailColumn] ?? "";
    phone = map[phoneColumn] ?? "";
    image = map[imageColumn] ?? "";
  }

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image,
    };
    // Só inclui o id se o contato já existir no banco.
    // Se id == 0, o SQLite gera o id automaticamente (autoincrement).
    if (id != 0) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, image: $image)";
  }
}
