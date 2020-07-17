import 'dart:async';
import 'dart:ui';

import 'package:algolia/algolia.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/helpers/algolia.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import 'package:userapp/ui/views/items_list.dart';
import '../shared/text_styles.dart' as style;
import 'package:userapp/core/services/firebase_service.dart' as firebase;

class SearchPanel extends StatefulWidget {
  @override
  _SearchPanelState createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  var _controller = TextEditingController();
  String searchString = '';
  bool _isLoading = false;
  bool _isSearching = false;
  ScrollController _scrollController = ScrollController();
  List<Item> _searchedProducts = [];
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  Timer _debounce;
  StreamSubscription<List<AlgoliaObjectSnapshot>> _searchSnapShotsStream;


  @override
  void initState() {
    CategoriesNotifier _categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);

    //firebase.getCategories(_categoriesNotifier);
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // do something with _searchQuery.text
      if (searchString.isNotEmpty) _submitSearch(searchString);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CategoriesNotifier _categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    color: MikroMartColors.colorPrimary.withOpacity(0.1),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 10.0),
                        child: Material(
                          elevation: 2.0,
                          borderRadius: BorderRadius.circular(8.0),
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.search,
                            onChanged: (val) {
                              setState(() {
                                if (val.isEmpty) {
                                  _isSearching = false;
                                  _isLoading = false;
                                } else {
                                  _isLoading = true;
                                }
                                searchString = val;
                              });
                              //if (val.isNotEmpty) _submitSearch(val);
                            },
                            onSubmitted: (val) async {
                              //_submitSearch(val);
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: searchString.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _controller.clear();
                                          setState(() {
                                            searchString = '';
                                            _isSearching = false;
                                          });
                                        },
                                        icon: Icon(Icons.clear),
                                      )
                                    : Icon(Icons.search),
                                /*suffixIcon: searchString.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          //_submitSearch(this.searchString);
                                        },
                                        icon: Image.asset(
                                          "assets/next.png",
                                        ),
                                      )
                                    : null,*/
                                contentPadding: EdgeInsets.only(
                                    left: 16.0, top: 16.0, bottom: 16.0),
                                hintText: 'Search item',
                                hintStyle: TextStyle(
                                    color: Theme.of(context).hintColor)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            "or navigate by category",
                            style: style.subHeaderStyle
                                .copyWith(color: MikroMartColors.colorPrimary),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(color: MikroMartColors.transparentGray),
                      Stack(
                        children: <Widget>[
                          _isLoading
                              ? Flexible(
                                  flex: 1,
                                  child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SizedBox(height: 30, width: 30,child: CircularProgressIndicator()),
                                      )))
                              : _isSearching
                                  ? GridView.count(
                                      controller: _scrollController,
                                      physics: ScrollPhysics(),
                                      crossAxisCount: 2,
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      children: List.generate(
                                          _searchedProducts.length, (index) {
                                        Item item = _searchedProducts[index];
                                        return Card(
                                          elevation: 2,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          ItemDetails(
                                                            data: item,
                                                          )));
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Hero(
                                                  transitionOnUserGestures:
                                                      true,
                                                  tag: item.item_name,
                                                  child: Image(
                                                    image: NetworkImage(
                                                        item.item_image_path),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8,
                                                          bottom: 8,
                                                          top: 16),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          item.item_name,
                                                          style: style
                                                              .mediumTextTitle,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          '₹ ' +
                                                              item.item_price
                                                                  .toString(),
                                                          style: style
                                                              .mediumTextSubtitle,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    )
                                  : ListView.separated(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          title: Text(_categoriesNotifier
                                              .categoriesList[index]
                                              .category_name),
                                          trailing:
                                              Icon(Icons.keyboard_arrow_right),
                                          onTap: () {
                                            //Navigator.pushNamed(context, '/itemList', arguments: _categoriesNotifier.categoriesList[index]) ;
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        new ItemsList(
                                                          argument:
                                                              _categoriesNotifier
                                                                      .categoriesList[
                                                                  index],
                                                        )));
                                          },
                                        );
                                      },
                                      itemCount: _categoriesNotifier
                                          .categoriesList.length,
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Divider(
                                            color: MikroMartColors
                                                .transparentGray);
                                      },
                                    ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitSearch(String val) async {
    setState(() {
      _isLoading = true;
    });

    _searchedProducts.clear();

    if (_searchSnapShotsStream != null) _searchSnapShotsStream.cancel();

    //List<AlgoliaObjectSnapshot> snapShots = await _operation(val);

    _searchSnapShotsStream = _operation(val).asStream().listen((snapShots) {
      for (var i = 0; i < snapShots.length; i++) {
        AlgoliaObjectSnapshot snap = snapShots[i];
        Map<String, dynamic> highlightResult = snap.highlightResult;

        Item item = Item.fromSearchMap(highlightResult, 'id');
        _searchedProducts.add(item);
      }

      setState(() {
        _isLoading = false;
        if (val.length != 0) {
          _isSearching = true;
        } else {
          _isSearching = false;
        }
      });
    });


    /*for (var i = 0; i < snapShots.length; i++) {
      AlgoliaObjectSnapshot snap = snapShots[i];
      Map<String, dynamic> highlightResult = snap.highlightResult;

      Item item = Item.fromSearchMap(highlightResult, 'id');

      print('ITEM -> ${item.item_name}');

      _searchedProducts.add(item);
    }

    setState(() {
      _isLoading = false;
      if (_searchedProducts.length != 0) {
        _isSearching = true;
      } else {
        _isSearching = false;
      }
    });*/
  }

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("items").search(input);
    AlgoliaQuerySnapshot querySnapshots = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnapshots.hits;
    return results;
  }
}
