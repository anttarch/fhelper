import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Default attributes are located at assets/attributes.json
///
/// Range from id=0 to id=14
///
/// - Accounts (type 0) -> from 0 to 1
/// - Income Types (type 1) -> from 2 to 6
/// - Expense Types (type 2) -> from 7 to 14
String? translatedDefaultAttribute(BuildContext context, int defaultAttributeid) {
  switch (defaultAttributeid) {
    // Accounts
    case 0:
      return AppLocalizations.of(context)!.mainBankAccountAccount;
    case 1:
      return AppLocalizations.of(context)!.walletAccount;

    // Income Types
    case 2:
      return AppLocalizations.of(context)!.benefitsIncomeType;
    case 3:
      return AppLocalizations.of(context)!.giftsIncomeType;
    case 4:
      return AppLocalizations.of(context)!.loansIncomeType;
    case 5:
      return AppLocalizations.of(context)!.salaryIncomeType;
    case 6:
      return AppLocalizations.of(context)!.othersIncomeType;

    // Expense Types
    case 7:
      return AppLocalizations.of(context)!.billsExpenseType;
    case 8:
      return AppLocalizations.of(context)!.foodExpenseType;
    case 9:
      return AppLocalizations.of(context)!.healthExpenseType;
    case 10:
      return AppLocalizations.of(context)!.homeExpenseType;
    case 11:
      return AppLocalizations.of(context)!.personalExpenseType;
    case 12:
      return AppLocalizations.of(context)!.recreationExpenseType;
    case 13:
      return AppLocalizations.of(context)!.transportsExpenseType;
    case 14:
      return AppLocalizations.of(context)!.othersExpenseType;
    default:
      return null;
  }
}
