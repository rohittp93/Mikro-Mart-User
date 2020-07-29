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
  final PageController ctrl = PageController(viewportFraction: 0.8,
    initialPage: 0,
  );
  int currentPage = 0;
  _buildStoryPage(Item data, bool active, context) {
    final double blur = active ? 18 : 0;
    final double offset = active ? 12 : 0;
    final double top = active ? 10 : 50;

    return Column(
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
            child: AnimatedContainer(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.45 - top - 7 - 8,
              duration: Duration(milliseconds: 700),
              curve: Curves.easeOutQuint,
              margin: EdgeInsets.only(
                  top: top,
                  bottom: 15,
                  right: MediaQuery.of(context).size.width * 0.1),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
          ),
        ),
        Container(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '${data.item_name}',
                  style: style.cardTitleStyle
                      .copyWith(color: MikroMartColors.colorPrimary),

                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: MikroMartColors.colorPrimary,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 7),
                  child: Text(
                    '\₹ ' + data.item_price.toString(),
                    style: style.cardPriceStyle.copyWith(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  void initState() {
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

    firebase.getItemOffers(itemNotifier);


    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (currentPage < itemNotifier.offerItemList.length) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      ctrl.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
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
             /* InkWell(
                onTap: () {},
                child: Text(
                  "View More",
                  style: style.subHeaderStyle
                      .copyWith(color: MikroMartColors.colorPrimary),
                ),
              )*/
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.52,
          child: PageView.builder(
            controller: ctrl,
            itemCount: itemNotifier.offerItemList.length,
            itemBuilder: (context, index) {
              bool active = index == currentPage;
              return _buildStoryPage(
                  itemNotifier.offerItemList[index], active, context);
            },
          ),
        )
      ],
    );
  }
}
