import 'package:flutter/material.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/ui/shared/colors.dart';
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
  List itemList = [];
  List filteredItemList = [];
  bool isSearching = false;

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
            Expanded(
              child: FutureBuilder(
                future: firebase.getItems(widget.argument.id, 10),
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
              ),
            ),

            /* */
          ],
        ),
      ),
    );
  }
}
