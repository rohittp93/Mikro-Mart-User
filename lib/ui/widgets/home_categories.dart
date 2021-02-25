import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/models/outlet_type.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/items_list.dart';
import 'package:userapp/ui/widgets/stores_scren.dart';
import '../shared/text_styles.dart' as style;
import 'package:provider/provider.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;

class HomeCategories extends StatefulWidget {
  final Function onViewMoreClicked;

  const HomeCategories({Key key, this.onViewMoreClicked}) : super(key: key);

  @override
  _HomeCategoriesState createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  ScrollController _scrollController = ScrollController();
  List<OutletType> _outletTypes = [];
  List<OutletType> _outletTypesWithoutMikroMart = [];
  OutletType _mikroMartOutlet;

  @override
  void initState() {
    fetchOutletTypes();

    StoresNotifier notifier =
        Provider.of<StoresNotifier>(context, listen: false);

    firebase.getStores(notifier);

    super.initState();
  }

  fetchOutletTypes() async {
    _outletTypes = await firebase.getCategories();

    for (OutletType outletType in _outletTypes) {
      if (outletType.category_name != 'MIKRO MART') {
        _outletTypesWithoutMikroMart.add(outletType);
      } else {
        _mikroMartOutlet = outletType;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
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
                  "CATEGORIES",
                  style: style.headerStyle2
                      .copyWith(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        _mikroMartOutlet != null
            ? InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(_createStoreRoute(_mikroMartOutlet.category_name));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 6),
                  child: Card(
                    color: MikroMartColors.cardBG,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 1 / 0.34,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                color: MikroMartColors.brightRed,
                                child: new Image.asset(
                                  'assets/mikromart_category.jpg',
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),

                                /*CachedNetworkImage(
                                  imageUrl: _mikroMartOutlet.category_image_path,
                                  fit: BoxFit.contain,
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
                                ),*/
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: Text(
                              _mikroMartOutlet.category_name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: style.outletCardNameStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
        _buildCategoriesWidget(
            _outletTypesWithoutMikroMart, context, _scrollController),
      ],
    );
  }
}

_buildCategoriesWidget(List<OutletType> outletTypes, BuildContext context,
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
            children: List.generate(outletTypes.length, (index) {
              OutletType outletType = outletTypes[index];
              return Padding(
                //padding:  EdgeInsets.fromLTRB(i == 0 ? 16 : 0, 0, i == 0? 0 : 16, 0),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                  child: InkWell(
                    onTap: () {
                      //TODO : Navigate to stores list with outlet id
                      //Navigator.of(context).push(_createRoute(cat));
                      Navigator.of(context)
                          .push(_createStoreRoute(outletType.category_name));
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
                                  /*width: (MediaQuery.of(context).size.width *
                                          0.6) -
                                      16,*/
                                  color: Colors.white,
                                  child: CachedNetworkImage(
                                    imageUrl: outletType.category_image_path,
                                    fit: BoxFit.contain,
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
                                  outletType.category_name,
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

Route _createStoreRoute(String categoryId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => StoresScreen(
      categoryId: categoryId,
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
