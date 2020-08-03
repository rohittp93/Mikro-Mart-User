import 'dart:async';

import 'package:flutter/material.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;
import 'package:provider/provider.dart';
import '../views/itemDetails.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;

class TopOfferList extends StatefulWidget {
  @override
  _TopOfferListState createState() => _TopOfferListState();
}

class _TopOfferListState extends State<TopOfferList> {
  //final PageController ctrl = PageController(viewportFraction: 0.8);
  bool isLoading = true;
  double _top = 0;
  final PageController ctrl = PageController(
    viewportFraction: 0.8,
    initialPage: 0,
  );
  int currentPage = 0;

  _buildStoryPage(Item data, bool active, context) {
    final double blur = active ? 18 : 0;
    final double offset = active ? 10 : 0;
    //_top = active ? 10 : 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ItemDetails(
                          data: data,
                        )));
          },
          child: Hero(
            transitionOnUserGestures: true,
            tag: data.item_name,
            child: Stack(
              children: <Widget>[
                AnimatedContainer(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  duration: Duration(milliseconds: 700),
                  curve: Curves.easeOutQuint,
                  margin: EdgeInsets.only(
                      top: _top,
                      bottom: 15,
                      right: MediaQuery.of(context).size.width * 0.1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                          image: NetworkImage(data.item_image_path),
                          fit: BoxFit.cover),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: blur,
                            offset: Offset(offset, offset))
                      ]),
                ),
                data.item_mrp != null
                    ? Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 0,
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(16)),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Text(
                              calculatePercentage(
                                          data.item_price, data.item_mrp)
                                      .toString() +
                                  '% OFF',
                              overflow: TextOverflow.ellipsis,
                              style: style.itemPriceText.copyWith(
                                  color: MikroMartColors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        Container(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    '${data.item_name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style.cardTitleStyle.copyWith(
                        color: MikroMartColors.colorPrimary, fontSize: 20),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            color: MikroMartColors.colorPrimary,
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 7),
                        child: Text(
                          '\₹ ' + data.item_price.toString(),
                          style: style.cardPriceStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  data.item_mrp != null
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            0,
                            20,
                            0,
                          ),
                          child: Container(
                            /*decoration: BoxDecoration(
                color: MikroMartColors.colorPrimary,
                borderRadius: BorderRadius.circular(10)),*/
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 7),
                            child: Text(
                              'MRP \₹ ' + data.item_mrp.toString(),
                              style: style.cardPriceStyle.copyWith(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            ],
          ),
        ),
      ],
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

  @override
  Future<void> initState() {
    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });

    ItemNotifier itemNotifier =
        Provider.of<ItemNotifier>(context, listen: false);

    fetchItems(itemNotifier);

    Timer.periodic(Duration(seconds: 5), (Timer timer) {
     // if (itemNotifier.offerItemList.length > 1) {
        if (currentPage < itemNotifier.offerItemList.length) {
          currentPage++;
        } else {
          currentPage = 0;
        }

        if (ctrl.positions.length > 0) {
          ctrl.animateToPage(
            currentPage,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
     //}
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ItemNotifier itemNotifier = Provider.of<ItemNotifier>(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Text(
                  "Top Offers",
                  style: style.headerStyle2,
                ),
              ),
            ],
          ),
        ),
        Container(
          // height: MediaQuery.of(context).size.height * 0.52,
          height: MediaQuery.of(context).size.width,
          child: isLoading
              ? Center(child: Center(child: CircularProgressIndicator()))
              : itemNotifier.offerItemList.length != 0
                  ? PageView.builder(
                      controller: ctrl,
                      itemCount: itemNotifier.offerItemList.length,
                      itemBuilder: (context, index) {
                        bool active = index == currentPage;
                        return _buildStoryPage(
                            itemNotifier.offerItemList[index], active, context);
                      },
                    )
                  : Container(
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
        )
      ],
    );
  }

  Future<void> fetchItems(ItemNotifier itemNotifier) async {
    await firebase.getItemOffers(itemNotifier);

    setState(() {
      isLoading = false;
    });
  }
}
