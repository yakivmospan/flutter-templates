import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'strings_en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': english,
  };

  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get transactions => translate('transactions');
  String get categories => translate('categories');
  String get charts => translate('charts');
  String get addExpense => translate('add_expense');
  String get addIncome => translate('add_income');
  String get addTransaction => translate('add_transaction');
  String get editTransaction => translate('edit_transaction');
  String get viewTransaction => translate('view_transaction');
  String get balance => translate('balance');
  String get amount => translate('amount');
  String get category => translate('category');
  String get date => translate('date');
  String get notes => translate('notes');
  String get type => translate('type');
  String get income => translate('income');
  String get expense => translate('expense');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get cancel => translate('cancel');
  String get errorLoading => translate('error_loading');
  String get retry => translate('retry');
  String get errorSaving => translate('error_saving');
  String get errorDeleting => translate('error_deleting');
  String get errorLoadingTransaction => translate('error_loading_transaction');
  String get categoriesComingSoon => translate('categories_coming_soon');
  String get chartsComingSoon => translate('charts_coming_soon');
  String get noTransactions => translate('no_transactions');
  String get notesOptional => translate('notes_optional');
  String get selectCategory => translate('select_category');
  String get selectDate => translate('select_date');
  String get filter => translate('filter');
  String get all => translate('all');
  String get dateRange => translate('date_range');
  String get applyFilters => translate('apply_filters');
  String get clearFilters => translate('clear_filters');
  String get spendingByCategory => translate('spending_by_category');
  String get deleteConfirmation => translate('delete_confirmation');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}