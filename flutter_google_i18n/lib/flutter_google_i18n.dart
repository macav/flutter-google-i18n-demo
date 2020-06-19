library flutter_google_i18n;

import 'dart:async';
import 'dart:convert';

import 'package:async_resource/file_resource.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class GoogleI18n {
  static Future<dynamic> loadSpreadsheetWithCache() async {
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
}

class AppLocalizations {
  AppLocalizations(this.locale);

  Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, Map<String, String>> _localizedValues;

  Future<bool> load() async {
    var _result = await GoogleI18n.loadSpreadsheetWithCache();
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
