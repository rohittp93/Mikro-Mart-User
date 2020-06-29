import 'package:get_it/get_it.dart';

import './core/Dish_list.dart';
import './core/card_model.dart';
import './core/card_list_model.dart';
import 'core/services/auth.dart';

GetIt locator = GetIt();

void setupLocator() {
  locator.registerFactory(() => FoodList()) ;
  locator.registerLazySingleton(() => CardListModelView());
  locator.registerLazySingleton(() => CardModel()) ;

/*  locator.registerLazySingleton(
          () => AuthService());*/
}