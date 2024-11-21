import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_management/provider/tm_provider.dart';

class WorkDetails extends StatefulWidget {
  final DateTime workDate;
  const WorkDetails({super.key, required this.workDate});

  @override
  State<WorkDetails> createState() => _WorkDetailsState();
}

class _WorkDetailsState extends State<WorkDetails> {
  int dividerCount = 18;
  List<Map<String, dynamic>>? breaks;
  Map<String, dynamic>? workData;
  bool isLoadingData = false;
  int totalBreakDuration = 0;
  double nettWorkedDay = 0;
  double grossWorkDay = 0;
  bool isWorkDeleting = false;

  Future<void> getBreaks({required int workSessionsId}) async {
    breaks = await Provider.of<TimeManagementPovider>(context, listen: false)
        .getBreaksFromSpecificDate(
            workSessionsId: workSessionsId, mounted: mounted);
    if (!mounted) return;
    getTotalOfBreakDuration(breaks: breaks!);
  }

  Future<void> getWorkData() async {
    setState(() {
      isLoadingData = true;
    });

    workData = await Provider.of<TimeManagementPovider>(context, listen: false)
        .getWorkDataFromSpecificDate(date: widget.workDate, mounted: mounted);
    if (!mounted) return;
    await getBreaks(workSessionsId: workData?["id"]);
    if (!mounted) return;
    getGrossWork();
    getNettWork();

    setState(() {
      isLoadingData = false;
    });
  }

  getTotalOfBreakDuration({required List<Map<String, dynamic>> breaks}) {
    int total = 0;
    for (Map<String, dynamic> breakData in breaks) {
      int formatDuration = breakData['duration'].toInt();
      total = total + formatDuration;
    }
    setState(() {
      totalBreakDuration = total;
    });
  }

  getGrossWork() {
    int workedDayInHourFormatInInt = workData?["workedTime"].toInt();
    setState(() {
      grossWorkDay = workedDayInHourFormatInInt / 60;
    });
  }

  getNettWork() {
    double nettWork = 0;
    int workedDayInHourFormatInInt = workData?["workedTime"].toInt();
    if (workedDayInHourFormatInInt > 0) {
      int difference = workedDayInHourFormatInInt - totalBreakDuration;

      nettWork = difference / 60;
    }

    setState(() {
      nettWorkedDay = nettWork;
    });
  }

  Future<void> deleteWork(
      {required int id,
      required String title,
      required String description,
      required String cancelText,
      required String confirmText}) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        icon: Icon(
          Icons.warning_amber,
          size: 33,
          color: Theme.of(context).colorScheme.error,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                isWorkDeleting = true;
              });
              final tm =
                  Provider.of<TimeManagementPovider>(context, listen: false);
              await tm.deleteWork(id: id);
              if (!context.mounted) return;
              Navigator.of(context).pop(true);
              setState(() {
                isWorkDeleting = false;
              });
            },
            child: Text(
              confirmText,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        tm.setOrientation(context);
        await getWorkData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getLabels.workDetails,
        ),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Platform.isIOS
              ? Icons.arrow_back_ios_new_outlined
              : Icons.arrow_back_outlined),
        ),
        bottom: isWorkDeleting
            ? const PreferredSize(
                preferredSize: Size(200, 3), child: LinearProgressIndicator())
            : null,
      ),
      body: workData != null && !isLoadingData
          ? SingleChildScrollView(
              child: Column(
                children: [
                  LeadingAndTitle(
                    leading: getLabels.date,
                    title: DateFormat(getLabels.dateFormat)
                        .format(widget.workDate),
                  ),
                  Text(
                    getLabels.workTime,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22.0),
                  ),
                  LeadingAndTitle(
                    leading: getLabels.startWork,
                    title: workData?['startTime'],
                  ),
                  LeadingAndTitle(
                    leading: getLabels.workEndedAt,
                    title: workData?['endTime'],
                  ),
                  LeadingAndTitle(
                    leading: getLabels.youWorkedHours,
                    title: grossWorkDay.toStringAsFixed(2),
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (double i = 0; i <= dividerCount; i++) ...{
                        if (i % 2 == 0) ...{
                          const Flexible(
                            child: SizedBox(
                              width: 20,
                              child: Divider(),
                            ),
                          ),
                        } else ...{
                          const Gap(10),
                        }
                      }
                    ],
                  ),
                  Text(
                    getLabels.breaks,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22.0),
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.01),
                  breaks != null && breaks!.isNotEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: ListView.builder(
                            itemCount: breaks?.length,
                            itemBuilder: (context, index) {
                              int breakNo = index + 1;
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 5.0),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Gap(MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                          RowLeadingAndTitle(
                                              leading: getLabels.breakNo,
                                              title: breakNo.toString()),
                                          Gap(MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                          RowLeadingAndTitle(
                                              leading: getLabels.breakStartedAt,
                                              title: breaks?[index]
                                                  ["breakStartTime"]),
                                          Gap(MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                          RowLeadingAndTitle(
                                              leading:
                                                  getLabels.breakFinishedAt,
                                              title: breaks?[index]
                                                  ["breakEndTime"]),
                                          Gap(MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                          Text(getLabels.youTook(
                                              "${breaks?[index]["duration"].toString()} Min"))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: Text(getLabels.noBreakTaken)),
                        ),
                  Gap(MediaQuery.of(context).size.height * 0.02),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5),
                    child: RowLeadingAndTitle(
                        leading: getLabels.totalBreakDurationMin,
                        title: totalBreakDuration.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5),
                    child: RowLeadingAndTitle(
                        leading: getLabels.youWorkedNetHours,
                        title: nettWorkedDay.toStringAsFixed(2)),
                  ),
                  TextButton(
                      style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(
                              EdgeInsets.only(bottom: 8.0))),
                      onPressed: () {
                        deleteWork(
                            id: workData?["id"],
                            title: getLabels.areYouSure,
                            description: getLabels.deleteWorkConfirmation,
                            cancelText: getLabels.cancel,
                            confirmText: getLabels.confirm);
                      },
                      child: Text(getLabels.deleteWorkDay)),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class LeadingAndTitle extends StatelessWidget {
  final String leading;
  final String title;
  const LeadingAndTitle(
      {super.key, required this.leading, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        leading,
        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
      ),
      trailing: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
    );
  }
}

class RowLeadingAndTitle extends StatelessWidget {
  final String leading;
  final String title;
  const RowLeadingAndTitle(
      {super.key, required this.leading, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          leading,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
        ),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  bool isPortrait(BuildContext context) {
    bool isPortraitGet = false;
    final mediaQuery = MediaQuery.of(context);

    bool isPortraitCheck = mediaQuery.orientation == Orientation.portrait;
    if (isPortraitCheck) {
      isPortraitGet = true;
    }
    return isPortraitGet;
  }
}
