import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './../widgets/ui_elements/title_default.dart';

import './../scoped-models/main.dart';
import './../models/product.dart';

class ProductPage extends StatelessWidget {
  final int index;

  ProductPage(this.index);

  Widget _buildAddressPriceRow(double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Union Square, San Fransisco',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.grey,
          ),
        ),
        Container(
          child: Text(
            '|',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 5.0),
        ),
        Text(
          '₹ ${price.toString()}',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.grey,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          final Product product = model.allProducts[index];

          return Scaffold(
            appBar: AppBar(
              title: Text(product.title),
            ),
            body: Column(
              children: <Widget>[
                Image.asset(product.image),
                Container(
                  child: TitleDefault(product.title),
                  padding: EdgeInsets.all(10.0),
                ),
                _buildAddressPriceRow(product.price),
                Container(
                  child: Text(
                    product.description,
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(10.0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
