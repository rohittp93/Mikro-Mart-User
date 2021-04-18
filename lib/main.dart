import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:userapp/ui/router.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/appspush.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'core/data/moor_database.dart';
import 'package:provider/provider.dart';
import './ui/shared/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: MikroMartColors.colorPrimaryDark));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(),
        child: Provider(
          create: (context) => AppDatabase(),
          dispose: (context, db) => db.close(),
          child: StreamProvider<FirebaseUserModel>.value(
              value: AuthService().user, child: MaterialAppWithTheme()),
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

    print('FutureBuilder MaterialAppWithTheme building');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemNotifier()),
        ChangeNotifierProvider(create: (context) => StoresNotifier()),
        StreamProvider<List<CartItem>>.value(value: db.watchAllCartItems()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: MikromartRouter.generateRoute,
        initialRoute: '/',
        theme: theme.getTheme(),
        title: 'Mikro Mart',
      ),
    );
  }
}
