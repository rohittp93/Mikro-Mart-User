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
import 'package:userapp/ui/widgets/stateful_grid.dart';
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
  ScrollController _listScrollController = ScrollController();
  Widget _list;

  StreamSubscription<List<AlgoliaObjectSnapshot>> _searchSnapShotsStream;

  @override
  void initState() {
    //firebase.getCategories(_categoriesNotifier);
    super.initState();
    //_controller.addListener(_onSearchChanged);
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
    if (_debounce != null) _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CategoriesNotifier _categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);
    var size = MediaQuery.of(context).size;

    final double itemWidth = size.width / 2;
    final double itemHeight = (itemWidth) + 100;
    //FocusScope.of(context).requestFocus(FocusNode());
    print('SearchScreenTag : widget rebuild');
    if (_list == null) {
      print('SearchScreenTag : Widget list is null & was called');
      _list = new StatefulGridView(_searchedProducts!=null ? _searchedProducts.length : 0, getBuilder);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
                    children: <Widget>[
                      Container(
                        color: MikroMartColors.greenShadowColor.withOpacity(0.2),
                        padding: EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 25.0),
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
                                  _isLoading = false;
                                } else {
                                  _isLoading = true;
                                }
                                searchString = val;
                              });
                              _onSearchChanged();
                            },
                            onSubmitted: (val) async {},
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: searchString.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          _controller.clear();
                                          setState(() {
                                            searchString = '';
                                            _isSearching = false;
                                          });
                                        },
                                        icon: Icon(Icons.clear),
                                      )
                                    : Icon(Icons.search),
                                contentPadding: EdgeInsets.only(
                                    left: 16.0, top: 16.0, bottom: 16.0),
                                hintText: 'Search item',
                                hintStyle: TextStyle(
                                    color: Theme.of(context).hintColor)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
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
                        height: 5,
                      ),
                      Divider(color: MikroMartColors.transparentGray),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            _isLoading
                                ? Center(
                                    child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator()),
                                  ))
                                : _isSearching
                                    ? _list
                                    /*GridView.builder(
                                        itemCount: _searchedProducts.length,
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
                                                                      .circular(
                                                                          6),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          6)),
                                                          child: AspectRatio(
                                                            aspectRatio: 1,
                                                            child: Container(
                                                                width: itemWidth,
                                                                child: Column(
                                                                  children: <
                                                                      Widget>[
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
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: style.itemPriceText.copyWith(color: MikroMartColors.colorPrimary, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            height:
                                                                                0,
                                                                          ),
                                                                    AspectRatio(
                                                                      aspectRatio:
                                                                          2 / 1.2,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Hero(
                                                                          transitionOnUserGestures:
                                                                              true,
                                                                          tag: item
                                                                              .item_name,
                                                                          child:
                                                                              Image(
                                                                            image:
                                                                                NetworkImage(item.item_image_path),
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
                                                                        child:
                                                                            Center(
                                                                          child: (item != null &&
                                                                                  item.outlet_id != null)
                                                                              ? Text(
                                                                                  item.outlet_id,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  maxLines: 1,
                                                                                  style: style.itemnNameText.copyWith(fontSize: 14, color: Colors.white),
                                                                                )
                                                                              : Container(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    item.item_stock_quantity !=
                                                                            0
                                                                        ? Container(
                                                                            height:
                                                                                35,
                                                                          )
                                                                        : Container(),
                                                                  ],
                                                                )),
                                                          ),
                                                        ),
                                                        item.item_mrp != null
                                                            ? calculatePercentage(
                                                                        item
                                                                            .item_price,
                                                                        item
                                                                            .item_mrp) !=
                                                                    0
                                                                ? item.item_stock_quantity !=
                                                                        0
                                                                    ? Align(
                                                                        alignment:
                                                                            Alignment
                                                                                .topRight,
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.green,
                                                                            borderRadius:
                                                                                BorderRadius.only(topRight: Radius.circular(6)),
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.all(8),
                                                                          child:
                                                                              Text(
                                                                            calculatePercentage(item.item_price, item.item_mrp).toString() +
                                                                                '% OFF',
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: style.itemPriceText.copyWith(
                                                                                color: MikroMartColors.white,
                                                                                fontWeight: FontWeight.bold),
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
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              6.0, 0.0, 6.0, 4.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 3.0),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .topLeft,
                                                              child: Flexible(
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
                                                          ),
                                                          Flexible(
                                                            child: Align(
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
                                                          ),
                                                          item.item_mrp != null
                                                              ? Flexible(
                                                                  child: Align(
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
                                      )*/
                                    :

                                    /*GridView.count(
                                        controller: _scrollController,
                                        physics: ScrollPhysics(),
                                        crossAxisCount: 2,
                                        childAspectRatio: 1 / 1.2,
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16, bottom: 50),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        children: List.generate(
                                            _searchedProducts.length, (index) {
                                          Item item = _searchedProducts[index];
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          return Card(
                                            elevation: 2,
                                            child: InkWell(
                                              onTap: () {
                                                FocusScope.of(context).requestFocus(FocusNode());
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
                                                  AspectRatio(
                                                    aspectRatio: 2 / 1.2,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      children: <Widget>[
                                                        Hero(
                                                          transitionOnUserGestures:
                                                              true,
                                                          tag: item.item_name,
                                                          child: Image(
                                                            image: NetworkImage(item
                                                                .item_image_path),
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        item.item_mrp != null
                                                            ? calculatePercentage(
                                                                        item.item_price,
                                                                        item.item_mrp) !=
                                                                    0
                                                                ? Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .green,
                                                                      padding:
                                                                          EdgeInsets
                                                                              .all(8),
                                                                      child: Text(
                                                                        calculatePercentage(item.item_price, item.item_mrp)
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
                                                            : Container(),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Container(
                                                            color: MikroMartColors
                                                                .transparentGray
                                                                .withOpacity(0.6),
                                                            height: 25,
                                                            child: Center(
                                                              child: (item !=
                                                                          null &&
                                                                      item.outlet_id !=
                                                                          null)
                                                                  ? Text(
                                                                      item.outlet_id,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines: 1,
                                                                      style: style
                                                                          .itemnNameText
                                                                          .copyWith(
                                                                              fontSize:
                                                                                  14,
                                                                              color:
                                                                                  Colors.white),
                                                                    )
                                                                  : Container(),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              8.0, 8.0, 0, 4.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Align(
                                                            alignment:
                                                                Alignment.topLeft,
                                                            child: Text(
                                                              //'ASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDK',
                                                              item.item_name +
                                                                  ' - ' +
                                                                  item.item_quantity,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3,
                                                              style: style
                                                                  .itemnNameText
                                                                  .copyWith(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
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
                                                          item.item_stock_quantity ==
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
                                                              : item.item_mrp !=
                                                                      null
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
                                                                          Text(
                                                                            'MRP: ₹' +
                                                                                item.item_mrp.toString(),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: style.itemPriceText.copyWith(
                                                                                decoration: TextDecoration.lineThrough,
                                                                                fontSize: 14,
                                                                                color: MikroMartColors.ErroColor),
                                                                          ),
                                                                          */ /*   calculatePercentage(item.item_price, item.item_mrp) !=
                                                                                0
                                                                            ? Text(
                                                                          calculatePercentage(item.item_price, item.item_mrp).toString() + '% OFF',
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: style.itemPriceText.copyWith(color: MikroMartColors.greenShadowColor),
                                                                              )
                                                                            : Container(),*/ /*
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      )*/
                                    ListView.separated(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        controller: _listScrollController,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          //FocusScope.of(context).requestFocus(FocusNode());
                                          return ListTile(
                                            title: Text(_categoriesNotifier
                                                .categoriesList[index]
                                                .category_name),
                                            trailing:
                                                Icon(Icons.keyboard_arrow_right),
                                            onTap: () {
                                              FocusScope.of(context).requestFocus(FocusNode());
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
                        ),
                      )
                    ],
                  )
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
    print('SearchScreenTag :  submit search called');

    setState(() {
      _isLoading = true;
    });


    _searchedProducts.clear();

    if (_searchSnapShotsStream != null) _searchSnapShotsStream.cancel();

    //List<AlgoliaObjectSnapshot> snapShots = await _operation(val);

    _searchSnapShotsStream = _operation(val).asStream().listen((snapShots) {
      for (var i = 0; i < snapShots.length; i++) {
        AlgoliaObjectSnapshot snap = snapShots[i];
        Map<String, dynamic> data = snap.data;

        Item item = Item.fromSearchMap(data, snap.objectID);
        _searchedProducts.add(item);
      }

      setState(() {
        _isLoading = false;
        if (searchString.length != 0) {
          _isSearching = true;
        } else {
          _isSearching = false;
        }
      });

      _list = new StatefulGridView(_searchedProducts.length, getBuilder);

    });
  }

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery tagQuery = _algoliaApp.instance.index("items").search(input);
    //AlgoliaQuery tagQuery = _algoliaApp.instance.index("items").setTagFilter(input);
    List<AlgoliaObjectSnapshot> results = [];

    AlgoliaQuerySnapshot querySnapshots = await tagQuery.getObjects();
    results  = querySnapshots.hits;

    if(results.isEmpty){
      print('SEARCHRESULT : EMPTY. searching tags ...');
      AlgoliaQuery tagQuery = _algoliaApp.instance.index("items").setTagFilter(input);
      AlgoliaQuerySnapshot tagQuerySnapshots = await tagQuery.getObjects();
      results = tagQuerySnapshots.hits;

      if(results.isEmpty){
        print('SEARCHRESULT : TAG result EMPTY');
      }else{
        print('SEARCHRESULT : TAG result NOT EMPTY' + results.toString());
      }

    }else{
      print('SEARCHRESULT : NOT EMPTY');
    }
    return results;
  }

  Widget getBuilder(BuildContext context, int index) {
    Item item = _searchedProducts[index];
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ItemDetails(
                        data: item,
                      )));
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(6),
                        topLeft: Radius.circular(6)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                          child: Column(
                        children: <Widget>[
                          item.item_stock_quantity == 0
                              ? Container(
                                  height: 35,
                                  child: Center(
                                    child: Text(
                                      'Item out of stock',
                                      overflow: TextOverflow.ellipsis,
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
                            aspectRatio: 2 / 1.2,
                            child: Center(
                              child: Hero(
                                transitionOnUserGestures: true,
                                tag: item.item_name,
                                child: Image(
                                  image: NetworkImage(item.item_image_path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: MikroMartColors.errorRed.withOpacity(0.8),
                              child: Center(
                                child: (item != null && item.outlet_id != null)
                                    ? Text(
                                        item.outlet_id,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: style.itemnNameText.copyWith(
                                            fontSize: 14, color: Colors.white),
                                      )
                                    : Container(),
                              ),
                            ),
                          ),
                          item.item_stock_quantity != 0
                              ? Container(
                                  height: 35,
                                )
                              : Container(),
                        ],
                      )),
                    ),
                  ),
                  item.item_mrp != null
                      ? calculatePercentage(item.item_price, item.item_mrp) != 0
                          ? item.item_stock_quantity != 0
                              ? Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(6)),
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      calculatePercentage(item.item_price,
                                                  item.item_mrp)
                                              .toString() +
                                          '% OFF',
                                      overflow: TextOverflow.ellipsis,
                                      style: style.itemPriceText.copyWith(
                                          color: MikroMartColors.white,
                                          fontWeight: FontWeight.bold),
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
                padding: EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          //'ASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDKASDDGAUSDGAJDHADJASDHAJDAGDJGASDJASHDADHAJDHASJDAJDBAJDGAJDHSKDSAKDK',
                          item.item_name + ' - ' + item.item_quantity,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: style.itemnNameText.copyWith(fontSize: 15),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹ ' + item.item_price.toStringAsFixed(2),
                        overflow: TextOverflow.ellipsis,
                        style: style.itemPriceText.copyWith(
                            fontSize: 15,
                            color: MikroMartColors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    item.item_mrp != null
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                item.item_mrp != item.item_price
                                    ? Text(
                                        'MRP: ₹' +
                                            item.item_mrp.toStringAsFixed(2),
                                        overflow: TextOverflow.ellipsis,
                                        style: style.itemPriceText.copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 14,
                                            color: MikroMartColors.ErroColor),
                                      )
                                    : Spacer(),
                              ],
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
  }
}
