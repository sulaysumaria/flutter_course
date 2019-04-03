import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import './../constants.dart';
import './../models/product.dart';
import './../models/user.dart';
import './../models/auth.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;
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

  String get selProductId {
    return _selProductId;
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  Product get selectedProduct {
    if (_selProductId != null) {
      return _products.firstWhere((Product product) {
        return product.id == _selProductId;
      });
    }

    return null;
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    try {
      final http.Response response = await http.post(
        'https://flutter-course-62ecc.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
        body: json.encode(productData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      final Product newProduct = Product(
        id: responseData['name'],
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
      );

      _products.add(newProduct);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct() {
    final String deletedProductId = selectedProduct.id;

    _products.removeAt(selectedProductIndex);
    _selProductId = null;

    _isLoading = true;
    notifyListeners();

    return http
        .delete(
            'https://flutter-course-62ecc.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();

      return true;
    }).catchError((e) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price,
      [bool favouriteStatus = false]) {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn.pixabay.com/photo/2015/10/02/12/00/chocolate-968457_960_720.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    return http
        .put(
      'https://flutter-course-62ecc.firebaseio.com/products/$_selProductId.json?auth=${_authenticatedUser.token}',
      body: json.encode(updateData),
    )
        .then((http.Response response) {
      final Product newProduct = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        isFavourite: favouriteStatus,
      );

      _products[selectedProductIndex] = newProduct;

      _isLoading = false;
      notifyListeners();

      return true;
    }).catchError((e) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlFavourite;

    updateProduct(selectedProduct.title, selectedProduct.description,
            selectedProduct.image, selectedProduct.price, newFavouriteStatus)
        .then((_) {
      notifyListeners();
    });
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    notifyListeners();
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();

    return http
        .get(
      'https://flutter-course-62ecc.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
    )
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];

      final Map<String, dynamic> productListData = json.decode(response.body);

      if (productListData != null) {
        productListData.forEach((String productId, dynamic productData) {
          final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
          );

          fetchedProductList.add(product);
        });
      }

      _products = fetchedProductList;

      _isLoading = false;
      notifyListeners();

      _selProductId = null;
    }).catchError((e) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    String url;

    if (mode == AuthMode.Login) {
      url =
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$FIREBASE_API_KEY';
    } else {
      url =
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$FIREBASE_API_KEY';
    }

    try {
      http.Response response = await http.post(
        url,
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      bool hasError = true;
      String message = 'Something went wrong.';

      if (responseData.containsKey('idToken')) {
        hasError = false;
        message = 'Authentication succeeded.';

        _authenticatedUser = User(
          id: responseData['localId'],
          email: responseData['email'],
          token: responseData['idToken'],
        );

        setAuthTimeout(int.parse(responseData['expiresIn']));

        final DateTime now = DateTime.now();
        final DateTime expiryTime = now.add(
          Duration(seconds: int.parse(responseData['expiresIn'])),
        );

        _userSubject.add(true);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseData['idToken']);
        prefs.setString('userEmail', responseData['email']);
        prefs.setString('userId', responseData['localId']);
        prefs.setString('expiryTime', expiryTime.toIso8601String());
      } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
        message = 'This email was not found.';
      } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
        message = 'The password is invalid.';
      } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
        message = 'This email already exists.';
      }

      _isLoading = false;
      notifyListeners();

      return {
        'success': !hasError,
        'message': message,
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
      };
    }
  }

  void autoAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTime = prefs.getString('expiryTime');

    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTime);

      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();

        return;
      }

      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');

      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;

      _userSubject.add(true);

      setAuthTimeout(tokenLifeSpan);

      _authenticatedUser = User(
        id: userId,
        email: userEmail,
        token: token,
      );

      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    prefs.remove('expiryTime');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
      _userSubject.add(false);
    });
  }
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
