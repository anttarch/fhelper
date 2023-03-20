import 'package:dynamic_color/dynamic_color.dart';
import 'package:fhelper/src/logic/collections/attribute.dart';
import 'package:fhelper/src/logic/collections/card.dart' as fhelper;
import 'package:fhelper/src/logic/collections/exchange.dart';
import 'package:fhelper/src/widgets/inputfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({super.key, required this.item});
  final Exchange item;

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  String exchangeDate(DateTime date) {
    final dateWithoutTime = DateTime(date.year, date.month, date.day);
    if (date.isAtSameMomentAs(dateWithoutTime)) {
      return DateFormat.yMd(
        Localizations.localeOf(context).languageCode,
      ).format(date);
    }
    return DateFormat.yMd(
      Localizations.localeOf(context).languageCode,
    ).add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 88 - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        AppLocalizations.of(context)!.details,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: InputField(
                              label: AppLocalizations.of(context)!.description,
                              placeholder: widget.item.eType != EType.transfer
                                  ? widget.item.description
                                  : AppLocalizations.of(context)!
                                      .transferDescription(widget.item.description.split(' ')[0], widget.item.description.split(' ')[1]),
                              readOnly: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: widget.item.value.isNegative ? AppLocalizations.of(context)!.price : AppLocalizations.of(context)!.amount,
                              placeholder: NumberFormat.simpleCurrency(
                                locale: Localizations.localeOf(context).languageCode,
                              ).format(widget.item.value),
                              readOnly: true,
                              textColor: Color(
                                widget.item.eType == EType.expense ? 0xffbd1c1c : 0xff199225,
                              ).harmonizeWith(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InputField(
                              label: AppLocalizations.of(context)!.date,
                              placeholder: exchangeDate(widget.item.date),
                              readOnly: true,
                            ),
                          ),
                          Visibility(
                            visible: widget.item.eType != EType.transfer,
                            child: FutureBuilder(
                              future: getAttributeFromId(Isar.getInstance()!, widget.item.typeId),
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: AppLocalizations.of(context)!.type(1),
                                    placeholder: snapshot.hasData ? snapshot.data!.name : AppLocalizations.of(context)!.deleted,
                                    readOnly: true,
                                  ),
                                );
                              },
                            ),
                          ),
                          FutureBuilder(
                            future: fhelper.getCardFromId(Isar.getInstance()!, widget.item.cardId),
                            builder: (context, snapshot) {
                              return Visibility(
                                visible: widget.item.value.isNegative && snapshot.hasData,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: AppLocalizations.of(context)!.card(1),
                                    placeholder: snapshot.hasData ? snapshot.data!.name : '',
                                    readOnly: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          FutureBuilder(
                            future: getAttributeFromId(Isar.getInstance()!, widget.item.accountId),
                            builder: (context, snapshot) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: InputField(
                                  label: widget.item.eType != EType.transfer ? AppLocalizations.of(context)!.account(1) : AppLocalizations.of(context)!.from,
                                  placeholder: snapshot.hasData ? snapshot.data!.name : AppLocalizations.of(context)!.deleted,
                                  readOnly: true,
                                ),
                              );
                            },
                          ),
                          if (widget.item.eType == EType.transfer)
                            FutureBuilder(
                              future: getAttributeFromId(Isar.getInstance()!, widget.item.accountIdEnd!),
                              builder: (context, snapshot) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: InputField(
                                    label: AppLocalizations.of(context)!.to,
                                    placeholder: snapshot.hasData ? snapshot.data!.name : AppLocalizations.of(context)!.deleted,
                                    readOnly: true,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(AppLocalizations.of(context)!.back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
