import 'package:flutter/material.dart';
import 'package:userapp/ui/widgets/CusTomAppBar.dart';
import 'package:userapp/ui/widgets/banners_list.dart';
import 'package:userapp/ui/widgets/offers_list.dart';
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
        child: ListView(
          children: <Widget>[
            CustomAppBar(icon: Container(
              width: 180,
              child: new Image.asset(
                'assets/logo_banner.png',
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                fit: BoxFit.contain,
              ),
            ), title: 'Mikro Mart',),
            //TopOfferList(),
            BannersList(),
            OffersList(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: HomeCategories(onViewMoreClicked: onViewMoreClicked),
            ),
            //DishCategories(),
            //PopularItems()
            Container(padding: EdgeInsets.only(bottom: 60))
          ],
        ),
      ),
    );
  }


  @override
  bool get wantKeepAlive => true;
}
