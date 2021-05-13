import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/items_list.dart';
import '../shared/text_styles.dart' as style;
import 'package:provider/provider.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;

class StoresScreen extends StatefulWidget {
  //final Function onViewMoreClicked;
  final String categoryId;

  const StoresScreen({this.categoryId});

  @override
  _StoresScreenState createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  ScrollController _scrollController = ScrollController();
  List<Store> _stores = [];
  bool isMikroMart = false;

  @override
  void initState() {
    StoresNotifier _categoriesNotifier =
        Provider.of<StoresNotifier>(context, listen: false);

    /**
     * Check if category is 'MIKRO MART', populate to ItemsList screen with an extra parameter(boolean: isMikroMart).
     * This boolean will help in showing all items under mikromart in ItemsList screen. Also, Search functionality should search for all items under mikromart category
     */
    
    isMikroMart = widget.categoryId == 'MIKRO MART';
    _stores = _categoriesNotifier.getStoreWithCatId(widget.categoryId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: isMikroMart ? ItemsList(
            stores: _stores,
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Container(
                    color: MikroMartColors.colorPrimary,
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 16),
                            width: 50,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                widget.categoryId,
                                style: style.headerStyle2.copyWith(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              _buildCategoriesWidget(_stores, context, _scrollController),
            ],
          ),
        ),
      ),
    );
  }
}

_buildCategoriesWidget(List<Store> stores, BuildContext context,
    ScrollController scrollController) {
  return Container(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GridView.count(
            controller: scrollController,
            physics: ScrollPhysics(),
            crossAxisCount: 2,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(left: 6, right: 6),
            childAspectRatio: 156 / 158,
            shrinkWrap: true,
            children: List.generate(stores.length, (index) {
              Store cat = stores[index];
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 16 : 0),
                //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                  /*decoration: new BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: MikroMartColors.cardShadowColor,
                          spreadRadius: 0.001,
                          blurRadius: 10,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),*/
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(_createRoute(cat));
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      color: MikroMartColors.cardBG,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 2,
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
                              AspectRatio(
                                aspectRatio: 2 / 1.2,
                                child: Container(
                                  width: (MediaQuery.of(context).size.width *
                                          0.6) -
                                      16,
                                  color: Colors.white,
                                  child: CachedNetworkImage(
                                    imageUrl: cat.category_image_path,
                                    fit: BoxFit.fitWidth,
                                    placeholder: (context, url) => Center(
                                        child: SizedBox(
                                      height: 15.0,
                                      width: 15.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                MikroMartColors.colorPrimary),
                                      ),
                                    )),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Text(
                                  cat.category_name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: style.outletCardNameStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );
}

Route _createRoute(Store category) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ItemsList(
      passedStore: category,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1, 0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
