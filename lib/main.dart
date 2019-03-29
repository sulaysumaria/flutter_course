import 'package:flutter/material.dart';

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
  List<Map<String, dynamic>> _products = [];

  void _addProduct(Map<String, dynamic> product) {
    setState(() {
      _products.add(product);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  void _updateProduct(int index, Map<String, dynamic> newProduct) {
    setState(() {
      _products[index] = newProduct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          return ProductsPage(
            products: _products,
          );
        },
        '/admin': (BuildContext context) {
          return ProductsAdminPage(
            addProduct: _addProduct,
            deleteProduct: _deleteProduct,
            products: _products,
            updateProduct: _updateProduct,
          );
        },
      },
      onGenerateRoute: (RouteSettings settings) {
        final List<String> pathElements = settings.name.split('/');
        if (pathElements[0] != '') {
          return null;
        }

        if (pathElements[1] == 'product') {
          final int index = int.parse(pathElements[2]);

          return MaterialPageRoute<bool>(
            builder: (BuildContext context) {
              return ProductPage(
                _products[index]['title'],
                _products[index]['image'],
                _products[index]['price'],
                _products[index]['description'],
              );
            },
          );
        }

        return null;
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return ProductsPage(
              products: _products,
            );
          },
        );
      },
    );
  }
}
