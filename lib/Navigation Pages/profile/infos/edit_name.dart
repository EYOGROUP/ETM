import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:time_management/constants.dart';
import 'package:time_management/provider/user_provider.dart';

class EditNamePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditNamePage({super.key, required this.userData});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.userData["firstName"]);
    _lastNameController =
        TextEditingController(text: widget.userData["lastName"]);
  }

  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> editName() async {
    Map<String, dynamic> userNameUpdate = {};
    if (widget.userData["firstName"] != _firstNameController?.text) {
      userNameUpdate["firstName"] = _firstNameController?.text;
      widget.userData
          .update("firstName", (value) => _firstNameController?.text);
    }
    if (widget.userData['lastName'] != _lastNameController?.text) {
      userNameUpdate["lastName"] = _lastNameController?.text;
      widget.userData.update("lastName", (value) => _lastNameController?.text);
    }
    if (userNameUpdate.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.editUserFullName(
          userNameUpdateMap: userNameUpdate,
          userId: widget.userData["id"],
          context: context);
      if (mounted) {
        Navigator.of(context).pop(widget.userData);
      }
    }
  }

  bool isNameChanged() {
    bool isChangedName = false;
    if (widget.userData["firstName"] != _firstNameController?.text) {
      isChangedName = true;
    }
    if (widget.userData['lastName'] != _lastNameController?.text) {
      isChangedName = true;
    }

    return isChangedName;
  }

  @override
  Widget build(BuildContext context) {
    final getLabels = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(getLabels.name),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () => editName(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getLabels.send,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: isNameChanged()
                          ? null
                          : Theme.of(context).colorScheme.outline),
                ),
              ),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(20.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getLabels.enterNewName,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Gap(20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width / 2.3,
                  child: TextFieldWithValidator(
                      controller: _firstNameController!,
                      getLabels: getLabels.firstName,
                      onChange: (p0) {
                        isNameChanged();
                        setState(() {});
                      },
                      validator: (firstName) {
                        return firstName!.isNotEmpty
                            ? null
                            : getLabels.fieldMustNotBeEmpty;
                      },
                      textType: TextInputType.name),
                ),
                Gap(20.0),
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width / 2.2,
                  child: TextFieldWithValidator(
                      onChange: (p0) {
                        isNameChanged();
                        setState(() {});
                      },
                      controller: _lastNameController!,
                      getLabels: getLabels.firstName,
                      validator: (lastName) {
                        return lastName!.isNotEmpty
                            ? null
                            : getLabels.fieldMustNotBeEmpty;
                      },
                      textType: TextInputType.name),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
