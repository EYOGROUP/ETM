import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:time_management/Navigation%20Pages/profile/infos/edit_name.dart';
import 'package:time_management/constants.dart';

class InfoPage extends StatefulWidget {
  final Map<String, dynamic> userDataGet;
  const InfoPage({super.key, required this.userDataGet});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    userData = widget.userDataGet;
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(getLabels.info),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About you',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Gap(5.0),
          CardLeadingAndTrailing(
            leading: getLabels.name,
            trailing: "${userData["firstName"]} ${userData["lastName"]}",
            onTap: () async {
              var userDataGet =
                  await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditNamePage(
                  userData: userData,
                ),
              ));
              if (!mounted) return;
              if (userDataGet != null) {
                if (userDataGet.isNotEmpty) {
                  setState(() {
                    userData = userDataGet;
                  });
                }
              }
            },
          ),
          CardLeadingAndTrailing(
            leading: getLabels.userName,
            trailing: userData["userName"],
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: "Gender",
            trailing: userData["gender"] != null && userData["gender"] != ""
                ? userData["gender"]
                : "None",
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: getLabels.phone,
            trailing: '+${userData["phoneCode"]} ${userData["phoneNumber"]}',
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: getLabels.email,
            trailing: userData["email"],
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: "Account Typ",
            trailing: "type",
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: "Account Status",
            trailing: userData["isVerified"]
                ? getLabels.verified
                : getLabels.notVerified,
            onTap: () {},
          ),
          CardLeadingAndTrailing(
            leading: getLabels.premiumStatus,
            trailing:
                userData["isPremium"] ? getLabels.active : getLabels.inactive,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
