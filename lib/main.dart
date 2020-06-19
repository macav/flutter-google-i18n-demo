import 'package:flutter/material.dart';
import 'package:flutter_google_i18n/flutter_google_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

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
                  child: Text("Switch to ${AppLocalizations.of(context).locale.languageCode == 'en' ? 'DE' : 'EN'}"),
                  onPressed: () {
                    Locale newLocale = AppLocalizations.of(context).locale.languageCode == 'en'
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
