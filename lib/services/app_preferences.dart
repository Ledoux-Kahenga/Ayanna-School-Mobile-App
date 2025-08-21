import 'package:shared_preferences/shared_preferences.dart';

double _exchangeRate = 2500; // Default: 1 USD = 2500 CDF

/// Sets the exchange rate (1 USD = ? CDF)
Future<void> setExchangeRate(double rate) async {
  _exchangeRate = rate;
  // Save to persistent storage if needed
}

/// Gets the current exchange rate (1 USD = ? CDF)
double getExchangeRate() {
  return _exchangeRate;
}

/// Converts an amount from USD to CDF
double usdToCdf(double usd) => usd * _exchangeRate;

/// Converts an amount from CDF to USD
double cdfToUsd(double cdf) => cdf / _exchangeRate;

/// Formats an amount with the selected currency
Future<String> formatAmount(double amount, {bool isUsd = false}) async {
  final currency = await getAppCurrency();
  if (currency == 'USD') {
    final value = isUsd ? amount : cdfToUsd(amount);
    return '${value.toStringAsFixed(2)} USD';
  } else {
    final value = isUsd ? usdToCdf(amount) : amount;
    return '${value.toStringAsFixed(0)} CDF';
  }
}

/// Sets the currency to use in the app ('USD' for dollar, 'CDF' for franc)
Future<void> setAppCurrency(String currencyCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_currency', currencyCode);
}

/// Gets the currently selected currency code ('USD' or 'CDF')
Future<String> getAppCurrency() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('app_currency') ?? 'CDF';
}

class AppPreferences {
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyCurrentSchoolYearId = 'current_school_year_id';
  static const String _keyIsConfigured = 'is_configured';

  // Vérifie si c'est le premier lancement de l'application
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  // Marque l'application comme ayant été lancée
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  // Vérifie si l'application est configurée (année scolaire sélectionnée)
  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsConfigured) ?? false;
  }

  // Marque l'application comme configurée
  static Future<void> setConfigured(bool configured) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsConfigured, configured);
  }

  // Sauvegarde l'ID de l'année scolaire en cours
  static Future<void> setCurrentSchoolYearId(int yearId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentSchoolYearId, yearId);
    await setConfigured(true);
  }

  // Récupère l'ID de l'année scolaire en cours
  static Future<int?> getCurrentSchoolYearId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentSchoolYearId);
  }

  // Remet à zéro les préférences (pour debugging ou réinitialisation)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
