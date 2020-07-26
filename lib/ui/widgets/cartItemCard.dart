import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../shared/text_styles.dart' as style;

class CartItemCard extends StatefulWidget {
  final Map<String, dynamic> item;


  CartItemCard({this.item});

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  int id = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 5.0,
        child: Container(
          padding: EdgeInsets.only(left: 8.0, right: 10.0),
          width: MediaQuery.of(context).size.width - 20.0,
          height: 150.0,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        id ++ ;
                      });
                    },
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 40,
                      color: Theme.of(context).brightness == Brightness.light ?Colors.black26 : Theme.of(context).hintColor,
                    ),
                  ),
                  Container(
                      height: 30.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                          child: Text(
                        id.toString(),
                        style: style.headerStyle3.copyWith(color: Theme.of(context).primaryColor),
                      ))),
                  GestureDetector(
                    onTap: (){
                      if ( id == 0){
                        return;
                      }
                      else{
                        setState(() {
                          id-- ;
                        });
                      }
                    },
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 40,
                      color: Theme.of(context).brightness == Brightness.light ?Colors.black26 : Theme.of(context).hintColor,
                    ),
                  )
                ],
              ),
              SizedBox(width: 5.0),
              Container(
                height: 120.0,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                      image: AssetImage(widget.item['img']), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 8.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.43,
                        child: Text(
                          widget.item['type'],
                          style: style.headerStyle3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.0),
                  Row(
                    children: <Widget>[
                      SmoothStarRating(
                          allowHalfRating: false,
                          starCount: 5,
                          rating: widget.item['rating'],
                          size: 17.0,
                          color: Color(0xFFFEBF00),
                          borderColor: Color(0xFFFEBF00),
                          spacing: 0.0),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "(${widget.item['rating'].toString()})",
                        style: style.subHintTitle,
                      )
                    ],
                  ),
                  SizedBox(height: 7.0),
                  Text(
                    'Cuisine: ' + widget.item['cuisine'],
                    style: style.subHintTitle,
                  ),
                  SizedBox(height: 7.0),
                  Text(
                    '\$' + widget.item['price'].toString(),
                    style: style.headerStyle3
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
