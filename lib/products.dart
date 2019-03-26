import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<Map<String, String>> products;
  final Function deleteProduct;

  Products(this.products, {this.deleteProduct});

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(products[index]['image']),
          Text(products[index]['title']),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Details'),
                onPressed: () {
                  Navigator.pushNamed<bool>(
                    context,
                    '/product/' + index.toString(),
                  ).then((bool value) {
                    if (value) {
                      deleteProduct(index);
                    }
                  });
                },
              ),
            ],
          ),
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
