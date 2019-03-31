import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './../../models/product.dart';
import './../../scoped-models/main.dart';

import './price_tag.dart';
import './../ui_elements/title_default.dart';
import './address_tag.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TitleDefault(product.title),
        SizedBox(
          width: 8.0,
        ),
        PriceTag('₹ ${product.price.toString()}'),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.info),
              color: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.pushNamed<bool>(
                  context,
                  '/product/' + model.allProducts[productIndex].id,
                );
              },
            ),
            IconButton(
              icon: model.allProducts[productIndex].isFavourite
                  ? Icon(Icons.favorite)
                  : Icon(Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(model.allProducts[productIndex].id);
                model.toggleProductFavouriteStatus();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          FadeInImage(
            image: NetworkImage(product.image),
            placeholder: AssetImage('assets/food.jpg'),
            height: 300.0,
            fit: BoxFit.cover,
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0),
            child: _buildTitlePriceRow(),
          ),
          AddressTag('Union Square, San Fransisco'),
          Text(product.userEmail),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
