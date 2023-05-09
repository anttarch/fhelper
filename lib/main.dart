import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart';
import 'package:fhelper/src/logic/collections/card_bill.dart';
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/views/head/head.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  await Isar.open([ExchangeSchema, AttributeSchema, CardSchema, CardBillSchema], directory: dir.path);
  runApp(const MyApp());

  // Set default values for first launch
  final Isar isar = Isar.getInstance()!;
  final prefs = await SharedPreferences.getInstance();
  final json = await rootBundle.load('assets/attributes.json');
  if (!prefs.containsKey('default') || (prefs.containsKey('default') && prefs.getBool('default') == false)) {
    await isar.writeTxn(() async {
      await isar.attributes.importJsonRaw(json.buffer.asUint8List());
    }).then((_) => prefs.setBool('default', true));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightTheme = SeedColorScheme.fromSeeds(
          primaryKey: lightDynamic?.primary ?? const ColorScheme.light().primary,
          secondaryKey: lightDynamic?.secondary ?? const ColorScheme.light().secondary,
          tertiaryKey: lightDynamic?.tertiary ?? const ColorScheme.light().tertiary,
          tones: FlexTones.vivid(Brightness.light),
        );
        final lightThemeHc = SeedColorScheme.fromSeeds(
          primaryKey: lightDynamic?.primary ?? const ColorScheme.light().primary,
          secondaryKey: lightDynamic?.secondary ?? const ColorScheme.light().secondary,
          tertiaryKey: lightDynamic?.tertiary ?? const ColorScheme.light().tertiary,
          tones: FlexTones.highContrast(Brightness.light),
        );
        final darkTheme = SeedColorScheme.fromSeeds(
          primaryKey: darkDynamic?.primary ?? const ColorScheme.light().primary,
          secondaryKey: darkDynamic?.secondary ?? const ColorScheme.light().secondary,
          tertiaryKey: darkDynamic?.tertiary ?? const ColorScheme.light().tertiary,
          tones: FlexTones.vivid(Brightness.dark),
          brightness: Brightness.dark,
        );
        final darkThemeHc = SeedColorScheme.fromSeeds(
          primaryKey: darkDynamic?.primary ?? const ColorScheme.light().primary,
          secondaryKey: darkDynamic?.secondary ?? const ColorScheme.light().secondary,
          tertiaryKey: darkDynamic?.tertiary ?? const ColorScheme.light().tertiary,
          tones: FlexTones.ultraContrast(Brightness.dark),
          brightness: Brightness.dark,
        );
        return MaterialApp(
          title: 'FHelper',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('pt', 'BR'),
          ],
          theme: ThemeData.from(
            colorScheme: lightTheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData.from(
            colorScheme: darkTheme,
            useMaterial3: true,
          ),
          highContrastTheme: ThemeData.from(
            colorScheme: lightThemeHc,
            useMaterial3: true,
          ),
          highContrastDarkTheme: ThemeData.from(
            colorScheme: darkThemeHc,
            useMaterial3: true,
          ),
          home: const HeadView(),
        );
      },
    );
  }
}
