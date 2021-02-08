import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/items_list.dart';
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

  @override
  void initState() {
    CategoriesNotifier _categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);

    firebase.getCategories(_categoriesNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CategoriesNotifier _categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);

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
                  "STORES",
                  style: style.headerStyle2
                      .copyWith(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        _buildCategoriesWidget(_categoriesNotifier, context, _scrollController),
      ],
    );
  }
}

_buildCategoriesWidget(CategoriesNotifier categoriesNotifier,
    BuildContext context, ScrollController scrollController) {
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
            children: List.generate(categoriesNotifier.categoriesList.length,
                (index) {
              Category cat = categoriesNotifier.categoriesList[index];
              return Padding(
                //padding:  EdgeInsets.fromLTRB(i == 0 ? 16 : 0, 0, i == 0? 0 : 16, 0),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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

Route _createRoute(Category category) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ItemsList(
      argument: category,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
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
