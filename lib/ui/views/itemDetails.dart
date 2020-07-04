import 'package:flutter/material.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;

final stateBloc = StateBloc();

class ItemDetails extends StatelessWidget {
  final Item data;

  ItemDetails({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutStarts(
        data: data,
      ),
    );
  }
}

class LayoutStarts extends StatelessWidget {
  final Item data;

  LayoutStarts({this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CarDetailsAnimation(data: data),
        CustomBottomSheet(context: context, data: data),
        RentButton(),
      ],
    );
  }
}

class RentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        child: FlatButton(
          onPressed: () {},
          child: Text(
            "Add To Cart ",
            style: style.arialTheme,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
          ),
          color:  MikroMartColors.colorPrimary,
          padding: EdgeInsets.all(20),
        ),
      ),
    );
  }
}

class CarDetailsAnimation extends StatefulWidget {
  final Item data;

  CarDetailsAnimation({this.data});

  @override
  _CarDetailsAnimationState createState() => _CarDetailsAnimationState();
}

class _CarDetailsAnimationState extends State<CarDetailsAnimation>
    with TickerProviderStateMixin {
  AnimationController fadeController;
  AnimationController scaleController;

  Animation fadeAnimation;
  Animation scaleAnimation;

  @override
  void initState() {
    super.initState();

    fadeController =
        AnimationController(duration: Duration(milliseconds: 180), vsync: this);

    scaleController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);

    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(fadeController);
    scaleAnimation = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ));
  }

  forward() {
    scaleController.forward();
    fadeController.forward();
  }

  reverse() {
    scaleController.reverse();
    fadeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      initialData: StateProvider().isAnimating,
      stream: stateBloc.animationStatus,
      builder: (context, snapshot) {
        snapshot.data ? forward() : reverse();

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: DishDetails(data: widget.data),
          ),
        );
      },
    );
  }
}

class DishDetails extends StatelessWidget {
  final Item data;

  DishDetails({this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: CarCarousel(data: data),
          ),
        ),
        SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 25),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 42,
                    ),
                  )),
            ],
          ),
        ),
      ],
    ));
  }

  _carTitle(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              style: style.headerStyle.copyWith(
                fontSize: 62,
              ),
              children: [
                TextSpan(text: data.item_name),
                TextSpan(text: "\n"),
                //TextSpan(text: data['cuisine'], style: style.subcardTitleStyle),
              ]),
        ),
        SizedBox(height: 10),
        RichText(
          text: TextSpan(style: TextStyle(fontSize: 16), children: [
            TextSpan(
                text: data.item_price.toString(),
                style: TextStyle(
                    color: MikroMartColors.colorPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w900)),
            TextSpan(
              text: " \₹",
              style: TextStyle(
                  color:  MikroMartColors.colorPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w900),
            )
          ]),
        ),
      ],
    );
  }
}

class CarCarousel extends StatefulWidget {
  final Item data;

  CarCarousel({this.data});

  @override
  _CarCarouselState createState() => _CarCarouselState();
}

class _CarCarouselState extends State<CarCarousel> {
  //List<String> imgList;

  List<Widget> child() {}
  //List<Widget> childe;

  List<T> _map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  int _current = 0;

  @override
  void initState() {
    //imgList = widget.data["imgList"];
    /*childe = _map<Widget>(imgList, (index, String assetName) {
      return Container(
          decoration: BoxDecoration(),
          child: Hero(
            tag: widget.dish['id'],
            child: Image.asset(
              assetName,
              fit: BoxFit.cover,
              color: Colors.lightBlueAccent.withOpacity(0.2),
              colorBlendMode: BlendMode.hardLight,
            ),
          ));
    }).toList();*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height/2,
            child: Center(
              child: Image(
                image: NetworkImage(widget.data.item_image_path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////
class CustomBottomSheet extends StatefulWidget {
  BuildContext context;
  final Item data;

  CustomBottomSheet({this.context, this.data});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin {
  double sheetTop;

  double minSheetTop = 30;

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    double sheetTop = MediaQuery.of(widget.context).size.height * 0.5;
    double minSheetTop = 100;
    controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    animation = Tween<double>(begin: sheetTop, end: minSheetTop)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeInOut,
    ))
          ..addListener(() {
            setState(() {});
          });
  }

  forwardAnimation() {
    controller.forward();
    stateBloc.toggleAnimation();
  }

  reverseAnimation() {
    controller.reverse();
    stateBloc.toggleAnimation();
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: animation.value,
      left: 0,
      child: GestureDetector(
        onTap: () {
          controller.isCompleted ? reverseAnimation() : forwardAnimation();
        },
        onVerticalDragEnd: (DragEndDetails dragEndDetails) {
          //upward drag
          if (dragEndDetails.primaryVelocity < 0.0 && !controller.isCompleted) {
            forwardAnimation();
            controller.forward();
          } else if (dragEndDetails.primaryVelocity > 0.0 && controller.isCompleted) {
            reverseAnimation();
          } else {
            return;
          }
        },
        child: SheetContainer(data: widget.data),
      ),
    );
  }
}

class SheetContainer extends StatelessWidget {
  final Item data;

  SheetContainer({this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).cardColor),
      child: Column(
        children: <Widget>[
          drawerHandle(),
          Expanded(
            flex: 1,
            child: ListView(
              padding: EdgeInsets.only(left: 15),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      data.item_name,
                      style: style.headerStyle2,
                    ),
                    /*Text(
                      '  ${dish['cuisine']}',
                      style: style.subHintTitle,
                    )*/
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
               /* Row(
                  children: <Widget>[
                    SmoothStarRating(
                        allowHalfRating: false,
                        starCount: 5,
                        rating: dish['rating'],
                        size: 20.0,
                        color: Color(0xFFFEBF00),
                        borderColor: Color(0xFFFEBF00),
                        spacing: 0.0),
                    Text(
                      '  (${dish['rating']})',
                      style: style.subHintTitle,
                    )
                  ],
                ),*/
                /*SizedBox(
                  height: MediaQuery.of(context).size.height * 0.005,
                ),*/
                Row(
                  children: <Widget>[
                    Text(
                      '20 Pieces     ',
                      style: style.cardTitleStyle,
                    ),
                    Text(
                      '${data.item_price.toString()} \₹',
                      style: style.headerStyle3
                          .copyWith(color:  MikroMartColors.colorPrimary),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Product Description',
                  style: style.headerStyle2,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Pyongyang Matsutake and Spinach Sauce alongside Natural Shitaki Juice,Psychotropic Cheese in a mélange of Pan-fried Veal Pizza Craft Tuna and Black Truffle Blobs atop Home-grown Spam Cake Tepid Frankfurter with a side of Housemade Sea Urchin and Truffle Oil Confit Tepid Frankfurter with a side of Housemade Sea Urchin and Truffle Oil Confit',
                  style: style.textTheme,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                /*Text(
                  'Reviews',
                  style: style.headerStyle2,
                ),
                SizedBox(
                  height: 20,
                ),
                ListView(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    drawReviewTile(context, 'Joe Hattab', 'assets/profil.jpg'),
                    drawReviewTile(context, 'Sophie', 'assets/profile2.jpg'),
                    drawReviewTile(
                        context, 'Lionel Messi', 'assets/profile3.jpg'),
                    drawReviewTile(context, 'Pewdiepie', 'assets/profil4.jpg'),
                    SizedBox(height: 100,)
                  ],
                )*/
              ],
            ),
          )
        ],
      ),
    );
  }

  drawReviewTile(context, name, asset) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: AssetImage(asset))),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  name,
                  style: style.headerStyle3,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    SmoothStarRating(
                        allowHalfRating: false,
                        starCount: 5,
                        rating: 5,
                        size: 20.0,
                        color: Color(0xFFFEBF00),
                        borderColor: Color(0xFFFEBF00),
                        spacing: 0.0),
                    Text(
                      ' June 7, 2020',
                      style: style.subHintTitle,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'This is the best food you can ever try Delicious and Have a nice plating and the service and delivery was really quickly',
                  softWrap: true,
                  maxLines: 3,
                  style: style.textTheme.copyWith(fontSize: 14),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  drawerHandle() {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      height: 3,
      width: 65,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Color(0xffd9dbdb)),
    );
  }
}

class StateBloc {
  StreamController animationController = StreamController.broadcast();
  final StateProvider provider = StateProvider();

  Stream get animationStatus => animationController.stream;

  void toggleAnimation() {
    provider.toggleAnimationValue();
    animationController.sink.add(provider.isAnimating);
  }

  void dispose() {
    animationController.close();
  }
}

class StateProvider {
  bool isAnimating = true;

  void toggleAnimationValue() => isAnimating = !isAnimating;
}
