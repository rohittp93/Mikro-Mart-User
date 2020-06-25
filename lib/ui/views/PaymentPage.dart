import '../../core/card_list_model.dart';
import '../../core/models/card_model.dart';
import '../widgets/card_chip.dart';
import '../widgets/card_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/titleAppBar.dart';
import '../shared/text_styles.dart' as style;

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CardListModelView cardlistProvided =
        Provider.of<CardListModelView>(context);
    return Scaffold(
      appBar: TitleAppBar(title: "Checkout"),
      body: Column(
        children: <Widget>[
          StreamBuilder<CardResults>(
            stream: cardlistProvided.selectedCard,
            builder: (context, AsyncSnapshot<CardResults> snapshot) {
              return !snapshot.hasData
                  ? CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 18),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context,'/cardList');
                        },
                        child: CardFromList(
                          cardModel: snapshot.data,
                        ),
                      ),
                    );
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            'Or Checkout With',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: RaisedButton(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Color(0xFFE5E6EA),
              child: Image.asset("assets/samsung.png"),
              onPressed: () {},
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: RaisedButton(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Color(0xFFE5E6EA),
              child: Image.asset(
                "assets/apple.png",
                width: MediaQuery.of(context).size.width * 0.2,
              ),
              onPressed: () {},
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: RaisedButton(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Color(0xFFE5E6EA),
              child: Image.asset(
                "assets/google.png",
              ),
              onPressed: () {},
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: RaisedButton(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Confirm Payment',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  Text('\$212.00',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

class CardFromList extends StatelessWidget {
  static const Widget dotPadding = SizedBox(width: 30);
  static final Widget dot = Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        "•",
        textScaleFactor: 2,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ));

  final CardResults cardModel;

  const CardFromList({this.cardModel});

  @override
  Widget build(BuildContext context) => Container(

        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: cardModel.cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3) ,spreadRadius: 4,blurRadius:8 )]
        ),
        child: RotatedBox(
          quarterTurns: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 5),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CardChip(),
                      CardLogo(cardModel.cardType),
                    ]),
                SizedBox(height: 40),
                Wrap(
                    children: List<Widget>.filled(
                  12,
                  dot,
                  growable: true,
                )
                      ..insert(
                          // now get the spaces
                          4,
                          dotPadding)
                      ..insert(9, dotPadding)
                      ..add(dotPadding)
                      ..add(Text(
                        cardModel.cardNumber.substring(12),
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 1.25,
                      ))),
                Text(cardModel.cardNumber.substring(12),
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cardModel.cardHolderName,
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Valid\nthru",
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 0.5,
                            textAlign: TextAlign.end,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            '${cardModel.cardMonth}/${cardModel.cardYear.substring(2)}',
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 1.2,
                          )
                        ],
                      )
                    ]),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      );
}
