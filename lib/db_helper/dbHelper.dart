import 'dart:async';
import 'dart:io';

import 'package:flutter_payment_app/model/product.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "ModiSamaj.db";
  static const _databaseVersion = 1;

  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDb);
  }

  _onCreateDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${ProductModel.tblProduct}(
    ${ProductModel.colID} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${ProductModel.colName} TEXT NOT NULL,
      ${ProductModel.colQty} TEXT NOT NULL,
      ${ProductModel.colPrice} TEXT NOT NULL,
      ${ProductModel.colSelected} TEXT NOT NULL
      )
    ''');
    print("Create table");
    // await db.execute('''
    // CREATE TABLE ${HelpCenterModel.tblHelpCenter}(
    // ${HelpCenterModel.colID} INTEGER PRIMARY KEY AUTOINCREMENT,
    //   ${HelpCenterModel.colName} TEXT NOT NULL,
    //   ${HelpCenterModel.colPhone} TEXT NOT NULL,
    //   ${HelpCenterModel.colDesignation} TEXT NOT NULL,
    //   ${HelpCenterModel.colCity} TEXT NOT NULL,
    //   ${HelpCenterModel.colZone} TEXT NOT NULL
    //   )
    // ''');
    // print("Create table");

  }

  Future<int> insertProduct(ProductModel productModel) async {
    Database? db = await database;
    return await db!.insert(ProductModel.tblProduct, productModel.toMap());
  }

  Future<int> updateUser(ProductModel productModel) async {
    Database? db = await database;
    return await db!.update(ProductModel.tblProduct, productModel.toMap(),
        where: "${ProductModel.colID}=?", whereArgs: [productModel.id]);
  }

  Future<List<ProductModel>> loginUser(String selected) async {
    Database? db = await database;
    List<Map<String, dynamic>> res = await db!.rawQuery(
        "SELECT * FROM ${ProductModel.tblProduct} WHERE ${ProductModel.colSelected} = $selected");
    return res.isNotEmpty ? res.map((e) => ProductModel.fromMap(e)).toList() : [];

    // if (res.isNotEmpty) {
    //   return ProductModel.fromMap(res.first);
    // }
    // return null;
  }

  Future<List<ProductModel>> getProductData() async {
    Database? db = await database;
    List<Map<String, dynamic>> res = await db!.query(ProductModel.tblProduct);
    print(res);
    return res.isNotEmpty ? res.map((e) => ProductModel.fromMap(e)).toList() : [];
  }

  Future<int> deleteHelpData(int id) async {
    Database? db = await database;
    return db!.delete(ProductModel.tblProduct, where: "${ProductModel.colID} = ?", whereArgs: [id]);
  }
}
