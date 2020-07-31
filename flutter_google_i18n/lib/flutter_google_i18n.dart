library flutter_google_i18n;

import 'dart:async';
import 'dart:convert';

import 'package:async_resource/file_resource.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class GoogleI18n {
  List<String> loadedLanguages;
  Map<String, Map<String, String>> localizedValues;

  Future<List<String>> getLoadedLanguages() async {
    if (loadedLanguages == null) {
      await load();
    }
    return loadedLanguages;
  }

  Future<dynamic> loadSpreadsheetWithCache() async {
    final path = (await getApplicationDocumentsDirectory()).path;
    final cacheFile = File('$path/translations.json');

    final myDataResource = HttpNetworkResource<dynamic>(
      url:
          'https://spreadsheets.google.com/feeds/list/1TGbtKpdNRptYwUVtqmkI2L7Ix00i-fQMnrChGHx2Ajk/1/public/values?alt=json',
      parser: (contents) => json.decode(contents),
      cache: FileResource(cacheFile),
      strategy: CacheStrategy.networkFirst,
    );
    return await myDataResource.get();
  }

  Future<bool> load() async {
    var _result = await loadSpreadsheetWithCache();
    List<dynamic> entries = _result['feed']['entry'];
    loadedLanguages = entries[0]
        .keys
        .toList()
        .where((element) => element.startsWith('gsx') && element != 'gsx\$key')
        .map((element) => element.replaceFirst('gsx\$', ''))
        .toList()
        .cast<String>();
    localizedValues = Map.fromIterable(loadedLanguages, key: (e) => e, value: (_e) => {});

    entries.forEach((translation) {
      final key = translation['gsx\$key']['\$t'];
      loadedLanguages.forEach((language) {
        localizedValues[language][key] = translation['gsx\$$language']['\$t'];
      });
    });
    return true;
  }
}

class AppLocalizations {
  AppLocalizations._internal() {
    googleI18n = GoogleI18n();
  }

  Locale locale;
  List<String> supportedLocales;
  GoogleI18n googleI18n;

  static AppLocalizations _instance;
  static AppLocalizations get instance => _instance ?? (_instance = AppLocalizations._internal());
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, Map<String, String>> _localizedValues;

  Future<bool> load() async {
    var result = await googleI18n.load();
    instance.supportedLocales = googleI18n.loadedLanguages;
    instance._localizedValues = googleI18n.localizedValues;
    return result;
  }

  static refresh(final BuildContext context, final Locale newLocale) {
    final currentInstance = AppLocalizations.of(context);
    currentInstance.locale = newLocale;
  }

  String t(String key) {
    try {
      return instance._localizedValues[locale.languageCode][key];
    } on NoSuchMethodError catch (e) {
      return '$key translation missing.';
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  bool isSupported(Locale locale) {
    var supportedLocales = AppLocalizations.instance.supportedLocales;
    return supportedLocales == null
        ? true
        : supportedLocales.contains(locale) || supportedLocales.contains(locale.languageCode);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations.instance;
    localizations.locale = locale;
    await localizations.load();

    return localizations;
  }
}
