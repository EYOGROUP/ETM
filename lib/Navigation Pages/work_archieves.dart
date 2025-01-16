import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:time_management/Navigation%20Pages/work_details.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:time_management/provider/user_provider.dart';

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
  bool isWorkFinished = false;
  bool? isUserExist;
  final RefreshController _refreshController = RefreshController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setState(() {
          isLoadingData = true;
        });
        await getAllData();
        setState(() {
          isLoadingData = false;
        });
      },
    );
  }

  getAllData() async {
    final tmProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);
    final tm = Provider.of<TimeManagementPovider>(context, listen: false);
    tm.setOrientation(context);
    _dates.clear();
    _dates.add(DateTime.now());
    isUserExist = await Provider.of<UserProvider>(context, listen: false)
        .isUserLogin(context: context);
    if (!mounted) return;

    await isWorkFinishedCheck(
        isUserExist: isUserExist!, tmProvider: tmProvider);
    if (!mounted) return;
    // if (isWorkFinished) {
    await getNumberOfWorkedHours(tmProvider: tmProvider);

    await getNumberOfBreaks(tmProvider: tmProvider);
    // }
    if (!mounted) return;
  }

  Future<void> isWorkFinishedCheck(
      {required bool isUserExist,
      required TimeManagementPovider tmProvider}) async {
    isWorkFinished = await tmProvider.isWorkFiniheshed(
        date: _dates.first, context: context, isUserExist: isUserExist);
    setState(() {});
  }

  Future<void> getNumberOfBreaks(
      {required TimeManagementPovider tmProvider}) async {
    int getData = await tmProvider.getNumberOfBreaks(
        isUserExist: isUserExist!,
        date: _dates.last,
        mounted: mounted,
        context: context);
    setState(() {
      numberOfBreaks = getData;
    });
  }

  Future<void> getNumberOfWorkedHours(
      {required TimeManagementPovider tmProvider}) async {
    Map<String, dynamic> getData =
        await tmProvider.getHoursOrMinutesWorkedForToday(
      context: context,
      isUserExist: isUserExist!,
      choosedDate: _dates.last,
    );
    if (getData.isNotEmpty) {
      setState(() {
        isInhours = getData['isInHours'];
        workedTime = getData['hours'].toInt();
      });
    } else {
      setState(() {
        isInhours = false;
        workedTime = 0;
      });
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    await getAllData();
    if (!mounted) return;
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    final tmProvider =
        Provider.of<TimeManagementPovider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(getLabels.archives),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: Constants.smartRefresherHeader(getLabels: getLabels),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${getLabels.chooseDate}: ",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Gap(MediaQuery.of(context).size.height * 0.02),
                CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                      calendarViewMode: CalendarDatePicker2Mode.day,
                      lastDate: DateTime.now(),
                      calendarType: CalendarDatePicker2Type.single),
                  value: _dates,
                  onValueChanged: (value) async {
                    setState(() {
                      _dates = value;
                    });
                    await getNumberOfBreaks(tmProvider: tmProvider);
                    await getNumberOfWorkedHours(tmProvider: tmProvider);
                    await isWorkFinishedCheck(
                        isUserExist: isUserExist!, tmProvider: tmProvider);
                  },
                ),
                Gap(MediaQuery.of(context).size.height * 0.02),
                isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Column(
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
                                      '${isInhours ? getLabels.trackedHoursGross : getLabels.trackedMinutesGross}  $workedTime ',
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
                                trailing: isWorkFinished
                                    ? GestureDetector(
                                        onTap: () async {
                                          bool? isFinished =
                                              await Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                            builder: (context) => WorkDetails(
                                                workDate: _dates.first),
                                          ));
                                          if (!mounted) return;
                                          if (isFinished != null &&
                                              isFinished) {
                                            await _refreshController
                                                .requestRefresh();
                                            if (!context.mounted) return;
                                            Constants.showInSnackBar(
                                                value:
                                                    getLabels.timeEntryDeleted,
                                                context: context);
                                          }
                                        },
                                        child: Text(
                                          getLabels.moreDetails,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                      )
                                    : null,
                              )
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
