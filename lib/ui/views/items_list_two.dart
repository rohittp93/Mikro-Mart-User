import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  List filteredItemList = [];
  bool _isLoading = false;
  int _per_page = 10;
  DocumentSnapshot _lastDocument;
  bool _gettingMoreProducts = false;
  bool _moreProductsAvailable = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getProducts();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if(maxScroll - currentScroll <= delta){
        _getMoreProducts();
      }
    });
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
    if(_moreProductsAvailable == false){
      //Display message saying there are no more products
      print('No more products');
      return;
    }

    if(_gettingMoreProducts == true){
      return;
    }


    print('Get more products called');

    _gettingMoreProducts = true;

    List<DocumentSnapshot> items = await firebase.getMoreItems(
        widget.argument.id, _per_page, _lastDocument);

    if(items.length < _per_page) {
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
      body: Container(
        color: MikroMartColors.white,
        child: Column(
          children: <Widget>[
            TitleAppBar(
                title: widget.argument == null
                    ? ''
                    : widget.argument.category_name),
            _isLoading
                ? Expanded(
                    flex: 1, child: Center(child: CircularProgressIndicator()))
                : (_products.length == 0
                    ? Center(
                        child: Text('No items to display'),
                      )
                    : Expanded(
                        child: GridView.count(
                          controller: _scrollController,
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          padding: EdgeInsets.only(left: 16, right: 16),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: List.generate(_products.length, (index) {
                            Item item = _products[index];
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Hero(
                                      transitionOnUserGestures: true,
                                      tag: item.item_name,
                                      child: Image(
                                        image: NetworkImage(item.item_image_path),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, bottom: 8, top: 16),
                                      child: Column(
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item.item_name,
                                              style: style.mediumTextTitle,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '₹ ' + item.item_price.toString(),
                                              style: style.mediumTextSubtitle,
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
                        ),
                      )),

            /* FutureBuilder(
              future: firebase.getItems(widget.argument.id),
              builder:
              // ignore: missing_return
                  (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Some error occured');
                  }
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          child: Material(
                            elevation: 10.0,
                            borderRadius: BorderRadius.circular(8.0),
                            child: TextField(
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {

                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search),
                                  contentPadding: EdgeInsets.only(
                                      left: 16.0, top: 16.0, bottom: 16.0),
                                  hintText: 'Search for an item',
                                  hintStyle: TextStyle(
                                      color: Theme.of(context).hintColor)),
                            ),
                          ),
                        ),
                        GridView.count(
                          crossAxisCount: 2,
                          padding: EdgeInsets.only(left: 16, right: 16),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children:
                          List.generate(snapshot.data.length, (index) {
                            Item item = snapshot.data[index];
                            return Card(
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: NetworkImage(item.item_image_path),
                                    fit: BoxFit.contain,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, bottom: 8, top: 16),
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.item_name,
                                            style: style.mediumTextTitle,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '₹ ' + item.item_price.toString(),
                                            style: style.mediumTextSubtitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),

                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),*/
          ],
        ),
      ),
    );
  }
}
