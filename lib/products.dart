import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<String> products;

  Products([this.products = const []]);

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset('assets/food.jpg'),
          Text(products[index]),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: _buildProductItem,
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
