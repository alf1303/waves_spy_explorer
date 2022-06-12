import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:waves_spy/src/charts/puzzle/puzzle_earnings.dart';
import 'package:waves_spy/src/helpers/helpers.dart';
import 'package:waves_spy/src/providers/asset_provider.dart';
import 'package:waves_spy/src/providers/data_script_provider.dart';
import 'package:waves_spy/src/providers/filter_provider.dart';
import 'package:waves_spy/src/providers/label_provider.dart';
import 'package:waves_spy/src/providers/nft_provider.dart';
import 'package:waves_spy/src/providers/progress_bars_provider.dart';
import 'package:waves_spy/src/providers/stats_provider.dart';
import 'package:waves_spy/src/providers/transaction_details_provider.dart';
import 'package:waves_spy/src/providers/transaction_provider.dart';
import 'package:get_it/get_it.dart';

import 'charts/puzzle/eagle_earnings.dart';
import 'helpers/firebase_analytics_service.dart';
import 'main_page.dart';

GetIt getIt = GetIt.instance;

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.address }) : super(key: key);
  final address;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<TransactionProvider>(create: (_) => TransactionProvider()),
      ChangeNotifierProvider<FilterProvider>(create: (_) => FilterProvider()),
      ChangeNotifierProvider<ProgressProvider>(create: (_) => ProgressProvider()),
      ChangeNotifierProvider<TransactionDetailsProvider>(create: (_) => TransactionDetailsProvider()),
      ChangeNotifierProvider<AssetProvider>(create: (_) => AssetProvider()),
      ChangeNotifierProvider<NftProvider>(create: (_) => NftProvider()),
      ChangeNotifierProvider<DataScriptProvider>(create: (_) => DataScriptProvider()),
      ChangeNotifierProvider<StatsProvider>(create: (_) => StatsProvider()),
      ChangeNotifierProvider<LabelProvider>(create: (_) => LabelProvider()),
    ],
      child: MaterialApp(
        // Providing a restorationScopeId allows the Navigator built by the
        // MaterialApp to restore the navigation stack when a user leaves and
        // returns to the app after it has been killed while running in the
        // background.
        restorationScopeId: 'app',
        navigatorObservers: [
          getIt<FirebaseAnalyticsService>().appAnalyticsObserver(),
        ],

        // Provide the generated AppLocalizations to the MaterialApp. This
        // allows descendant Widgets to display the correct translations
        // depending on the user's locale.
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
        ],

        // Use AppLocalizations to configure the correct application title
        // depending on the user's locale.
        //
        // The appTitle is defined in .arb files found in the localization
        // directory.
        onGenerateTitle: (BuildContext context) =>
        AppLocalizations.of(context)!.appTitle,

        // Define a light and dark color theme. Then, read the user's
        // preferred ThemeMode (light, dark, or system default) from the
        // SettingsController to display the correct theme.
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,

        // Define a function to handle named routes in order to support
        // Flutter web url navigation and deep linking.
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              switch (routeSettings.name) {
                case PuzzleEarnings.routeName:
                  return PuzzleEarnings();
                case EagleEarnings.routeName:
                  return EagleEarnings();
                default:
                  return MainPage(address: address);
              }
            },
          );
        },
      )
      ,);
  }
}

class MobilePage extends StatelessWidget {
  const MobilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Change orientation, please"),
      ),
    );
  }
}

