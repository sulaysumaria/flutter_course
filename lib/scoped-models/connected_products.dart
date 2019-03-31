import 'package:scoped_model/scoped_model.dart';

import './../models/product.dart';
import './../models/user.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  int _selProductIndex;
  User _authenticatedUser;

  void addProduct(
      String title, String description, String image, double price) {
    final Product newProduct = Product(
      title: title,
      description: description,
      image: image,
      price: price,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
    );

    _products.add(newProduct);
    notifyListeners();
  }
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return _products.where((Product product) => product.isFavourite).toList();
    }

    return List.from(_products);
  }

  int get selProductIndex {
    return _selProductIndex;
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  Product get selectedProduct {
    if (_selProductIndex != null) {
      return _products[_selProductIndex];
    }

    return null;
  }

  void selectProduct(int index) {
    _selProductIndex = index;
    if (index != null) {
      notifyListeners();
    }
  }

  void deleteProduct() {
    _products.removeAt(_selProductIndex);
    notifyListeners();
  }

  void updateProduct(
      String title, String description, String image, double price,
      [bool favouriteStatus = false]) {
    final Product newProduct = Product(
      title: title,
      description: description,
      image: image,
      price: price,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
      isFavourite: favouriteStatus,
    );

    _products[_selProductIndex] = newProduct;
    notifyListeners();
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlFavourite;

    updateProduct(selectedProduct.title, selectedProduct.description,
        selectedProduct.image, selectedProduct.price, newFavouriteStatus);
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(
      id: 'asdasdasd',
      email: email,
      password: password,
    );
  }
}
