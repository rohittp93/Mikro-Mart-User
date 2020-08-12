import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../shared/text_styles.dart' as style;

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final Widget icon;

  CustomAppBar({Key key, @required this.title, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: icon!=null ? EdgeInsets.only(top: 25, bottom: 25): EdgeInsets.only(top: 15, bottom: 15),
      child: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Center(
                child: icon == null
                    ? Text(
                        title,
                        style: style.appBarTextTheme,
                        textAlign: TextAlign.center,
                      )
                    : icon,
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
