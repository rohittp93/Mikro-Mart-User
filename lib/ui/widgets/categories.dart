import 'package:flutter/material.dart';
import '../shared/text_styles.dart' as style;
import 'package:provider/provider.dart';
import '../../core/Dish_list.dart';


class DishCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: 16,top: 24),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Text(
                "Category",
                style: style.headerStyle2,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                "View More",
                style: style.subHeaderStyle
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
      ),
      Consumer<FoodList>(
        builder: (context,model,child) {
          return  Container(
            height: MediaQuery.of(context).size.height/6,
            child: ListView.builder(
              primary: false,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: model.cuisines == null ? 0:model.cuisines.length,
              itemBuilder: (BuildContext context, int index) {
                Map cat = model.cuisines[index];

                return Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          cat["img"],
                          height: MediaQuery.of(context).size.height/6,
                          width: MediaQuery.of(context).size.height/6,
                          fit: BoxFit.cover,
                        ),

                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [0.2, 0.7],
                              colors: [
                                Color.fromARGB(100, 0, 0, 0),
                                Color.fromARGB(100, 0, 0, 0),
                              ],
                              // stops: [0.0, 0.1],
                            ),
                          ),
                          height: MediaQuery.of(context).size.height/6,
                          width: MediaQuery.of(context).size.height/6,
                        ),


                        Center(

                          child: Container(
                            height: MediaQuery.of(context).size.height/6,
                            width: MediaQuery.of(context).size.height/6,
                            padding: EdgeInsets.all(1),
                            constraints: BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                cat["cuisine"],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

    ],);
  }
}
