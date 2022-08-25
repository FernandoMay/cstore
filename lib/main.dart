import 'package:cstore/cart.dart';
import 'package:cstore/detail.dart';
import 'package:cstore/home.dart';
import 'package:cstore/models.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

void main() {
  // setPathUrlStrategy();
  runApp(VxState(store: Store(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var vxNavigator = VxNavigator(routes: {
      "/": (_, __) => const MaterialPage(child: Home()),
      "/home": (_, __) => const MaterialPage(child: Home()),
      "/detail": (uri, _) {
        final catalog = (VxState.store as Store)
            .catalog
            .getById(int.parse(uri.queryParameters["id"].toString()));
        return MaterialPage(
            child: Detail(
          catalog: catalog,
        ));
      },
      // MyRoutes.loginRoute: (_, __) => MaterialPage(child: LoginPage()),
      // MyRoutes.signupRoute: (_, __) => MaterialPage(child: SignUpPage()),
      "/cart": (_, __) => const MaterialPage(child: CartView()),
    });
    (VxState.store as Store).navigator = vxNavigator;

    return MaterialApp.router(
      themeMode: ThemeMode.system,
      // theme: ThemeData..lightTheme(context),
      // darkTheme: MyTheme.darkTheme(context),
      debugShowCheckedModeBanner: false,
      routeInformationParser: VxInformationParser(),
      routerDelegate: vxNavigator,
    );
  }
}
