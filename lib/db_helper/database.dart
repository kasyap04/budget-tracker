import 'package:sqflite/sqflite.dart' ;

class Sql {
  static Future<Database> db() async {
    return openDatabase(
      'database.db',
      version: 2,
      onCreate: (Database db, int version) async {
        await createSettings(db) ;
        await createCards(db) ;
        await createBudget(db) ;
        await createCategories(db) ;
        await createExpense(db) ;
        await createBudgetDetails(db) ;
      }
    ) ;
  }

  static Future<void> createSettings(Database db) async {
    await db.execute("""
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currency_icon TEXT,
        user_id INT
      )
    """) ;
  }

  static Future<void> createCards(Database db) async {
    await db.execute("""
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT,
        status INT NOT NULL DEFAULT 1
      )
    """) ;
  }

  static Future<void> createBudget(Database db) async {
    await db.execute("""
      CREATE TABLE budget(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_name TEXT,
        start_date TIMESTAMP,
        end_date TIMESTAMP,
        total_amount FLOAT NOT NULL,
        status INT NOT NULL DEFAULT 1
      )
    """) ;
  }

  static Future<void> createCategories(Database db) async {
    await db.execute("""
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT,
        status INT NOT NULL DEFAULT 1
      )
    """) ;
  }

  static Future<void> createExpense(Database db) async {
    await db.execute("""
      CREATE TABLE expense(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT ,
        amount FLOAT NOT NULL,
        category_id INT,
        budget_details_id INT,
        card_id INT,
        quick_expense INT,
        date TIMESTAMP,
        status INT NOT NULL DEFAULT 1
      )
    """) ;
  }

  static Future<void> createBudgetDetails(Database db) async {
    await db.execute("""
      CREATE TABLE budget_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_id INT,
        category_id INT,
        total_amount FLOAT NOT NULL,
        amount_spend FLOAT NOT NULL,
        status INT NOT NULL DEFAULT 1
      )
    """) ;
  }

}