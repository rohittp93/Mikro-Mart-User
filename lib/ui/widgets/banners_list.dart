import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/models/banner.dart';
import 'package:userapp/core/models/item_quantity.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import '../shared/text_styles.dart' as style;

class BannersList extends StatefulWidget {
  @override
  _OffersListState createState() => _OffersListState();
}

class _OffersListState extends State<BannersList> {
  int _current = 0;
  List<BannerImage> _banners = [];

  @override
  Future<void> initState() {
    super.initState();
    fetchBanners();
  }

  Future<List<BannerImage>> fetchBanners() async {
    _banners = await firebase.getBanners();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 12,
          ),
          (_banners != null && _banners.length != 0)
              ? CarouselSlider(
                  items: _banners.map((banner) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Card(
                        elevation: 2,
                        child: Container(
                          child: Container(
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Stack(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: NetworkImage(
                                                    banner.banner_image_path,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 2 / 1,
                      viewportFraction: 0.9,
                      //height: (((0.8 * screenWidth)) / 2),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _banners.map((url) {
              int index = _banners.indexOf(url);
              return Container(
                width: 6.0,
                height: 6.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? MikroMartColors.colorPrimary
                      : MikroMartColors.colorPrimary.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
