import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/views/head/head.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:isar/isar.dart';

void main() async {
  await Isar.open([ExchangeSchema, AttributeSchema]);
  runApp(const MyApp());

  // Set default values for first launch
  final Isar isar = Isar.getInstance()!;
  final json = await rootBundle.load('assets/attributes.json');
  if (await isar.attributes.count() == 0) {
    await isar.writeTxn(() async {
      await isar.attributes.importJsonRaw(json.buffer.asUint8List());
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Flutter Demo',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('pt', 'BR'),
          ],
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
