import 'package:flutter/material.dart';
import 'package:userapp/ui/widgets/CusTomAppBar.dart';
import '../widgets/top_offer_list.dart';
import 'package:provider/provider.dart';
import '../../locator.dart';
import '../../core/Dish_list.dart';
import '../widgets/home_categories.dart';

class LandingPage extends StatelessWidget {
  final Function onViewMoreClicked;

  const LandingPage({Key key, this.onViewMoreClicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FoodList>(
      create: (context) => locator<FoodList>(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: <Widget>[
            CustomAppBar(title: 'Mikro Mart',),
            TopOfferList(),
            HomeCategories(onViewMoreClicked: onViewMoreClicked),
            //DishCategories(),
            //PopularItems()
            Container(padding: EdgeInsets.only(bottom: 100))
          ],
        ),
      ),
    );
  }


  @override
  bool get wantKeepAlive => true;
}
