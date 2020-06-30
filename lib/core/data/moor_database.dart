import 'package:moor_flutter/moor_flutter.dart';

part 'moor_database.g.dart';

@DataClassName('User')
class Users extends Table {
 TextColumn get uid => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  BoolColumn get phoneValidated => boolean()();


  @override
  Set<Column> get primaryKey => {uid};
}


@UseMoor(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
      path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

  Future<List<User>> getUsers() => select(users).get();
  //Stream<List<Purpose>> watchAllPurpose() => select(purposes).watch();
  Future insertUser(User user) => into(users).insert(user);
  Future updateUser(User user) => update(users).replace(user);
  Future deleteUser(User user) => delete(users).delete(user);
}
