import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:async_resource/file_resource.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class AppLocalizations {
  AppLocalizations(this.locale);

  Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, Map<String, String>> _localizedValues;

  Future<HttpNetworkResource<dynamic>> loadSpreadsheetWithCache() async {
    final path = (await getApplicationDocumentsDirectory()).path;
    final cacheFile = File('$path/translations.json');

    final myDataResource = HttpNetworkResource<dynamic>(
      url: 'https://spreadsheets.google.com/feeds/list/1TGbtKpdNRptYwUVtqmkI2L7Ix00i-fQMnrChGHx2Ajk/1/public/values?alt=json',
      parser: (contents) => json.decode(contents),
      cache: FileResource(cacheFile),
      strategy: CacheStrategy.networkFirst,
    );
    return myDataResource;
  }

  Future<bool> load() async {
    var _result = await (await loadSpreadsheetWithCache()).get();
    List<dynamic> entries = _result['feed']['entry'];
    _localizedValues = {'en': {}, 'de': {}};
    
    entries.forEach((translation) {
      final key = translation['gsx\$key']['\$t'];
      _localizedValues['en'][key] = translation['gsx\$en']['\$t'];
      _localizedValues['de'][key] = translation['gsx\$de']['\$t'];
    });
    return true;
  }

  static refresh(final BuildContext context, final Locale newLocale) {
    final currentInstance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    currentInstance.locale = newLocale;
  }

  String t(String key) {
    return _localizedValues[locale.languageCode][key];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();

    return localizations;
  }
}

class MyAppState extends State<MyApp> {
  Locale locale;

  @override
  void initState() {
    super.initState();
    locale = Locale('en');
  }

  onLocaleChange(Locale locale) {
    setState(() {
      this.locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Internationalization Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('de'),
      ],
      locale: Locale('en'),
      home: MyHomePage(onLocaleChange),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
}

class MyHomePage extends StatelessWidget {
  final void Function(Locale locale) onLocaleSwitch;

  MyHomePage(this.onLocaleSwitch);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('title')),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Text(AppLocalizations.of(context).t('title')),
          Padding(padding: EdgeInsets.only(top: 30)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton(
                items: [
                  DropdownMenuItem(child: Text('English'), value: 'en'),
                  DropdownMenuItem(child: Text('Deutsch'), value: 'de'),
                ],
                value: AppLocalizations.of(context).locale.languageCode,
                onChanged: (String value) {
                  Locale newLocale = Locale(value);
                  AppLocalizations.refresh(context, newLocale);
                  this.onLocaleSwitch(newLocale);
                },
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text(
                      "Switch to ${AppLocalizations.of(context).locale.languageCode == 'en' ? 'DE' : 'EN'}"),
                  onPressed: () {
                    Locale newLocale =
                        AppLocalizations.of(context).locale.languageCode == 'en'
                            ? const Locale('de')
                            : const Locale('en');
                    AppLocalizations.refresh(context, newLocale);
                    this.onLocaleSwitch(newLocale);
                  })
            ],
          )
        ],
      )),
    );
  }
}
