import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  final List<String> pages = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    pages.add(route.settings.name ?? '');
    print(pages.toString());
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute == null) return;
    final index =
        pages.indexWhere((element) => newRoute.settings.name == element);
    pages[index] = newRoute.settings.name ?? '';
    print(pages.toString());
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    pages.remove(route.settings.name ?? '');
    print(pages.toString());
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    pages.remove(route.settings.name ?? '');
    print(pages.toString());
  }
}
