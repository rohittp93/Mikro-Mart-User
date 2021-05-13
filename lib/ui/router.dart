import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/ui/views/CurvedPage.dart';
import 'package:userapp/ui/views/PhonenumberRegister.dart';
import 'package:userapp/ui/views/delivery_addresses.dart.dart';
import 'package:userapp/ui/views/items_list.dart';
import 'package:userapp/ui/views/notificationPage.dart';
import 'package:userapp/ui/views/orders_list.dart';
import 'package:userapp/ui/views/otp_verification_screen.dart';
import 'package:userapp/ui/views/profile_screen_new.dart';
import 'package:userapp/ui/views/shopping_cart_new.dart';
import './views/HomePage.dart';
import './views/mainHome.dart';
import './views/splashScreen.dart';

const String initialRoute = "login";

class MikromartRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/phoneNumberRegister':
        return MaterialPageRoute(builder: (_) => PhoneNumberRegister());
      /*     case '/otpPage':
        var argument = settings.arguments;
        return MaterialPageRoute(builder: (_) => OtpPage(argument: argument));*/
      case '/home':
        final splash = new HomePage();
        return MaterialPageRoute(builder: (_) => splash);
      case '/profilePage':
        final profile = new ProfilePage();
        return MaterialPageRoute(builder: (_) => profile);

      case '/deliveryAddressScreen':
        return MaterialPageRoute(builder: (_) => DeliveryAddressScreen());
      case '/mainHome':
        final home = MainHome();
        return MaterialPageRoute(builder: (_) => home);
      case '/curvedDesignPage':
        final home = CurvedPage();
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
        Store data = settings.arguments;
        final itemsListRoute = ItemsList(store: data);
        return MaterialPageRoute(builder: (context) => itemsListRoute);
      case '/otpVerification':
        String mobileNumber = settings.arguments;
        final otpScreenRoute = OTPScreen(mobileNumber: mobileNumber);
        return MaterialPageRoute(builder: (context) => otpScreenRoute);

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
