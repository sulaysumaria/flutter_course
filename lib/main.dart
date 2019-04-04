import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';

import './constants.dart';
import './scoped-models/main.dart';
import './models/product.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

void main() {
  MapView.setApiKey(FIREBASE_API_KEY);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuth();

    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          brightness: Brightness.light,
          buttonColor: Colors.deepPurple,
        ),
        routes: {
          '/': (BuildContext context) {
            return !_isAuthenticated ? AuthPage() : ProductsPage(_model);
          },
          '/admin': (BuildContext context) {
            return !_isAuthenticated ? AuthPage() : ProductsAdminPage(_model);
          },
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(builder: (BuildContext context) {
              return AuthPage();
            });
          }

          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });

            // model.selectProduct(productId);

            return MaterialPageRoute<bool>(
              builder: (BuildContext context) {
                return !_isAuthenticated ? AuthPage() : ProductPage(product);
              },
            );
          }

          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) {
              return !_isAuthenticated ? AuthPage() : ProductsPage(_model);
            },
          );
        },
      ),
    );
  }
}
