import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_management/provider/tm_provider.dart';

class WorkArchieves extends StatefulWidget {
  const WorkArchieves({super.key});

  @override
  State<WorkArchieves> createState() => _WorkArchievesState();
}

class _WorkArchievesState extends State<WorkArchieves> {
  List<DateTime> _dates = [];
  int numberOfBreaks = 0;
  bool isLoadingData = false;
  int workedTime = 0;
  bool isInhours = false;
  @override
  void initState() {
    super.initState();
    _dates.add(DateTime.now());
    getNumberOfWorkedHours();
    getNumberOfBreaks();
  }

  getNumberOfBreaks() async {
    final tmProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);
    setState(() {
      isLoadingData = true;
    });
    int getData = await tmProvider.getNumberOfBreaks(
        date: _dates.last, mounted: mounted, context: context);
    setState(() {
      numberOfBreaks = getData;
      isLoadingData = false;
    });
  }

  getNumberOfWorkedHours() async {
    final tmProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);

    Map<String, dynamic> getData =
        await tmProvider.getHoursOrMinutesWorkedForToday(
      choosedDate: _dates.last,
    );
    if (getData.isNotEmpty) {
      setState(() {
        isInhours = getData['isInHours'];
        workedTime = getData['hours'];
      });
    } else {
      setState(() {
        isInhours = false;
        workedTime = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(getLabels.archives),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.015),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${getLabels.chooseDate}: ",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Gap(MediaQuery.of(context).size.height * 0.02),
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                  lastDate: DateTime.now(),
                  calendarType: CalendarDatePicker2Type.single),
              value: _dates,
              onValueChanged: (value) async {
                setState(() {
                  _dates = value;
                });
                await getNumberOfBreaks();
                getNumberOfWorkedHours();
              },
            ),
            Gap(MediaQuery.of(context).size.height * 0.02),
            isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _dates.isNotEmpty
                                    ? '${getLabels.date} ${DateFormat(getLabels.dateFormat).format(_dates.first)}'
                                    : getLabels.date,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Gap(MediaQuery.of(context).size.height * 0.02),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                  text:
                                      '${getLabels.youWorkedHours}  $workedTime ',
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text: isInhours
                                        ? workedTime <= 1
                                            ? getLabels.hour
                                            : getLabels.hours
                                        : workedTime > 1
                                            ? getLabels.minutes
                                            : getLabels.minute,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                              ])),
                              ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: Text(
                                  numberOfBreaks <= 1
                                      ? "${getLabels.youHadBreaks} $numberOfBreaks ${getLabels.breakLabel}"
                                      : "${getLabels.youHadBreaks} $numberOfBreaks ${getLabels.breaks}",
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  getLabels.moreDetails,
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
