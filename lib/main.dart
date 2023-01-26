import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/views/head/head.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

void main() async {
  await Isar.open([ExchangeSchema]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: lightDynamic ?? const ColorScheme.light(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? const ColorScheme.dark(),
            useMaterial3: true,
          ),
          home: const HeadView(),
        );
      },
    );
  }
}
