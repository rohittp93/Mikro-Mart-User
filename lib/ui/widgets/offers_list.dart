import 'package:carousel_slider/carousel_slider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/models/item_quantity.dart';
import 'package:userapp/core/models/version_check.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;
import 'package:userapp/ui/shared/colors.dart';
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
        if(_isDialogShowing && dialog!=null){
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
          builder: (_) => dialog);
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
    ItemNotifier itemNotifier = Provider.of<ItemNotifier>(context);
    var screenWidth = MediaQuery.of(context).size.width;

    if(_isDialogShowing){
      checkVersion(context);
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              "TOP OFFERS",
              style: style.headerStyle2,
            ),
          ),
          isLoading
              ? Container(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()))
              : itemNotifier.offerItemList.length != 0
                  ? CarouselSlider(
                      items: itemNotifier.offerItemList.map((item) {
                        ItemQuantity displayableItemQuantity =
                            new ItemQuantity();

                        for (var i = 0;
                            i < item.item_quantity_list.length;
                            i++) {
                          if (item.item_quantity_list[i].display_quantity) {
                            displayableItemQuantity =
                                item.item_quantity_list[i];
                            break;
                          }
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ItemDetails(
                                          data: item,
                                        )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Card(
                              elevation: 2,
                              child: Container(
                                child: Container(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                            child: Stack(
                                              children: <Widget>[
                                                Center(
                                                  child: Image.network(
                                                    item.item_image_path,
                                                    fit: BoxFit.cover,
                                                    width: screenWidth * 0.7,
                                                  ),
                                                ),
                                                displayableItemQuantity
                                                            .item_mrp !=
                                                        null
                                                    ? Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: 0,
                                                          ),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius.only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              5)),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12),
                                                            child: Text(
                                                              calculatePercentage(
                                                                          displayableItemQuantity
                                                                              .item_price,
                                                                          displayableItemQuantity
                                                                              .item_mrp)
                                                                      .toString() +
                                                                  '% OFF',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: style
                                                                  .itemPriceText
                                                                  .copyWith(
                                                                      color: MikroMartColors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 80,
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Flexible(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 12,
                                                            ),
                                                            child: Text(
                                                              item.item_name,
                                                              //'Some big offer name which might take two lines',
                                                              style: TextStyle(
                                                                color: MikroMartColors
                                                                    .colorPrimary,
                                                                fontSize: 16.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        displayableItemQuantity
                                                                    .item_mrp !=
                                                                null
                                                            ? Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                  0,
                                                                  0,
                                                                  20,
                                                                  0,
                                                                ),
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              4,
                                                                          left:
                                                                              12),
                                                                  child: Text(
                                                                    'MRP \₹ ' +
                                                                        displayableItemQuantity
                                                                            .item_mrp
                                                                            .toString(),
                                                                    style: style
                                                                        .cardPriceStyle
                                                                        .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 12, left: 6),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: MikroMartColors
                                                              .colorPrimary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6)),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12,
                                                              horizontal: 7),
                                                      child: Text(
                                                        '\₹ ' +
                                                            displayableItemQuantity
                                                                .item_price
                                                                .toString(),
                                                        style: style
                                                            .cardPriceStyle
                                                            .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                          autoPlay: itemNotifier.offerItemList.length <= 1
                              ? false
                              : true,
                          autoPlayInterval: Duration(milliseconds: 4000),
                          enlargeCenterPage: true,
                          height: (((0.7 * screenWidth) * 1.2) / 2) + 80,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
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
          itemNotifier.offerItemList.length != 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: itemNotifier.offerItemList.map((url) {
                    int index = itemNotifier.offerItemList.indexOf(url);
                    return Container(
                      width: 6.0,
                      height: 6.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                )
              : Container(),
        ],
      ),
    );
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
}
