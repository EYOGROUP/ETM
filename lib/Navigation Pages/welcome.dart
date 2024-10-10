import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:time_management/Navigation%20Pages/pagination.dart';
import 'package:time_management/constants.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'Welcome to ETM!',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: MediaQuery.of(context).size.width * 0.1,
                          fontWeight: FontWeight.bold),
                    ),
                    Gap(MediaQuery.of(context).size.height * 0.0009),
                    const Text('Track your time locally, no login required.'),
                    Gap(MediaQuery.of(context).size.height * 0.05),
                    Gap(MediaQuery.of(context).size.height * 0.2),
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
                          'Start Now',
                          style: TextStyle(
                              fontSize: 22.0,
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
