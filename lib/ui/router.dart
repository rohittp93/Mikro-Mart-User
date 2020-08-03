import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/ui/views/OtpPage.dart';
import 'package:userapp/ui/views/PhonenumberRegister.dart';
import 'package:userapp/ui/views/address_screen.dart';
import 'package:userapp/ui/views/card_type.dart';
import 'package:userapp/ui/views/items_list.dart';
import 'package:userapp/ui/views/notificationPage.dart';
import 'package:userapp/ui/views/orders_list.dart';
import './views/HomePage.dart';
import './views/mainHome.dart';
import './views/shoppingCart.dart';
import './views/splashScreen.dart';
import './views/ProfilePage.dart';
import './views/favoritePage.dart';
import './views/PaymentPage.dart';
import 'views/walletpage.dart';
import 'views/card_create.dart';
import 'views/card_wallet.dart';

const String initialRoute = "login";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/phoneNumberRegister':
        return MaterialPageRoute(builder: (_) => PhoneNumberRegister());
      /*     case '/otpPage':
        var argument = settings.arguments;
        return MaterialPageRoute(builder: (_) => OtpPage(argument: argument));*/
      case '/cardList':
        return MaterialPageRoute(builder: (_) => WalletPage());
      case '/cardCreate':
        return MaterialPageRoute(builder: (_) => CardCreate());
      case '/cardWallet':
        return MaterialPageRoute(builder: (_) => CardWallet());
      case '/cardType':
        return MaterialPageRoute(builder: (_) => CardType());
      case '/paymentPage':
        return MaterialPageRoute(builder: (_) => PaymentPage());
      case '/splashScreen':
        final splash =  new SplashScreen();
        return MaterialPageRoute(builder: (_) => splash);
      case '/profilePage':
        final profile =  new ProfilePage();
        return MaterialPageRoute(builder: (_) => profile);
      case '/favoritePage':
        return MaterialPageRoute(builder: (_) => FavoriteList());
      case '/mainHome':
        final home =  MainHome();
        return MaterialPageRoute(builder: (_) => home);
      case '/notification':
        final page = NotificationPage();
        return MaterialPageRoute(builder: (context) => page);
      case '/shoppingCart':
        final shoppingRoute = ShoppingCart();
        return MaterialPageRoute(builder: (context) => shoppingRoute);
      case '/orders':
        final ordersRoute = OrderList();
        return MaterialPageRoute(builder: (context) => ordersRoute);
      case '/itemList':
        Category data = settings.arguments;
        final itemsListRoute = ItemsList(argument: data);
        return MaterialPageRoute(
            builder: (context) => itemsListRoute);

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
