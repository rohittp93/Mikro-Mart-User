import 'package:flutter/material.dart';
import '../widgets/top_offer_list.dart';
import 'package:provider/provider.dart';
import '../../locator.dart';
import '../../core/Dish_list.dart';
import '../widgets/home_categories.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FoodList>(
      create: (context) => locator<FoodList>(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: <Widget>[
            TopOfferList(),
            HomeCategories(),
            //DishCategories(),
            //PopularItems()
            Container(padding: EdgeInsets.only(bottom: 100))
          ],
        ),
      ),
    );
  }
}
