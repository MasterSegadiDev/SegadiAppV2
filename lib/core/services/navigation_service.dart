import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._internal();
  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    // currentState! permite navegar desde cualquier parte del código
    return navigationKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  void goBack() {
    return navigationKey.currentState!.pop();
  }
}
