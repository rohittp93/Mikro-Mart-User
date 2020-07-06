import 'package:flutter/material.dart';
import '../shared/text_styles.dart' as style;

class TitleAppBar extends StatelessWidget {
  final String title;

  Size size;

  TitleAppBar({@required this.title});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(left: 0.0, top:8, bottom:8, right: 18.0),
      child: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
              Container(
                width: 70,
                child: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                ),
            ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Text(
                this.title,
                style: style.appBarTextTheme,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
