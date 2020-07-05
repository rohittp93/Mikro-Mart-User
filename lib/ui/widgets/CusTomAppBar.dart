import 'package:flutter/material.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;


class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
                    "Mikro Mart",
                    style: style.appBarTextTheme,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              /*GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, '/notification') ;
                },
                child: Icon(
                  Icons.notifications_none,
                  size: 32,
                ),
              ),*/
            ],
          ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(90);
}
