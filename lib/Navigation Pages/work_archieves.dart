import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkArchieves extends StatefulWidget {
  const WorkArchieves({super.key});

  @override
  State<WorkArchieves> createState() => _WorkArchievesState();
}

class _WorkArchievesState extends State<WorkArchieves> {
  List<DateTime> _dates = [];
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
                  calendarType: CalendarDatePicker2Type.range),
              value: _dates,
              onValueChanged: (value) {
                setState(() {
                  _dates = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
