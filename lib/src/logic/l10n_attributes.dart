import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Default attributes are located at assets/attributes.json
///
/// Range from id=0 to id=20
///
/// - Accounts (type 0) -> from 0 to 4
/// - Income Types (type 1) -> from 5 to 9
/// - Expense Types (type 2) -> from 10 to 23
String? translatedDefaultAttribute(BuildContext context, int defaultAttributeid) => switch (defaultAttributeid) {
      // Accounts

      // MAIN BANK
      0 => AppLocalizations.of(context)!.mainBankAccount,
      1 => AppLocalizations.of(context)!.checkingSubaccount,

      // OTHERS
      2 => AppLocalizations.of(context)!.savingsSubaccount,
      3 => AppLocalizations.of(context)!.othersAccount,
      4 => AppLocalizations.of(context)!.walletSubaccount,

      // Income Types
      5 => AppLocalizations.of(context)!.benefitsIncomeType,
      6 => AppLocalizations.of(context)!.giftsIncomeType,
      7 => AppLocalizations.of(context)!.loansIncomeType,
      8 => AppLocalizations.of(context)!.salaryIncomeType,
      9 => AppLocalizations.of(context)!.othersIncomeType,

      // Expense Types

      // FOOD
      10 => AppLocalizations.of(context)!.foodExpenseType,
      11 => AppLocalizations.of(context)!.marketFOOD,
      12 => AppLocalizations.of(context)!.streetMarketFOOD,
      13 => AppLocalizations.of(context)!.bakeryFOOD,
      14 => AppLocalizations.of(context)!.restaurantFOOD,
      15 => AppLocalizations.of(context)!.othersExpenseType,

      // HOME
      16 => AppLocalizations.of(context)!.homeExpenseType,
      17 => AppLocalizations.of(context)!.housePaymentHOME,
      18 => AppLocalizations.of(context)!.cleaningHOME,
      19 => AppLocalizations.of(context)!.waterBillHOME,
      20 => AppLocalizations.of(context)!.electricityBillHOME,
      21 => AppLocalizations.of(context)!.propertyTaxHOME,
      22 => AppLocalizations.of(context)!.internetTVHOME,
      23 => AppLocalizations.of(context)!.othersExpenseType,
      // 8 => AppLocalizations.of(context)!.billsExpenseType,
      // 9 => AppLocalizations.of(context)!.healthExpenseType,
      // 10 => AppLocalizations.of(context)!.homeExpenseType,
      // 11 => AppLocalizations.of(context)!.personalExpenseType,
      // 12 => AppLocalizations.of(context)!.recreationExpenseType,
      // 13 => AppLocalizations.of(context)!.transportsExpenseType,
      // 14 => AppLocalizations.of(context)!.othersExpenseType,
      _ => null,
    };
