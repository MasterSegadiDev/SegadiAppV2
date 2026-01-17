import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  Future<void> navigateTo(String routeName, {Object? arguments}) async {
    final navigator = navigationKey.currentState;
    if (navigator == null) {
      debugPrint('❌ Navigator no inicializado todavía');
      return;
    }
    await navigator.pushNamed(routeName, arguments: arguments);
  }

  Future<void> navigateToReplacement(String routeName,
      {Object? arguments}) async {
    final navigator = navigationKey.currentState;
    if (navigator == null) {
      debugPrint('❌ Navigator no inicializado todavía');
      return;
    }
    await navigator.pushReplacementNamed(routeName, arguments: arguments);
  }

  void goBack() {
    final navigator = navigationKey.currentState;
    if (navigator == null) {
      debugPrint('❌ Navigator no inicializado todavía');
      return;
    }
    navigator.pop();
  }
}
