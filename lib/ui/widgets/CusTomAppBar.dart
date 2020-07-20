import 'package:flutter/material.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;


class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  CustomAppBar({Key key, @required this.title}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return  Container(
        height: 100,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
            /*  GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/shoppingCart');
                  },
                  child: Icon(Icons.shopping_cart, size: 32)),*/
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: style.appBarTextTheme,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(90);
}
