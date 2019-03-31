import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './../../scoped-models/main.dart';
import './../../models/product.dart';

import './product_card.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products) {
    Widget productCard;

    if (products.length > 0) {
      productCard = ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductCard(products[index], index);
        },
      );
    } else {
      productCard = _buildProductDefaultView();
    }

    return productCard;
  }

  Widget _buildProductDefaultView() {
    return Center(
      child: Text('No products found, please add one.'),
    );

    // return Container();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildProductList(model.displayedProducts);
      },
    );
  }
}
