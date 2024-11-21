import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:time_management/provider/tm_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
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
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Image.asset(
              '${Constants.imagePath}welcome_image.jpg',
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
                    Gap(MediaQuery.of(context).size.height * 0.04),
                    Text(
                      '${AppLocalizations.of(context)?.welcomeTo} ETM!',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: isPortrait
                              ? MediaQuery.of(context).size.width * 0.09
                              : MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold),
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.0009),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.subtitleWelcomePage,
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
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const PagesController(),
                            )),
                        child: Text(
                          AppLocalizations.of(context)!.startNow,
                          style: TextStyle(
                              fontSize: isPortrait
                                  ? MediaQuery.of(context).size.width * 0.04
                                  : MediaQuery.of(context).size.width * 0.027,
                              color: Theme.of(context).colorScheme.secondary),
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
