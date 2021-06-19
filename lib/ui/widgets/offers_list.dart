import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/item_quantity.dart';
import 'package:userapp/core/models/version_check.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/custom_page_view.dart';
import 'package:userapp/ui/shared/dottedline.dart';
import 'package:userapp/ui/views/itemDetailNew.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import '../shared/text_styles.dart' as style;

class OffersList extends StatefulWidget {
  @override
  _OffersListState createState() => _OffersListState();
}

class _OffersListState extends State<OffersList> {
  int _current = 0;
  bool isLoading = true;
  bool _isDialogShowing = false;

  Dialog dialog;

  @override
  Future<void> initState() {
    ItemNotifier itemNotifier =
        Provider.of<ItemNotifier>(context, listen: false);
    print('OFFERS INit State Called');

    fetchItems(itemNotifier);

    checkVersion(context);

    super.initState();
  }

  checkVersion(BuildContext context) async {
    Version version = await firebase.checkAppVersion();
    if (version != null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String versionNumber = packageInfo.version;
      print(
          'app version : ${versionNumber} remote version : ${version.current_verion}');

      if (versionNumber != version.current_verion) {
        print(
            'Not the same version. Show non dismissable bottomsheet and redirect to app on playstore');
        showErrorBottomSheet(context,
            'You are using an older version of Mikro Mart. Please update your app');
      } else {
        print('Version up to date');
        if (_isDialogShowing && dialog != null) {
          Navigator.pop(context);
        }
      }
    }
  }

  showErrorBottomSheet(BuildContext context, String message) {
    if (!_isDialogShowing) {
      _isDialogShowing = true;

      dialog = new Dialog(
        child: new Container(
          height: 170.0,
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: MikroMartColors.black,
                      fontSize: 18,
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.normal),
                ),
              ),
              FlatButton(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                onPressed: () {
                  //itemAdded();
                  LaunchReview.launch();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                color: MikroMartColors.colorPrimary,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'UPDATE',
                    style: TextStyle(
                        color: MikroMartColors.white,
                        fontSize: 18,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      );

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: dialog));
    }
  }

  Future<void> fetchItems(ItemNotifier itemNotifier) async {
    await firebase.getItemOffers(itemNotifier);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('OFFERS REFRESHED');
    ItemNotifier itemNotifier = Provider.of<ItemNotifier>(context);
    var screenWidth = MediaQuery.of(context).size.width;

    if (_isDialogShowing) {
      checkVersion(context);
    }

    return itemNotifier.offerItemList.length != 0
        ? Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 0),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Container(
                        width: 113,
                        child: Image(
                          image: AssetImage('assets/flag_bg.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "TOP OFFERS",
                          style: style.headerStyle2
                              .copyWith(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                isLoading
                    ? Container(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()))
                    : itemNotifier.offerItemList.length != 0
                        ? Container(
                            width: double.infinity,
                            height: 250,
                            child: Wrap(
                              children: <Widget>[
                                _buildCarousel(context, itemNotifier),
                              ],
                            ),
                          )
                        : Container(
                            height: 150,
                            padding: EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              0,
                            ),
                            child: Center(
                              child: Text(
                                'There are no offers at the moment',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: MikroMartColors.subtitleGray,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
              ],
            ),
          )
        : Container();
  }

  Widget _buildCarousel(BuildContext context, ItemNotifier itemNotifier) {
    return Column(
      children: <Widget>[
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          child: Container(
            height: 250,
            child: Center(
              child: CustomPageView(
                viewportDirection: false,
                controller: PageController(viewportFraction: 0.6),
                children: _buildOfferWidgets(context, itemNotifier),
                /* children: <Widget>[
                Container(height: 20,color: Colors.indigoAccent,)
              ],*/
              ),
            ),
          ),
        )
      ],
    );
  }
}

_buildOfferWidgets(BuildContext context, ItemNotifier itemNotifier) {
  List<Widget> offersList = [];

  for (var i = 0; i < itemNotifier.offerItemList.length; i++) {
    Item item = itemNotifier.offerItemList[i];

    ItemQuantity displayableItemQuantity = new ItemQuantity();

    for (var j = 0; j < item.item_quantity_list.length; j++) {
      if (item.item_quantity_list[j].display_quantity) {
        displayableItemQuantity = item.item_quantity_list[j];
        break;
      }
    }

    offersList.add(InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ItemDetail(
                      item: item,
                    )));
      },
      child: Padding(
        //padding:  EdgeInsets.fromLTRB(i == 0 ? 16 : 0, 0, i == 0? 0 : 16, 0),
        padding: EdgeInsets.fromLTRB(
            16, 12, i == itemNotifier.offerItemList.length - 1 ? 16 : 0, 12),
        child: Container(
          decoration: new BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: MikroMartColors.cardShadowColor,
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Card(
            color: MikroMartColors.cardBG,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: <Widget>[
                    Hero(
                      tag: item.item_name,
                      child: AspectRatio(
                        aspectRatio: 2 / 1.2,
                        child: Container(
                          width: (MediaQuery.of(context).size.width * 0.6) - 16,
                          color: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: item.item_image_path,
                            fit: BoxFit.fitWidth,
                            placeholder: (context, url) => Center(
                                child: SizedBox(
                              height: 15.0,
                              width: 15.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    MikroMartColors.colorPrimary),
                              ),
                            )),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        displayableItemQuantity.item_mrp != null
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5)),
                                ),
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  calculatePercentage(
                                              displayableItemQuantity
                                                  .item_price,
                                              displayableItemQuantity.item_mrp)
                                          .toString() +
                                      '% OFF',
                                  overflow: TextOverflow.ellipsis,
                                  style: style.itemPriceText.copyWith(
                                      color: MikroMartColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(),
                        Container(
                          color:
                              MikroMartColors.colorPrimaryDark.withOpacity(0.7),
                          width: double.infinity,
                          padding: EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              item.outlet_id,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: style.itemPriceText.copyWith(
                                  color: MikroMartColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text(
                      item.item_name,
                      style: style.mediumTextTitle.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40.0),
                        child: MySeparator(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            '₹ ' + displayableItemQuantity.item_mrp.toString(),
                            style: style.strikeThroughPrice,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Text(
                            '₹ ' +
                                displayableItemQuantity.item_price.toString(),
                            style: TextStyle(
                                color: MikroMartColors.colorPrimary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  return offersList;
}

calculatePercentage(itemRate, mrpRate) {
  if (itemRate != 0.0 && mrpRate != 0.0) {
    if (itemRate == mrpRate) {
      return 0;
    } else {
      if (mrpRate > itemRate) {
        double percentage = (100 - ((itemRate / mrpRate) * 100));
        return percentage.round();
      } else {
        return 0;
      }
    }
  }
}
