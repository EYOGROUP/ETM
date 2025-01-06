import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:time_management/controller/category_architecture.dart';
import 'package:time_management/db/mydb.dart';

import 'package:time_management/provider/user_provider.dart';

class CategoryProvider extends ChangeNotifier {
  bool _isCategoryLocked = false;
  bool get isCategoryLockedGet => _isCategoryLocked;
  Map<String, dynamic> _selectedCategory = {};
  Map<String, dynamic> get selectedCategory => _selectedCategory;
  final List<Map<String, dynamic>> _lockedCategories = [];
  List<Map<String, dynamic>> get lockedCategories => _lockedCategories;
  bool _isSwitchedToLokalCategories = false;
  bool get isSwitchedToLokalCategories => _isSwitchedToLokalCategories;
  bool _isSwitchedToCloudCategories = false;
  bool get isSwitchedToCloudCategories => _isSwitchedToCloudCategories;

  set switchToLokalCategories(bool switchTo) {
    _isSwitchedToLokalCategories = switchTo;
    notifyListeners();
  }

  set switchToCloudCategories(bool switchTo) {
    _isSwitchedToCloudCategories = switchTo;
    notifyListeners();
  }

  set setCategory(Map<String, dynamic> categories) {
    resetSelectedCategory();
    _selectedCategory = categories;
    notifyListeners();
  }

  void resetSelectedCategory() {
    if (_selectedCategory.isNotEmpty) {
      _selectedCategory.clear();
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(
      {required BuildContext context}) async {
    List<Map<String, dynamic>> getCategoriesList = [];
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_isSwitchedToLokalCategories) {
      getCategoriesList = ETMCategory.categories
          .map((category) => category.toMap(isLokal: true))
          .toList();
    } else {
      if (context.mounted) {
        bool isUserExists = await userProvider.isUserLogin(context: context);

        if (isUserExists) {
          final getCategories =
              await FirebaseFirestore.instance.collection("categories").get();
          if (getCategories.docs.isNotEmpty) {
            getCategoriesList =
                getCategories.docs.map((category) => category.data()).toList();
          }
        } else {
          getCategoriesList = ETMCategory.categories
              .map((category) => category.toMap(isLokal: true))
              .toList();
        }
      }
    }

    return getCategoriesList;
  }

  // Future<List<Map<String, dynamic>>> getAllLokalUserCategories(
  //     {required bool mounted}) async {
  //   List<Map<String, dynamic>> categories = [];
  //   TrackingDB db = TrackingDB();
  //   bool isTableCategories = await db.doesTableExist("categories");
  //   if (mounted) {
  //     if (isTableCategories) {
  //       final getCategories =
  //           await db.readData(sql: "select * from categories");
  //       if (mounted) {
  //         categories = getCategories
  //             .map((category) => Map<String, dynamic>.from(category))
  //             .toList();
  //       }
  //     }
  //   }
  //   return categories;
  // }

  // close Category
  Future<void> closeCategoryForNotPremiumUserAfterUseIt(
      {required bool isUserExit}) async {
    Map<String, dynamic> closeCategory = {};
    if (_selectedCategory.isNotEmpty) {
      String categoryId = _selectedCategory["id"];
      if (isUserExit) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        closeCategory["lockedCategories"] =
            FieldValue.arrayRemove([categoryId]);
        FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .update(closeCategory);
      } else {
        closeCategory["isUnlocked"] = 0;
        TrackingDB db = TrackingDB();
        await db.updateData(
            tableName: "categories",
            data: closeCategory,
            id: categoryId,
            columnId: "id");
      }
    }
  }

  // Activate a Category
  void activateCategory() {
    bool isUnlocked = true;
    _selectedCategory.update(
      "isUnlocked",
      (value) => isUnlocked,
    );
    notifyListeners();
  }

  // check if category inserted
  Future<bool> isCategoryLokalInserted(
      {required bool mounted,
      required BuildContext context,
      required Map<String, dynamic> categorySet}) async {
    bool isInserted = false;

    List<Map<String, dynamic>> getCategoriesList =
        await getCategories(context: context);

    if (mounted) {
      bool categoryGet = getCategoriesList
          .where((category) => category["id"] == categorySet["id"])
          .isNotEmpty;
      if (categoryGet) {
        isInserted = true;
      }
    }
    return isInserted;
  }

  Future<Map<String, dynamic>> getLokalCategory({
    required String categoryId,
    required bool mounted,
  }) async {
    Map<String, dynamic> categoryGet = {};
    TrackingDB db = TrackingDB();
    final getCategory = await db.readData(
        sql: "select * from categories where id='$categoryId'");
    if (mounted) {
      categoryGet = Map<String, dynamic>.from(getCategory.first);
    }
    return categoryGet;
  }

  // check if category locked or Free
  Future<void> isCategoryLocked(
      {required bool mounted,
      required BuildContext context,
      required Map<String, dynamic> categorySet}) async {
    if (categorySet.isNotEmpty && categorySet["isUnlocked"]) {
      _isCategoryLocked = true;
    } else {
      bool isCategoryInserted = await isCategoryLokalInserted(
          context: context, mounted: mounted, categorySet: categorySet);
      if (mounted) {
        if (isCategoryInserted) {
          Map<String, dynamic> getCategory = await getLokalCategory(
              categoryId: categorySet["id"], mounted: mounted);
          if (getCategory["isUnlocked"]) {
            _isCategoryLocked = true;
          }
        }
      }
    }
    notifyListeners();
  }

  // check if category locked or Free
  Future<void> getLockedCategories(
      {required bool mounted,
      required BuildContext context,
      bool? isUserExist}) async {
    _lockedCategories.clear();
    // List<Map<String, dynamic>> getCategories =
    //     await getAllLokalUserCategories(mounted: mounted);
    List<Map<String, dynamic>> getCategoriesList =
        await getCategories(context: context);

    List<Map<String, dynamic>> switchCategory = [];
    for (Map<String, dynamic> category in getCategoriesList) {
      if (category["isUnlocked"] == 0 || category["isUnlocked"] == 1) {
        DateTime? unlockExpiryCategory = DateFormat("yyyy-MM-dd HH:mm:ss")
            .tryParse(category['unlockExpiry']);
        ETMCategory categoryDate = ETMCategory(
            id: category['id'],
            unlockExpiry: unlockExpiryCategory,
            name: category['name'],
            icon: '',
            isPremium: category["isPremium"] == 0 ? false : true,
            isUnlocked: category["isUnlocked"] == 0 ? false : true,
            description: category['description']);
        switchCategory.add(categoryDate.toMap(isLokal: false));
      }
      //  else {
      //   switchCategory.add(category);
      // }
    }
    List<String> lockedUserCategory = [];
    if (isUserExist!) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      if (!mounted) return;
      Map<String, dynamic>? userDataAsMap = userData.data();
      lockedUserCategory = List.from(userDataAsMap?["lockedCategories"]);
    }

    for (Map<String, dynamic> getCategory in switchCategory) {
      if (getCategory["isUnlocked"] ||
          lockedUserCategory.contains(getCategory['id'])) {
        _lockedCategories.add(getCategory);
      }
    }
    print(_lockedCategories);
    notifyListeners();
  }

  Future<bool> isLokalCategoryInDBSaved(
      {required TrackingDB db,
      required String categoryId,
      required BuildContext context}) async {
    bool checkIfCategoryInDB = false;
    final getCategories = await db.readData(
        sql: "select * from categories where id='$categoryId'");
    if (context.mounted) {
      if (getCategories.isNotEmpty) {
        checkIfCategoryInDB = true;
      } else {
        checkIfCategoryInDB = false;
      }
    }
    return checkIfCategoryInDB;
  }

  Future<void> unlockCategory(
      {required Map<String, dynamic> categorySet,
      required BuildContext context,
      required bool mounted}) async {
    // Code to activate category

    bool isUserExists = await Provider.of<UserProvider>(context, listen: false)
        .isUserLogin(context: context);
    if (!context.mounted) return;
    if (isUserExists) {
      Map<String, dynamic> lockedCategory = {
        "lockedCategories": FieldValue.arrayUnion([categorySet['id']])
      };
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(lockedCategory);
      if (!context.mounted) return;
    } else {
      TrackingDB db = TrackingDB();
      if (!context.mounted) return;
      bool isCategoryLokalInsertedGet = await isCategoryLokalInserted(
          context: context, mounted: mounted, categorySet: categorySet);
      if (!context.mounted) return;
      bool isLokalCategoryInDBSavedChecked = await isLokalCategoryInDBSaved(
          context: context, db: db, categoryId: categorySet["id"]);

      if (!context.mounted) return;
      ETMCategory categoryGet = ETMCategory.categories
          .where((categoryGet) => categoryGet.id == categorySet["id"])
          .first;
      if (isCategoryLokalInsertedGet && isLokalCategoryInDBSavedChecked) {
        Map<String, dynamic> isUnlocked = {"isUnlocked": 1, "isPremium": 1};
        await db.updateData(
            tableName: 'categories',
            data: isUnlocked,
            columnId: "id",
            id: categorySet["id"]);
        if (!context.mounted) return;
      } else {
        ETMCategory category = ETMCategory(
            unlockExpiry: DateTime.now().add(Duration(days: 1)),
            icon: "icon",
            id: categorySet["id"],
            isUnlocked: true,
            isPremium: true,
            name: categoryGet.name);
        await db.insertData(
            tableName: "categories", data: category.toMapToLokal());
        if (!context.mounted) return;
      }
      bool isCategoreyInLocked = _lockedCategories
          .where((lockedCategory) => lockedCategory['id'] == categorySet["id"])
          .isNotEmpty;
      if (!isCategoreyInLocked) {
        categoryGet.isUnlocked = true;
        _lockedCategories.add(categoryGet.toMap(isLokal: true));
      }
    }
    if (!context.mounted) return;
    getLockedCategories(
        mounted: mounted, context: context, isUserExist: isUserExists);
  }

  insertCategoryLokal(
      {required Map<String, dynamic> categorySet,
      required BuildContext context,
      required bool mounted}) async {
    TrackingDB db = TrackingDB();
    bool isCategoryLokalInsertedGet = await isCategoryLokalInserted(
        context: context, mounted: mounted, categorySet: categorySet);
    if (!mounted) return;
    if (!isCategoryLokalInsertedGet) {
      ETMCategory category = ETMCategory(
          unlockExpiry: DateTime.now().add(Duration(days: 1)),
          icon: "icon",
          id: categorySet["id"],
          isUnlocked: true,
          name: {});
      await db.insertData(
          tableName: "categories", data: category.toMapToLokal());
      if (!context.mounted) return;
      getLockedCategories(
        mounted: mounted,
        context: context,
      );
    }
  }
}
