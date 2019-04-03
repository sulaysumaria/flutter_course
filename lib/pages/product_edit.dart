import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './../models/product.dart';
import './../scoped-models/main.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg',
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Title',
      ),
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
      initialValue: product == null ? '' : product.title,
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Product Description',
      ),
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return 'Description is required and should be 10+ characters long.';
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
      initialValue: product == null ? '' : product.description,
    );
  }

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Price',
      ),
      keyboardType: TextInputType.phone,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number.';
        }
      },
      onSaved: (String value) {
        _formData['price'] = double.parse(value);
      },
      initialValue: product == null ? '' : product.price.toString(),
    );
  }

  Widget _buildSubmitButton(MainModel model) {
    return model.isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RaisedButton(
            child: Text('Save'),
            textColor: Colors.white,
            onPressed: () => _submitForm(model),
          );
  }

  Widget _buildPageContent(MainModel model) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(model.selectedProduct),
              _buildDescriptionTextField(model.selectedProduct),
              _buildPriceTextField(model.selectedProduct),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(model),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(MainModel model) {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    if (model.selProductId == null) {
      model
          .addProduct(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        _formData['price'],
      )
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/').then((_) {
            model.selectProduct(null);
          });
        } else {
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
    } else {
      model
          .updateProduct(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        _formData['price'],
      )
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/').then((_) {
            model.selectProduct(null);
          });
        } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.selProductId == null
            ? _buildPageContent(model)
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: _buildPageContent(model),
              );
      },
    );
  }
}
