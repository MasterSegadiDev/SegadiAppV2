import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/app/router/app_router_titles.dart';
import 'package:segadi/features/home/presentation/widgets/app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).matchedLocation;
    final title = AppRouteTitles.forPath(path);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101812), // negro verdoso, header
        foregroundColor: Colors.white, // ícono de menú y flecha de back
        elevation: 0,
        centerTitle: false,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
