import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
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
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 16, top: 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Text(
                  "Categories",
                  style: style.headerStyle2,
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
          SizedBox(
            height: 5,
          ),
          GridView.count(
            controller: scrollController,
            physics: ScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2 / 1.2,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: List.generate(categoriesNotifier.categoriesList.length,
                (index) {
              Category cat = categoriesNotifier.categoriesList[index];
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      children: <Widget>[
                        Image(
                          image: NetworkImage(cat.category_image_path),
                          fit: BoxFit.cover,
                        ),
                        AspectRatio(
                          aspectRatio: 2/1.2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0.1, 0.7],
                                colors: [
                                  Color.fromARGB(90, 0, 0, 0),
                                  Color.fromARGB(100, 0, 0, 0),
                                ],
                              ),
                            ),
                            height: MediaQuery.of(context).size.height / 6,
                            width: MediaQuery.of(context).size.height / 6,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            print('Tapped on category');
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) => new ItemsList(
                                      argument:
                                      categoriesNotifier.categoriesList[index],
                                    )));
                          },
                          child: AspectRatio(
                            aspectRatio: 2/1.2,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(2, 0, 2, 10),
                              constraints: BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  cat.category_name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  /* ListView.builder(
      primary: false,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: categoriesNotifier.categoriesList == null
          ? 0
          : categoriesNotifier.categoriesList.length,
      itemBuilder: (BuildContext context, int index) {
        Category cat = categoriesNotifier.categoriesList[index];

        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: <Widget>[
                  Image(
                    image: NetworkImage(cat.category_image_path),
                    fit: BoxFit.cover,
                  ),
                  AspectRatio(
                    aspectRatio: 2/1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // Add one stop for each color. Stops should increase from 0 to 1
                          stops: [0.1, 0.7],
                          colors: [
                            Color.fromARGB(90, 0, 0, 0),
                            Color.fromARGB(100, 0, 0, 0),
                          ],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height / 6,
                      width: MediaQuery.of(context).size.height / 6,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      print('Tapped on category');
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new ItemsList(
                                    argument:
                                        categoriesNotifier.categoriesList[index],
                                  )));
                    },
                    child: AspectRatio(
                      aspectRatio: 2/1.2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(2, 0, 2, 10),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            cat.category_name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),*/
}

/*
_buildCategoriesWidget(
    CategoriesNotifier categoriesNotifier, BuildContext context) {
  return Container(
    height: 110,
    child: ListView.builder(
      primary: false,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: categoriesNotifier.categoriesList == null
          ? 0
          : categoriesNotifier.categoriesList.length,
      itemBuilder: (BuildContext context, int index) {
        Category cat = categoriesNotifier.categoriesList[index];

        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: <Widget>[
                  Image(
                    image: NetworkImage(cat.category_image_path),
                    fit: BoxFit.cover,
                  ),
                  AspectRatio(
                    aspectRatio: 2/1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // Add one stop for each color. Stops should increase from 0 to 1
                          stops: [0.1, 0.7],
                          colors: [
                            Color.fromARGB(90, 0, 0, 0),
                            Color.fromARGB(100, 0, 0, 0),
                          ],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height / 6,
                      width: MediaQuery.of(context).size.height / 6,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      print('Tapped on category');
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new ItemsList(
                                    argument:
                                        categoriesNotifier.categoriesList[index],
                                  )));
                    },
                    child: AspectRatio(
                      aspectRatio: 2/1.2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(2, 0, 2, 10),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            cat.category_name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
*/
