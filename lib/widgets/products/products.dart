import 'package:flutter/material.dart';

import './product_card.dart';

class Products extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  Products(this.products);

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        return ProductCard(products[index], index);
      },
    );
  }

  Widget _buildProductDefaultView() {
    return Center(
      child: Text('No products found, please add one.'),
    );

    // return Container();
  }

  @override
  Widget build(BuildContext context) {
    Widget productCard;

    if (products.length > 0) {
      productCard = _buildProductList();
    } else {
      productCard = _buildProductDefaultView();
    }

    return productCard;
  }
}
