import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:slider_button/slider_button.dart';

class StartTimePage extends StatefulWidget {
  const StartTimePage({super.key});

  @override
  State<StartTimePage> createState() => _StartTimePageState();
}

class _StartTimePageState extends State<StartTimePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.06,
            vertical: MediaQuery.of(context).size.height * 0.015),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome User !',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  fontWeight: FontWeight.bold),
            ),
            Gap(MediaQuery.of(context).size.height * 0.02),
            Text(
              'Start trackin Time',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.02),
            ),
            Gap(MediaQuery.of(context).size.height * 0.02),
            SliderButton(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              action: () async {
                await Future.delayed(Duration(seconds: 3));
                print('hez');
                return false;
              },
              vibrationFlag: true,
              width: MediaQuery.of(context).size.width * 0.9,
              alignLabel: Alignment.center,
              buttonColor: Theme.of(context).colorScheme.primary,
              shimmer: true,
              highlightedColor: Theme.of(context).colorScheme.primary,
              baseColor: Theme.of(context).colorScheme.onSurface,
              label: Text(
                'Start Tracking',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 17),
              ),
              icon: Icon(
                Icons.arrow_circle_right_outlined,
                size: MediaQuery.of(context).size.height * 0.07,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
