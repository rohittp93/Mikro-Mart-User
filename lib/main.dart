import 'package:flutter/material.dart';

import 'core/card_list_model.dart';
import 'core/card_model.dart';
import 'locator.dart';
import 'package:provider/provider.dart';
import './ui/shared/theme.dart';
import './ui/router.dart';

void main() {
  setupLocator() ;
  runApp(MyApp()) ;
}
class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      builder: (_) => ThemeChanger(),
      child: MaterialAppWithTheme(),
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => locator<CardListModelView>()),
        ChangeNotifierProvider(builder: (context) => locator<CardModel>()),
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

