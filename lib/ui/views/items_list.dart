import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/helpers/algolia.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import 'package:userapp/ui/widgets/titleAppBar.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;
import '../shared/text_styles.dart' as style;

class ItemsList extends StatefulWidget {
  final Category argument;

  const ItemsList({Key key, this.argument});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  List<DocumentSnapshot> _productSnapshots = [];
  List<Item> _products = [];
  List<String> _facets = ["category_id"];
  List<Item> _searchedProducts = [];
  List filteredItemList = [];
  bool _isLoading = false;
  bool _isSearching = false;
  int _per_page = 10;
  DocumentSnapshot _lastDocument;
  bool _gettingMoreProducts = false;
  bool _moreProductsAvailable = true;
  ScrollController _scrollController = ScrollController();
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String searchTerm = '';
  var _controller = TextEditingController();
  var _blankFocusNode = new FocusNode();
  Timer _debounce;
  StreamSubscription<List<AlgoliaObjectSnapshot>> _searchSnapShotsStream;

  String _searchString = '';

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    String whereCondition = "category_id:" + widget.argument.id;
    print("Where condition: " + whereCondition);
    AlgoliaQuery query = _algoliaApp.instance
        .index("items")
        .search(input)
        .setFacetFilter(whereCondition);
    AlgoliaQuerySnapshot querySnapshots = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnapshots.hits;
    return results;
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // do something with _searchQuery.text
      if (_searchString.isNotEmpty) _submitSearch(_searchString);
    });
  }

  @override
  void initState() {
    super.initState();
    _getProducts();

    _controller.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      //print('SCROLLING');
      //FocusScope.of(context).requestFocus(_blankFocusNode);

      if (maxScroll - currentScroll <= delta) {
        _getMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _debounce.cancel();
    super.dispose();
  }

  _getProducts() async {
    setState(() {
      _isLoading = true;
    });

    _productSnapshots = await firebase.getItems(widget.argument.id, _per_page);

    _productSnapshots.forEach((document) {
      Item item = Item.fromMap(document.data, document.documentID);
      _products.add(item);
    });

    _lastDocument = _productSnapshots[_productSnapshots.length - 1];

    setState(() {
      _isLoading = false;
    });
  }

  _getMoreProducts() async {
    if (_moreProductsAvailable == false) {
      //Display message saying there are no more products
      print('No more products');
      return;
    }

    if (_gettingMoreProducts == true) {
      return;
    }

    print('Get more products called');

    _gettingMoreProducts = true;

    List<DocumentSnapshot> items = await firebase.getMoreItems(
        widget.argument.id, _per_page, _lastDocument);

    if (items.length < _per_page) {
      _moreProductsAvailable = false;
    }

    _productSnapshots.addAll(items);
    _lastDocument = _productSnapshots[_productSnapshots.length - 1];

    items.forEach((document) {
      Item item = Item.fromMap(document.data, document.documentID);
      _products.add(item);
    });

    setState(() {});

    _gettingMoreProducts = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (v) {
          FocusScope.of(context).requestFocus(_blankFocusNode);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: MikroMartColors.white,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TitleAppBar(
                    title: widget.argument == null
                        ? ''
                        : widget.argument.category_name),
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
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
                          }
                          _searchString = val;
                        });
                      },
                      onSubmitted: (val) async {
                        _submitSearch(val);
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: _searchString.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {
                                      _searchString = '';
                                      _isSearching = false;
                                    });
                                  },
                                  icon: Icon(Icons.clear),
                                )
                              : Icon(Icons.search),
                          contentPadding: EdgeInsets.only(
                              left: 16.0, top: 16.0, bottom: 16.0),
                          hintText: 'Search item',
                          hintStyle:
                              TextStyle(color: Theme.of(context).hintColor)),
                    ),
                  ),
                ),
                _isLoading
                    ? Flexible(
                        flex: 1,
                        child: Center(child: CircularProgressIndicator()))
                    : (_products.length == 0
                        ? Center(
                            child: Text('No items to display'),
                          )
                        : Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),
                                  GridView.count(
                                    controller: _scrollController,
                                    physics: ScrollPhysics(),
                                    crossAxisCount: 2,
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, bottom: 50),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    children: List.generate(
                                        _isSearching
                                            ? _searchedProducts.length
                                            : _products.length, (index) {
                                      Item item = _isSearching
                                          ? _searchedProducts[index]
                                          : _products[index];
                                      return Card(
                                        elevation: 2,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ItemDetails(
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
                                                transitionOnUserGestures: true,
                                                tag: item.item_name,
                                                child: Image(
                                                  image: NetworkImage(
                                                      item.item_image_path),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, bottom: 0, top: 4),
                                                child: Flexible(
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            item.item_name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            style: style
                                                                .lightTextTitle,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            '₹ ' +
                                                                item.item_price
                                                                    .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: style
                                                                .lightTextSubtitle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          )),
              ],
            ),
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
  }
}