import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/Dish_list.dart';
import '../shared/text_styles.dart' as style;
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../../locator.dart';
import 'itemDetails.dart';

class FavoriteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: <Widget>[
          ChangeNotifierProvider<FoodList>(
            create: (context) => locator<FoodList>(),
            child: Consumer<FoodList>(
              builder: (context, model, child) {
                return Expanded(
                  child: ListView.builder(
                    physics: ScrollPhysics(parent: BouncingScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: model.categories.length,
                    itemBuilder: (context, index) {
                      if (model.categories[index]['liked']) {
                        return LikedProduct(
                          productDetails: model.categories[index],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}

class LikedProduct extends StatelessWidget {
  final productDetails;

  LikedProduct({this.productDetails});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> ItemDetails(data: productDetails,))) ;
        },
        child: Container(
          height: size.height * 0.15,
          width: size.width * 0.9,
          child: Row(
            children: <Widget>[
              Hero(
                transitionOnUserGestures: true,
                tag:productDetails['id'] ,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    productDetails['img'],
                    width: size.width * 0.35,
                    height: size.height * 0.15,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              SizedBox(
                height: size.height *0.13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      productDetails['type'],
                      style: style.headerStyle3,
                    ),
                    Text(
                      productDetails['price'].toString() + " \$",
                      style: style.textTheme
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      productDetails['cuisine'],style: style.textTheme,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SmoothStarRating(
                            allowHalfRating: false,
                            starCount: 5,
                            rating: productDetails['rating'],
                            size: 20.0,
                            color: Color(0xFFFEBF00),
                            borderColor: Color(0xFFFEBF00),
                            spacing: 0.0),
                        Text(
                          "(${productDetails['rating']})",
                          style: style.textTheme,
                        )
                      ],
                    )
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
