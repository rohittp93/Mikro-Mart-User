import 'package:flutter/material.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/widgets/titleAppBar.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;

class ItemsList extends StatefulWidget {
  final Category argument;

  const ItemsList({Key key, this.argument});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
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
                future: firebase.getItems(widget.argument.id),
                builder:
                    // ignore: missing_return
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if(snapshot.connectionState == ConnectionState.done){
                        if(snapshot.hasError){
                          return Text('Some error occured');
                        }


                        return GridView.count(
                            crossAxisCount: 2,
                          padding: EdgeInsets.only(left: 16, right: 16),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: List.generate(snapshot.data.length,(index){
                              Item item = snapshot.data[index];
                              return Card(
                                elevation: 2,
                                child: Stack(
                                  children: <Widget>[
                                    Image(
                                      image: NetworkImage(item.item_image_path),
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              );
                            }),


                          /*<Widget>[
                              Card(
                                color: MikroMartColors.colorAccent,
                                child: Stack(
                                  children: <Widget>[
                                    Image(
                                      image: NetworkImage(item.item_image_path),
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              )
                            ],*/

                            /*itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(item.item_name),
                                *//*onTap: () {
                                  Navigator.pushNamed(context, '/itemList', arguments: _categoriesNotifier.categoriesList[index].category_name) ;
                                },*//*
                              );
                            },
                            itemCount: snapshot.data.length,
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(color: MikroMartColors.transparentGray);
                            },*/
                          );
                      }else{
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
