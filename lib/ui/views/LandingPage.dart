import 'package:flutter/material.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/widgets/CusTomAppBar.dart';
import 'package:userapp/ui/widgets/banners_list.dart';
import 'package:userapp/ui/widgets/offers_list.dart';
import '../widgets/top_offer_list.dart';
import 'package:provider/provider.dart';
import '../widgets/home_categories.dart';

class LandingPage extends StatelessWidget {
  final Function onViewMoreClicked;

  const LandingPage({Key key, this.onViewMoreClicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print('LANDINGPAGE REFRESHED');
    ItemNotifier itemNotifier =
        Provider.of<ItemNotifier>(context, listen: false);
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: MikroMartColors.colorPrimary,
                height: 55,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Image.asset(
                    'assets/logo_banner.png',
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              //TopOfferList(),
              BannersList(),
              /*itemNotifier.offerItemList.length != 0
                    ? */OffersList(),
              //: Container(),
              HomeCategories(onViewMoreClicked: onViewMoreClicked),
              Container(padding: EdgeInsets.only(bottom: 100))
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
