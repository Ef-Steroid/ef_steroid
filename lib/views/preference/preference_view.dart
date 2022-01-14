import 'package:fast_dotnet_ef/app_settings.dart';
import 'package:fast_dotnet_ef/helpers/intl/language_helper.dart';
import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/views/preference/preference_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PreferenceView extends StatefulWidget {
  const PreferenceView({Key? key}) : super(key: key);

  @override
  _PreferenceViewState createState() => _PreferenceViewState();
}

class _PreferenceViewState extends State<PreferenceView> {
  final PreferenceViewModel vm = GetIt.I<PreferenceViewModel>();

  @override
  void initState() {
    super.initState();
    vm.initViewModelAsync();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Dialog(
      insetPadding: const EdgeInsets.all(80),
      child: Column(
        children: <Widget>[
          _ThemeSetting(
            vm: vm,
          ),
          _LanguageSetting(
            vm: vm,
          ),
          const Spacer(),
          ButtonBar(
            children: [
              OutlinedButton(
                onPressed: _onClosedButtonPressed,
                child: Text(l('Close')),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  void _onClosedButtonPressed() {
    Navigator.pop(context);
  }
}

class _ThemeSetting extends StatelessWidget {
  final PreferenceViewModel vm;

  const _ThemeSetting({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l('Theme'),
            style: textTheme.headline6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ThemeKey.values
                .map((e) => Expanded(
                      child: RadioListTile<ThemeKey>(
                        title: Text(e.toLocalizedString(context)),
                        value: e,
                        groupValue: AppSettings.prefTheme,
                        contentPadding: const EdgeInsets.only(right: 16.0),
                        onChanged: _onRadioChanged,
                      ),
                    ))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  void _onRadioChanged(ThemeKey? theme) {
    vm.updateTheme(theme: theme);
  }
}

class _LanguageSetting extends StatelessWidget {
  final PreferenceViewModel vm;

  const _LanguageSetting({
    Key? key,
    required this.vm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    final localeMapEntries = LanguageHelper.languages.entries;
    return ListTile(
      title: Text(l('Language')),
      subtitle: DropdownButton<String>(
        value: AppSettings.prefLocale,
        underline: const SizedBox.shrink(),
        items: localeMapEntries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value.name),
                ))
            .toList(growable: false),
        onChanged: _onDropdownChanged,
      ),
    );
  }

  void _onDropdownChanged(String? locale) {
    vm.updateLanguage(locale: locale);
  }
}
