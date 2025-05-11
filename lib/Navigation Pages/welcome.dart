import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/app/config/routes/app_pages.dart';
import 'package:time_management/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/db/mydb.dart';
import 'package:time_management/provider/category_provider.dart';
import 'package:time_management/provider/tm_provider.dart';
import 'package:time_management/provider/user_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isSending = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final tm = Provider.of<TimeManagementPovider>(context, listen: false);
        tm.setOrientation(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract MediaQuery data at the beginning of the build method
    final mediaQuery = MediaQuery.of(context);

    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Image.asset(
              '${Constants.imagePath}etm_back.png',
              height: MediaQuery.of(context).size.height * 0.53,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    shape: BoxShape.rectangle,
                    color: Theme.of(context).colorScheme.surface),
                child: Column(
                  children: [
                    InkWell(
                        onTap: () async {
                          final delete = TrackingDB();
                          // await delete.deleteDB();
                          final currentUser =
                              Provider.of<UserProvider>(context, listen: false);
                          print(currentUser.isUserLogin(context: context));
                          final categ = Provider.of<CategoryProvider>(context,
                              listen: false);
                          String catId = categ.selectedCategory['id'];
                          String dateToday =
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          // final tets = await delete.readData(
                          //     sql:
                          //         'select * from tracking_sessions where (isCompleted=0 and substr(startTime,1,10) ="$dateToday") OR (isCompleted =1 and substr(startTime,1,10) ="$dateToday" AND categoryId="$catId")');
                          final tets = await delete.readData(
                              sql: 'select * from categories ');
                          print(tets);
                          print(categ.selectedCategory);
                        },
                        child: Text(
                          "Test",
                          style: TextStyle(color: Colors.red),
                        )),
                    Gap(MediaQuery.of(context).size.height * 0.04),
                    Text(
                      '${l10n?.welcomeTo} ETM!',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: isPortrait
                              ? MediaQuery.of(context).size.width * 0.09
                              : MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold),
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.0009),
                    Center(
                      child: Text(
                        l10n?.subtitleWelcomePage ?? " ",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.028,
                        ),
                      ),
                    ),
                    Gap(isPortrait
                        ? MediaQuery.of(context).size.height * 0.28
                        : MediaQuery.of(context).size.height * 0.18),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.primaryContainer),
                            fixedSize: WidgetStatePropertyAll(Size(
                                MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.height * 0.06))),
                        onPressed: () => Get.toNamed(Routes.pageController)
                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => PagesController(),
                        // )),
                        ,
                        child: Text(
                          l10n?.startNow ?? "Start Now",
                          style: TextStyle(
                              fontSize: isPortrait
                                  ? MediaQuery.of(context).size.width * 0.04
                                  : MediaQuery.of(context).size.width * 0.027,
                              color: Theme.of(context).colorScheme.primary),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
