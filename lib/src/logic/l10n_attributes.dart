import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Default attributes are located at assets/attributes.json
///
/// Range from id=0 to id=14
///
/// - Accounts (type 0) -> from 0 to 1
/// - Income Types (type 1) -> from 2 to 6
/// - Expense Types (type 2) -> from 7 to 14
String? translatedDefaultAttribute(BuildContext context, int defaultAttributeid) => switch (defaultAttributeid) {
      // Accounts
      0 => AppLocalizations.of(context)!.mainBankAccountAccount,
      1 => AppLocalizations.of(context)!.walletAccount,

      // Income Types
      2 => AppLocalizations.of(context)!.benefitsIncomeType,
      3 => AppLocalizations.of(context)!.giftsIncomeType,
      4 => AppLocalizations.of(context)!.loansIncomeType,
      5 => AppLocalizations.of(context)!.salaryIncomeType,
      6 => AppLocalizations.of(context)!.othersIncomeType,

      // Expense Types
      7 => AppLocalizations.of(context)!.billsExpenseType,
      8 => AppLocalizations.of(context)!.foodExpenseType,
      9 => AppLocalizations.of(context)!.healthExpenseType,
      10 => AppLocalizations.of(context)!.homeExpenseType,
      11 => AppLocalizations.of(context)!.personalExpenseType,
      12 => AppLocalizations.of(context)!.recreationExpenseType,
      13 => AppLocalizations.of(context)!.transportsExpenseType,
      14 => AppLocalizations.of(context)!.othersExpenseType,
      _ => null,
    };
