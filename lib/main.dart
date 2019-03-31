import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './scoped-models/main.dart';
import './models/product.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();

    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          brightness: Brightness.light,
          buttonColor: Colors.deepPurple,
        ),
        routes: {
          '/': (BuildContext context) {
            return AuthPage();
          },
          '/products': (BuildContext context) {
            return ProductsPage(model);
          },
          '/admin': (BuildContext context) {
            return ProductsAdminPage(model);
          },
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });

            // model.selectProduct(productId);

            return MaterialPageRoute<bool>(
              builder: (BuildContext context) {
                return ProductPage(product);
              },
            );
          }

          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) {
              return ProductsPage(model);
            },
          );
        },
      ),
    );
  }
}
