import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/helpers/algolia.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/item_quantity.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/choicechip.dart';
import 'package:userapp/ui/views/itemDetailNew.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import 'package:userapp/ui/widgets/titleAppBar.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;
import '../shared/text_styles.dart' as style;

class ItemsList extends StatefulWidget {
  final Store passedStore;
  final List<Store> stores;

  const ItemsList({Key key, this.passedStore, this.stores});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  List<DocumentSnapshot> _productSnapshots = [];
  List<Item> _products = [];
  List<Item> _searchedProducts = [];
  Store currentStore;

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

  Flushbar _errorFlushBar = Flushbar();

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    String whereCondition = "category_id:" + currentStore.id;
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
    currentStore =
        widget.passedStore != null ? widget.passedStore : widget.stores[0];
    _getProducts();
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

    _productSnapshots = await firebase.getItems(currentStore.id, _per_page);

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

  _resetStoreItems() {
    _lastDocument = null;
    _productSnapshots = null;
    _lastDocument = null;
    _moreProductsAvailable = true;
    _products = [];
    _getProducts();
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

    List<DocumentSnapshot> items =
        await firebase.getMoreItems(currentStore.id, _per_page, _lastDocument);

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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemWidth = size.width / 2;

    return NotificationListener(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          //_scrollController.position.pixels
          double maxScroll = _scrollController.position.maxScrollExtent;
          double currentScroll = _scrollController.position.pixels;
          double delta = MediaQuery.of(context).size.height * 0.25;
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
        resizeToAvoidBottomInset: false,
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
                  Container(
                    color: MikroMartColors.colorPrimary,
                    padding: EdgeInsets.only(
                        left: 0.0, top: 8, bottom: 8, right: 18.0),
                    child: SafeArea(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: 70,
                            child: FlatButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 0.0, top: 8, bottom: 8),
                              child: Text(
                                currentStore == null
                                    ? ''
                                    : currentStore.category_name,
                                style: style.appBarTextTheme
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: MikroMartColors.colorPrimary,
                    padding: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 18.0),
                    child: Material(
                      elevation: 2.0,
                      borderRadius: BorderRadius.circular(50.0),
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
                  widget.stores!=null ?Container(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Wrap(
                      spacing: 5.0,
                      runSpacing: 3.0,
                      children: [
                        choiceChipWidget(
                            storesList: widget.stores,
                            onStoreSelected: (store) {
                              currentStore = store;
                              setState(() {});
                              _resetStoreItems();
                            }),
                      ],
                    ),
                  ) : Container(),
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
                                          /* childAspectRatio:
                                              itemWidth / itemHeight,*/
                                          childAspectRatio: 158 / 163,
                                          crossAxisCount: 2),
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, bottom: 100),
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

                                    bool itemUnavailable =
                                        (displayableItemQuantity
                                                    .item_stock_quantity ==
                                                0 ||
                                            !item.show_item);

                                    bool itemOnOffer =
                                        displayableItemQuantity.item_price <
                                            displayableItemQuantity.item_mrp;

                                    return InkWell(
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        if (item.show_item) {
                                          /*Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ItemDetail(
                                                      item: item,
                                                    )));*/
                                          Navigator.of(context)
                                              .push(_createRoute(item));
                                        } else {
                                          showErrorDialog(item.item_name);
                                        }
                                      },
                                      child: Padding(
                                        //padding:  EdgeInsets.fromLTRB(i == 0 ? 16 : 0, 0, i == 0? 0 : 16, 0),
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Container(
                                          child: Card(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            color: MikroMartColors.cardBG,
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Stack(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  children: <Widget>[
                                                    AspectRatio(
                                                      aspectRatio: 2 / 1.2,
                                                      child: Container(
                                                        width: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.6) -
                                                            16,
                                                        color: Colors.white,
                                                        child: Hero(
                                                          tag: item.item_name,
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: item
                                                                .item_image_path,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context,
                                                                    url) =>
                                                                Center(
                                                                    child:
                                                                        SizedBox(
                                                              height: 15.0,
                                                              width: 15.0,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor: new AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    MikroMartColors
                                                                        .colorPrimary),
                                                              ),
                                                            )),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    itemUnavailable
                                                        ? Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: <Widget>[
                                                              Container(
                                                                child: Image(
                                                                  image: AssetImage(
                                                                      'assets/item_unavailable_bg.png'),
                                                                ),
                                                              ),
                                                              Center(
                                                                child: Text(
                                                                  'Item Unavailable',
                                                                  style: style
                                                                      .headerStyle2
                                                                      .copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.white),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : itemOnOffer
                                                            ? Container(
                                                                width: 100,
                                                                child: Image(
                                                                  image: AssetImage(
                                                                      'assets/flag_bg.png'),
                                                                  color: MikroMartColors
                                                                      .badgeGreen,
                                                                ),
                                                              )
                                                            : Container(),
                                                    itemUnavailable ||
                                                            !itemOnOffer
                                                        ? Container()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8.0,
                                                                    bottom:
                                                                        6.0),
                                                            child: Text(
                                                              calculatePercentage(
                                                                          displayableItemQuantity
                                                                              .item_price,
                                                                          displayableItemQuantity
                                                                              .item_mrp)
                                                                      .toString() +
                                                                  '% OFF',
                                                              style: style
                                                                  .headerStyle2
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        width: double.infinity,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10, 0, 10, 6),
                                                          child: Text(
                                                            item.item_name,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: style
                                                                .outletCardNameStyle,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      10,
                                                                      0,
                                                                      10,
                                                                      0),
                                                              child: Text(
                                                                '₹ ' +
                                                                    displayableItemQuantity
                                                                        .item_mrp
                                                                        .toString(),
                                                                style: style
                                                                    .strikeThroughPrice,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      10,
                                                                      0),
                                                              child: Text(
                                                                '₹ ' +
                                                                    displayableItemQuantity
                                                                        .item_price
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    color: MikroMartColors
                                                                        .colorPrimary,
                                                                    fontFamily:
                                                                        'Mulish',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )

                                        /*Card(
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          if (item.show_item) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ItemDetails(
                                                          data: item,
                                                        )));
                                          } else {
                                            showErrorDialog(item.item_name);
                                          }
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
                                                              (displayableItemQuantity
                                                                              .item_stock_quantity ==
                                                                          0 ||
                                                                      !item
                                                                          .show_item)
                                                                  ? Container(
                                                                      height:
                                                                          25,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          displayableItemQuantity.item_stock_quantity == 0
                                                                              ? 'Item out of stock'
                                                                              : 'Item Unavailable',
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
                                                                            padding:
                                                                                const EdgeInsets.only(left: 2.0, right: 2.0),
                                                                            child:
                                                                                Text(
                                                                              item.outlet_id,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 2,
                                                                              style: style.itemnNameText.copyWith(fontSize: 14, color: Colors.white),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                  ),
                                                                ),
                                                              ),
                                                              (displayableItemQuantity
                                                                              .item_stock_quantity !=
                                                                          0 ||
                                                                      !item
                                                                          .show_item)
                                                                  ? Flexible(
                                                                      child:
                                                                          Container(
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
                                    )*/
                                        ;
                                  },
                                ),
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

  showErrorDialog(String itemName) {
    if (_errorFlushBar != null && !_errorFlushBar.isShowing()) {
      _errorFlushBar = Flushbar<List<String>>(
        flushbarPosition: FlushbarPosition.BOTTOM,
        flushbarStyle: FlushbarStyle.GROUNDED,
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.easeOutCubic,
        animationDuration: Duration(milliseconds: 400),
        duration: Duration(seconds: 3),
        backgroundColor: MikroMartColors.purpleStart,
        userInputForm: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(
                  '${itemName} is currently unavailable. Please check after some time',
                  style: TextStyle(color: MikroMartColors.white),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: FlatButton(
                      child: Text('OK'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      textColor: MikroMartColors.purpleEnd,
                      padding: EdgeInsets.all(6),
                      onPressed: () {
                        _errorFlushBar.dismiss();
                        //onContinue.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        boxShadows: [
          BoxShadow(
              color: Colors.blue, offset: Offset(0.0, 0.2), blurRadius: 3.0)
        ],
        backgroundGradient: LinearGradient(colors: [
          MikroMartColors.colorPrimaryDark,
          MikroMartColors.colorPrimary
        ]),
        isDismissible: true,
        icon: Icon(
          Icons.check,
          color: Colors.white,
        ),
      )..show(context);
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

  Route _createRoute(Item item) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ItemDetail(
        item: item,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1, 0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
