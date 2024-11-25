import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  List<Map<String, dynamic>>? worksData;
  bool isLoadingData = false;
  int totalBreakDuration = 0;
  double nettWorkedDay = 0;
  double grossWorkDayInHour = 0;
  int grossWorkDayInMin = 0;
  double netWorkDayInHour = 0;
  int netWorkDayInMin = 0;
  bool isWorkDeleting = false;
  bool isInHoursGross = true;
  bool isInHoursNet = true;
  Map<String, dynamic>? _selectedCategoryForFilter;
  final RefreshController _refreshController = RefreshController();
  String netWorkTimeLabel = '';
  String grossWorkTimeLabel = '';

  Future<void> getAllCategoriesBreaks() async {
    breaks = await Provider.of<TimeManagementPovider>(context, listen: false)
        .getBreaksFromSpecificDate(
            breakSessionTime: widget.workDate,
            mounted: mounted,
            workSessionId: _selectedCategoryForFilter?["id"]);
    if (!mounted) return;
    getTotalOfBreakDuration(breaks: breaks!);
  }

  Future<void> getBreaks({required int workSessionsId}) async {
    // breaks = await Provider.of<TimeManagementPovider>(context, listen: false)
    //     .getBreaksFromSpecificDateAndId(
    //         workSessionsId: workSessionsId, mounted: mounted);
    // if (!mounted) return;
    getTotalOfBreakDuration(breaks: breaks!);
  }

  Future<void> getWorkData() async {
    setState(() {
      isLoadingData = true;
    });

    worksData = await Provider.of<TimeManagementPovider>(context, listen: false)
        .getWorkDataFromSpecificDate(
            date: widget.workDate,
            mounted: mounted,
            categoryId: _selectedCategoryForFilter?["id"]);
    print(worksData);
    if (!mounted) return;
    await getAllCategoriesBreaks();
    // await getBreaks(workSessionsId: worksData?.first["id"]);
    if (!mounted) return;
    getGrossWork(worksData: worksData!);
    getNettWork(worksData: worksData!);

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

  getGrossWork({required List<Map<String, dynamic>> worksData}) {
    int workedDayInHourFormatInInt = 0;
    for (Map<String, dynamic> workData in worksData) {
      int workDayDuration = workData["workedTime"];
      workedDayInHourFormatInInt += workDayDuration;
    }
    if (workedDayInHourFormatInInt >= 60) {
      grossWorkDayInHour = workedDayInHourFormatInInt / 60;
      if (grossWorkDayInHour % 1 == 0) {
        grossWorkTimeLabel = "${grossWorkDayInHour.toInt()} H";
      } else {
        List grossInHourSplit =
            grossWorkDayInHour.toStringAsFixed(2).split(".");
        grossWorkTimeLabel =
            "${grossInHourSplit[0]}H ${grossInHourSplit[1]}min";
      }
    } else {
      grossWorkTimeLabel = "$workedDayInHourFormatInInt min";
      isInHoursGross = false;
    }
    setState(() {});
  }

  getNettWork({required List<Map<String, dynamic>> worksData}) {
    int workedDayInHourFormatInInt = 0;
    for (Map<String, dynamic> workData in worksData) {
      int workTime = workData["workedTime"];
      workedDayInHourFormatInInt += workTime;
    }
    if (workedDayInHourFormatInInt > 0) {
      int difference = workedDayInHourFormatInInt - totalBreakDuration;
      if (difference >= 60) {
        netWorkDayInHour = difference / 60;
        if (netWorkDayInHour % 1 == 0) {
          netWorkTimeLabel = "${netWorkDayInHour.toInt()}H  ";
        } else {
          List networkDay = netWorkDayInHour.toStringAsFixed(2).split(".");
          netWorkTimeLabel = "${networkDay[0]}H ${networkDay[1]}min ";
        }
      } else {
        netWorkDayInMin = difference;
        netWorkTimeLabel = "$difference min";
        isInHoursNet = false;
      }
    }

    setState(() {});
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

  showBottomFilter({required AppLocalizations labels}) async {
    List<Map<String, dynamic>> categories = [
      {
        "id": 0,
        "name": labels.allCategories,
      },
    ];
    final getCategories =
        await Provider.of<TimeManagementPovider>(context, listen: false)
            .getCategories(context: context, mounted: mounted);
    if (!mounted) return;
    if (getCategories.isNotEmpty) {
      for (Map<String, dynamic> category in getCategories) {
        categories.add(category);
      }
    }
    if (_selectedCategoryForFilter == null ||
        _selectedCategoryForFilter!.isEmpty) {
      _selectedCategoryForFilter = categories.first;
    }

    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Card(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                  vertical: MediaQuery.of(context).size.height * 0.03),
              width: MediaQuery.of(context).size.width * 0.98,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text('Filter',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22.0)),
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.02),
                  Text(labels.selectCategory,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0)),
                  Gap(MediaQuery.of(context).size.height * 0.02),
                  if (getCategories.isNotEmpty)
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButton(
                              borderRadius: BorderRadius.circular(11.0),
                              menuMaxHeight:
                                  MediaQuery.of(context).size.height * 0.2,
                              isExpanded: true,
                              hint: Text(_selectedCategoryForFilter?['name']),
                              items: categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category["name"]),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryForFilter = value;
                                });
                              },
                            ),
                            Gap(MediaQuery.of(context).size.height * 0.02),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryForFilter = categories.first;
                                });
                              },
                              child: Text(
                                "Reset Filters",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                            Gap(MediaQuery.of(context).size.height * 0.12),
                            Center(
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Theme.of(context)
                                              .colorScheme
                                              .primaryContainer),
                                      alignment: Alignment.center,
                                      fixedSize: WidgetStatePropertyAll(Size(
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                          MediaQuery.of(context).size.height *
                                              0.02))),
                                  onPressed: () {
                                    _refreshController.requestRefresh();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                  )),
                            )
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> refreshFunction() async {
    await getWorkData();
    if (!mounted) return;
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
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
      body: worksData != null && !isLoadingData
          ? SmartRefresher(
              controller: _refreshController,
              enablePullUp: false,
              onRefresh: refreshFunction,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Filter:",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22.0),
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap: () => showBottomFilter(labels: getLabels),
                              child: Icon(Icons.filter_list)),
                        ],
                      ),
                    ),
                    LeadingAndTitle(
                      leading: "Category:",
                      title: _selectedCategoryForFilter != null
                          ? _selectedCategoryForFilter!["name"]
                          : getLabels.allCategories,
                    ),
                    LeadingAndTitle(
                      leading: getLabels.date,
                      title: DateFormat(getLabels.dateFormat)
                          .format(widget.workDate),
                    ),
                    if (worksData!.isNotEmpty) ...{
                      Text(
                        getLabels.workTime,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22.0),
                      ),
                      LeadingAndTitle(
                        leading: getLabels.startWork,
                        title: worksData?.first['startTime'],
                      ),
                      LeadingAndTitle(
                        leading: getLabels.workEndedAt,
                        title: worksData?.last['endTime'],
                      ),
                      LeadingAndTitle(
                        leading: isInHoursGross
                            ? getLabels.youWorkedHours
                            : getLabels.youWorkedInMinuteGross,
                        title: grossWorkTimeLabel,
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
                      if ((_selectedCategoryForFilter != null &&
                          _selectedCategoryForFilter?["id"] != 0)) ...{
                        breaks != null && breaks!.isNotEmpty
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
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
                                                    leading: getLabels
                                                        .breakStartedAt,
                                                    title: breaks?[index]
                                                        ["breakStartTime"]),
                                                Gap(MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                                RowLeadingAndTitle(
                                                    leading: getLabels
                                                        .breakFinishedAt,
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
                                    height: MediaQuery.of(context).size.height *
                                        0.28,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(getLabels.noBreakTaken),
                                    )),
                              ),
                      },
                      Gap(MediaQuery.of(context).size.height * 0.02),
                      if (_selectedCategoryForFilter == null ||
                          _selectedCategoryForFilter?["id"] == 0) ...{
                        Gap(MediaQuery.of(context).size.height * 0.05),
                        Text(getLabels.viewBreakDetails),
                        Gap(MediaQuery.of(context).size.height * 0.23),
                      },
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
                            leading: isInHoursNet
                                ? getLabels.youWorkedNetHours
                                : getLabels.youWorkedInMinuteNet,
                            title: netWorkTimeLabel),
                      ),
                      if (_selectedCategoryForFilter != null &&
                          _selectedCategoryForFilter?['id'] != 0)
                        TextButton(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.only(bottom: 8.0))),
                            onPressed: () {
                              deleteWork(
                                  id: worksData?.first["id"],
                                  title: getLabels.areYouSure,
                                  description: getLabels.deleteWorkConfirmation,
                                  cancelText: getLabels.cancel,
                                  confirmText: getLabels.confirm);
                            },
                            child: Text(getLabels.deleteWorkDay)),
                    } else ...{
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(child: Text(getLabels.noDataFound)))
                    }
                  ],
                ),
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
