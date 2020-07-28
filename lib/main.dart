import 'package:flutter/material.dart';
import 'package:userapp/appspush.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/firebase_service.dart';

import 'core/card_list_model.dart';
import 'core/card_model.dart';
import 'core/data/moor_database.dart';
import 'locator.dart';
import 'package:provider/provider.dart';
import './ui/shared/theme.dart';
import './ui/router.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppPushs(
      child: ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(),
        child: Provider(
          create: (context) => AppDatabase(),
          dispose: (context, db) => db.close(),
          child: StreamProvider<FirebaseUserModel>.value(
              value: AuthService().user, child: MaterialAppWithTheme()),
        ),
      ),
    );
  }
}

class MaterialAppWithTheme extends StatefulWidget {
  @override
  _MaterialAppWithThemeState createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    AppDatabase db = Provider.of<AppDatabase>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => locator<CardListModelView>()),
        ChangeNotifierProvider(create: (context) => locator<CardModel>()),
        ChangeNotifierProvider(create: (context) => ItemNotifier()),
        ChangeNotifierProvider(create: (context) => CategoriesNotifier()),
        StreamProvider<List<CartItem>>.value(value: db.watchAllCartItems()),
      ],
      child: MaterialApp(
        onGenerateRoute: Router.generateRoute,
        initialRoute: '/splashScreen',
        theme: theme.getTheme(),
        title: 'Restaurant Template',
      ),
    );
  }
}
