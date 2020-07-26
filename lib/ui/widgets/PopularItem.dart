import 'package:flutter/material.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import '../shared/text_styles.dart' as style;
class PopularItem extends StatelessWidget{
  final Item item ;
  PopularItem({this.item}) ;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> ItemDetails(data: item,))) ;
          },
          child: Card(
            elevation: 10,
            child:  Container(
              alignment: Alignment.bottomRight,
              height: MediaQuery.of(context).size.width * 0.5,
              width: MediaQuery.of(context).size.width * 0.43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(image: NetworkImage(item.item_image_path),
                      fit: BoxFit.cover)
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(1, 0),spreadRadius: 4)]

                  ),
                 /* child: GestureDetector(
                    onTap: (){
                      itemDetails.likeAndUnlike(item['id']);
                    },
                    child: Icon(
                      item['liked']? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: MediaQuery.of(context).size.height * 0.04,
                    ),
                  ),*/
                ),
              ), //just for testing, will fill with image later
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Column(
            children: <Widget>[
              Text(
                item.item_name,
                style: style.subcardTitleStyle,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
       /* Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           *//* SmoothStarRating(
                allowHalfRating: false,
                starCount: 5,
                rating: item['rating'],
                size: 20.0,
                color: Color(0xFFFEBF00),
                borderColor: Color(0xFFFEBF00),
                spacing: 0.0),*//*
            Text(
              "(${item['rating']})",
              style: style.subHeaderStyle,
            )
          ],
        ),*/
      ],
    );
  }
}
