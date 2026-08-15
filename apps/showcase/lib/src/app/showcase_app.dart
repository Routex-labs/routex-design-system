import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import 'showcase_home.dart';

class RoutexShowcaseApp extends StatelessWidget {
  const RoutexShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routex Design System',
      debugShowCheckedModeBanner: false,
      theme: RoutexTheme.light,
      home: const ShowcaseHome(),
    );
  }
}
