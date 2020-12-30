import 'package:moor_flutter/moor_flutter.dart';

part 'moor_database.g.dart';

@DataClassName('CartItem')

class CartItems extends Table {
  TextColumn get itemId => text()();

  TextColumn get cartItemId => text()();

  TextColumn get itemName => text()();

  TextColumn get itemImage => text()();

  TextColumn get itemQuantity => text()();

  TextColumn get outletId => text()();

  RealColumn get itemPrice => real()();

  RealColumn get cartPrice => real()();

  IntColumn get cartQuantity => integer()();

  IntColumn get quantityInStock => integer()();

  IntColumn get maxQuantity => integer()();

  @override
  Set<Column> get primaryKey => {cartItemId};
}

@UseMoor(tables: [CartItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: true));

  @override
  int get schemaVersion => 1;

 /* Future<List<User>> getUsers() => select(users).get();

  //Stream<List<Purpose>> watchAllPurpose() => select(purposes).watch();
  Future insertUser(User user) => into(users).insert(user);

  Future updateUser(User user) => update(users).replace(user);

  Future deleteUser(User user) => delete(users).delete(user);
*/
  Future<List<CartItem>> getCartItems() => select(cartItems).get();

  Stream<List<CartItem>> watchAllCartItems() => select(cartItems).watch();

  Future insertCartItem(CartItem cartItem) => into(cartItems).insert(cartItem);

  Future updateCartItem(CartItem cartItem) =>
      update(cartItems).replace(cartItem);

  Future deleteCartItem(CartItem cartItem) =>
      delete(cartItems).delete(cartItem);

  Future deleteAllCartItems() =>
      delete(cartItems).go();

}
