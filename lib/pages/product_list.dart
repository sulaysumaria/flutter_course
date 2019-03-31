import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_edit.dart';
import './../scoped-models/main.dart';

class ProductListPage extends StatefulWidget {
  final MainModel model;

  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  initState() {
    widget.model.fetchProducts();

    super.initState();
  }

  Widget _buildEditButton(BuildContext context, MainModel model, int index) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          model.selectProduct(model.allProducts[index].id);

          return ProductEditPage();
        })).then((_) {
          model.selectProduct(null);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allProducts[index].title),
              background: Container(
                color: Colors.red,
              ),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectProduct(model.allProducts[index].id);
                  model.deleteProduct().then((bool success) {
                    if (!success) {
                      showDialog(
                        context: context,
                        builder: (BuildContext contetx) {
                          return AlertDialog(
                            title: Text('Something went wrong'),
                            content: Text('Please try again'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Okay'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
                  ;
                }
              },
              direction: DismissDirection.endToStart,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(model.allProducts[index].title),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allProducts[index].image),
                    ),
                    subtitle:
                        Text('\$${model.allProducts[index].price.toString()}'),
                    trailing: _buildEditButton(context, model, index),
                  ),
                  Divider(),
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }
}
