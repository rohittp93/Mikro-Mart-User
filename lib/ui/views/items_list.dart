import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/helpers/algolia.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/item_quantity.dart';
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

  //final GlobalKey itemCardKey = new GlobalKey();
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
  Size cardSize;
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

    //WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _getSizeAndPosition());

    // _controller.addListener(_onSearchChanged);

    print('ITEMLOADMORE : scroll listener added');

    /*_scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      //print('SCROLLING');
      //FocusScope.of(context).requestFocus(_blankFocusNode);
      print('ITEMLOADMORE : Scrollchanged');
      if (maxScroll - currentScroll <= delta) {
        print('ITEMLOADMORE : Scroll reached');
        _getMoreProducts();
      }
    });*/
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    if (_debounce != null) _debounce.cancel();
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

    if (_productSnapshots.length > 1)
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

    print('ITEMLOADMORE : Get more products called ');

    _gettingMoreProducts = true;

    List<DocumentSnapshot> items = await firebase.getMoreItems(
        widget.argument.id, _per_page, _lastDocument);

    if (items != null && items.length < _per_page) {
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

  /* bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }*/

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemWidth = size.width / 2;
    final double itemHeight = (itemWidth) + 100;

    /* if (_keyboardIsVisible()) {
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
    }*/

    return NotificationListener(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          //_scrollController.position.pixels
          double maxScroll = _scrollController.position.maxScrollExtent;
          double currentScroll = _scrollController.position.pixels;
          double delta = MediaQuery.of(context).size.height * 0.25;
          //print('SCROLLING');
          //FocusScope.of(context).requestFocus(_blankFocusNode);
          print('ITEMLOADMORE : Scrollchanged');
          if (maxScroll - currentScroll <= delta) {
            print('ITEMLOADMORE : Scroll reached');
            _getMoreProducts();
          }

          print('Widget has started scrolling');
        }
        return true;
      },
      child: Scaffold(
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
                        autofocus: false,
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onChanged: (val) {
                          setState(() {
                            if (val.isEmpty) {
                              _isSearching = false;
                            }
                            _searchString = val;
                          });
                          _onSearchChanged();
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
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
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
                          ? Flexible(
                              flex: 1,
                              child: Center(
                                child: Text('No items to display'),
                              ),
                            )
                          : Expanded(
                              child: SingleChildScrollView(
                                child: GridView.builder(
                                  itemCount: _isSearching
                                      ? _searchedProducts.length
                                      : _products.length,
                                  controller: _scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio:
                                              itemWidth / itemHeight,
                                          crossAxisCount: 2),
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, bottom: 50),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Item item = _isSearching
                                        ? _searchedProducts[index]
                                        : _products[index];

                                    ItemQuantity displayableItemQuantity =
                                        new ItemQuantity();

                                    for (var i = 0;
                                        i < item.item_quantity_list.length;
                                        i++) {
                                      if (item.item_quantity_list[i]
                                          .display_quantity) {
                                        displayableItemQuantity =
                                            item.item_quantity_list[i];
                                        break;
                                      }
                                    }

                                    return Card(
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => ItemDetails(
                                                        data: item,
                                                      )));
                                        },
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Stack(
                                                children: <Widget>[
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(6),
                                                            topLeft:
                                                                Radius.circular(
                                                                    6)),
                                                    child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: Container(
                                                          width: itemWidth,
                                                          child: Column(
                                                            children: <Widget>[
                                                              displayableItemQuantity
                                                                          .item_stock_quantity ==
                                                                      0
                                                                  ? Container(
                                                                      height:
                                                                          25,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Item out of stock',
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: style.itemPriceText.copyWith(
                                                                              color: MikroMartColors.colorPrimary,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      height: 0,
                                                                    ),
                                                              AspectRatio(
                                                                aspectRatio:
                                                                    2 / 1.2,
                                                                child: Center(
                                                                  child: Hero(
                                                                    transitionOnUserGestures:
                                                                        true,
                                                                    tag: item
                                                                        .item_name,
                                                                    child:
                                                                        Image(
                                                                      image: NetworkImage(
                                                                          item.item_image_path),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  color: MikroMartColors
                                                                      .errorRed
                                                                      .withOpacity(
                                                                          0.8),
                                                                  child: Center(
                                                                    child: (item !=
                                                                                null &&
                                                                            item.outlet_id !=
                                                                                null)
                                                                        ? Padding(
                                                                          padding: const EdgeInsets.only(left: 2.0, right:2.0),
                                                                          child: Text(
                                                                              item.outlet_id,
                                                                              overflow:
                                                                                  TextOverflow.ellipsis,
                                                                              maxLines:
                                                                                  2,
                                                                              style:
                                                                                  style.itemnNameText.copyWith(fontSize: 14, color: Colors.white),
                                                                            ),
                                                                        )
                                                                        : Container(),
                                                                  ),
                                                                ),
                                                              ),
                                                              displayableItemQuantity
                                                                          .item_stock_quantity !=
                                                                      0
                                                                  ? Flexible(
                                                                    child: Container(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                  )
                                                                  : Container(),
                                                            ],
                                                          )),
                                                    ),
                                                  ),
                                                  displayableItemQuantity
                                                              .item_mrp !=
                                                          null
                                                      ? calculatePercentage(
                                                                  displayableItemQuantity
                                                                      .item_price,
                                                                  displayableItemQuantity
                                                                      .item_mrp) !=
                                                              0
                                                          ? displayableItemQuantity
                                                                      .item_stock_quantity !=
                                                                  0
                                                              ? Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      borderRadius:
                                                                          BorderRadius.only(
                                                                              topRight: Radius.circular(6)),
                                                                    ),
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(8),
                                                                    child: Text(
                                                                      calculatePercentage(displayableItemQuantity.item_price, displayableItemQuantity.item_mrp)
                                                                              .toString() +
                                                                          '% OFF',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: style.itemPriceText.copyWith(
                                                                          color: MikroMartColors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container()
                                                          : Container()
                                                      : Container(),
                                                ],
                                              ),
                                              Container(
                                                height: 90,
                                                padding: EdgeInsets.fromLTRB(
                                                    6.0, 0.0, 6.0, 4.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 3.0),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          //'ASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDK',
                                                          item.item_name +
                                                              ' - ' +
                                                              displayableItemQuantity
                                                                  .item_quantity,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style: style
                                                              .itemnNameText
                                                              .copyWith(
                                                                  fontSize: 15),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          '₹ ' +
                                                              displayableItemQuantity
                                                                  .item_price
                                                                  .toStringAsFixed(
                                                                      2),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: style
                                                              .itemPriceText
                                                              .copyWith(
                                                                  fontSize: 15,
                                                                  color:
                                                                      MikroMartColors
                                                                          .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                    ),
                                                    displayableItemQuantity
                                                                .item_mrp !=
                                                            null
                                                        ? Flexible(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <
                                                                    Widget>[
                                                                  displayableItemQuantity
                                                                              .item_mrp !=
                                                                          displayableItemQuantity
                                                                              .item_price
                                                                      ? Text(
                                                                          'MRP: ₹' +
                                                                              displayableItemQuantity.item_mrp.toStringAsFixed(2),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: style.itemPriceText.copyWith(
                                                                              decoration: TextDecoration.lineThrough,
                                                                              fontSize: 14,
                                                                              color: MikroMartColors.ErroColor),
                                                                        )
                                                                      : Spacer(),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Spacer(),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                /*
                              GridView.count(
                                controller: _scrollController,
                                childAspectRatio: itemWidth / itemHeight,
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
                                  return Wrap(
                                    children: <Widget>[
                                      Card(
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
                                          child: Container(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: <Widget>[
                                                Stack(
                                                  children: <Widget>[
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(6.0),
                                                      child: AspectRatio(
                                                        aspectRatio: 1,
                                                        child: Container(
                                                            width: itemWidth,
                                                            child: Column(
                                                              children: <Widget>[
                                                                item.item_stock_quantity ==
                                                                    0
                                                                    ? Container(
                                                                  height:
                                                                  35,
                                                                  child:
                                                                  Center(
                                                                    child:
                                                                    Text(
                                                                      'Item out of stock',
                                                                      overflow:
                                                                      TextOverflow.ellipsis,
                                                                      style: style
                                                                          .itemPriceText
                                                                          .copyWith(color: MikroMartColors.colorPrimary, fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                )
                                                                    : Container(height:
                                                                0,),
                                                                AspectRatio(
                                                                  aspectRatio:
                                                                  2 / 1.2,
                                                                  child: Center(
                                                                    child: Hero(
                                                                      transitionOnUserGestures:
                                                                      true,
                                                                      tag: item
                                                                          .item_name,
                                                                      child:
                                                                      Image(
                                                                        image: NetworkImage(
                                                                            item.item_image_path),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                  Container(
                                                                    color: MikroMartColors
                                                                        .errorRed
                                                                        .withOpacity(
                                                                        0.8),
                                                                    child: Center(
                                                                      child: (item !=
                                                                          null &&
                                                                          item.outlet_id !=
                                                                              null)
                                                                          ? Text(
                                                                        item.outlet_id,
                                                                        overflow:
                                                                        TextOverflow.ellipsis,
                                                                        maxLines:
                                                                        1,
                                                                        style:
                                                                        style.itemnNameText.copyWith(fontSize: 14, color: Colors.white),
                                                                      )
                                                                          : Container(),
                                                                    ),
                                                                  ),
                                                                ),
                                                                item.item_stock_quantity !=
                                                                    0
                                                                    ? Container(
                                                                  height: 35,
                                                                ): Container(),
                                                              ],
                                                            )),
                                                      ),
                                                    ),
                                                    item.item_mrp != null
                                                        ? calculatePercentage(
                                                        item.item_price,
                                                        item.item_mrp) !=
                                                        0
                                                        ? item.item_stock_quantity !=
                                                        0
                                                        ? Align(
                                                      alignment:
                                                      Alignment
                                                          .topRight,
                                                      child:
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(6)),
                                                        ),
                                                        padding:
                                                        EdgeInsets
                                                            .all(
                                                            8),
                                                        child: Text(
                                                          calculatePercentage(item.item_price,
                                                              item.item_mrp)
                                                              .toString() +
                                                              '% OFF',
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          style: style
                                                              .itemPriceText
                                                              .copyWith(
                                                              color:
                                                              MikroMartColors.white,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ) : Container()
                                                        : Container()
                                                        : Container(),
                                                  ],
                                                ),
                                                Container(
                                                  height: 90,
                                                  padding:
                                                  EdgeInsets.fromLTRB(
                                                      6.0,
                                                      0.0,
                                                      6.0,
                                                      4.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 3.0),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .topLeft,
                                                          child: Text(
                                                            //'ASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDK',
                                                            item.item_name +
                                                                ' - ' +
                                                                item.item_quantity,
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            maxLines: 2,
                                                            style: style
                                                                .itemnNameText
                                                                .copyWith(
                                                                fontSize:
                                                                15),
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          '₹ ' +
                                                              item.item_price
                                                                  .toStringAsFixed(
                                                                  2),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          style: style
                                                              .itemPriceText
                                                              .copyWith(
                                                              fontSize:
                                                              15,
                                                              color: MikroMartColors
                                                                  .black,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      ),
                                                      */ /*item.item_stock_quantity ==
                                                                  0
                                                                  ? Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  'Item out of stock',
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  style: style.itemPriceText.copyWith(
                                                                      fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                      color: MikroMartColors
                                                                          .colorPrimary),
                                                                ),
                                                              )
                                                                  : */ /*
                                                      item.item_mrp != null
                                                          ? Align(
                                                        alignment:
                                                        Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: <
                                                              Widget>[
                                                            item.item_mrp !=
                                                                item.item_price
                                                                ? Text(
                                                              'MRP: ₹' + item.item_mrp.toStringAsFixed(2),
                                                              overflow: TextOverflow.ellipsis,
                                                              style: style.itemPriceText.copyWith(decoration: TextDecoration.lineThrough, fontSize: 14, color: MikroMartColors.ErroColor),
                                                            )
                                                                : Spacer(),
                                                          ],
                                                        ),
                                                      )
                                                          : Spacer(),
                                                      Spacer(),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),*/
                              ),
                            )),
                ],
              ),
            ),
          ),
        ),
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

  Future<void> _submitSearch(String val) async {
    setState(() {
      _isLoading = true;
    });
    _searchedProducts.clear();

    if (_searchSnapShotsStream != null) _searchSnapShotsStream.cancel();

    _searchSnapShotsStream = _operation(val).asStream().listen((snapShots) {
      for (var i = 0; i < snapShots.length; i++) {
        AlgoliaObjectSnapshot snap = snapShots[i];
        Map<String, dynamic> data = snap.data;

        print('ALGOLOA SEARCH MAP ${snap.objectID}');

        Item item = Item.fromSearchMap(data, snap.objectID);
        _searchedProducts.add(item);
      }

      setState(() {
        _isLoading = false;
        if (_searchString.length != 0) {
          _isSearching = true;
        } else {
          _isSearching = false;
        }
      });
    });
  }
}
