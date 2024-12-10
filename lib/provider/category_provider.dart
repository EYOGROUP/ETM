import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  Future<List<Map<String, dynamic>>> getAllLokalUserCategories(
      {required bool mounted}) async {
    List<Map<String, dynamic>> categories = [];
    TrackingDB db = TrackingDB();
    bool isTableCategories = await db.doesTableExist("categories");
    if (mounted) {
      if (isTableCategories) {
        final getCategories =
            await db.readData(sql: "select * from categories");
        if (mounted) {
          categories = getCategories
              .map((category) => Map<String, dynamic>.from(category))
              .toList();
        }
      }
    }
    return categories;
  }

  // close Category
  Future<void> closeCategoryForNotPremiumUserAfterUseIt() async {
    Map<String, dynamic> closeCategory = {"isUnlocked": 0};
    if (_selectedCategory.isNotEmpty) {
      String categoryId = _selectedCategory["id"];

      TrackingDB db = TrackingDB();
      await db.updateData(
          tableName: "categories",
          data: closeCategory,
          id: categoryId,
          columnId: "id");
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
      required Map<String, dynamic> categorySet}) async {
    bool isInserted = false;
    final getCategories = await getAllLokalUserCategories(mounted: mounted);
    if (mounted) {
      bool categoryGet = getCategories
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
      required Map<String, dynamic> categorySet}) async {
    if (categorySet.isNotEmpty && categorySet["isUnlocked"]) {
      _isCategoryLocked = true;
    } else {
      bool isCategoryInserted = await isCategoryLokalInserted(
          mounted: mounted, categorySet: categorySet);
      if (mounted) {
        if (isCategoryInserted) {
          Map<String, dynamic> getCategory = await getLokalCategory(
              categoryId: categorySet["id"], mounted: mounted);
          if (getCategory["isUnlocked"] == 1) {
            _isCategoryLocked = true;
          }
        }
      }
    }
    notifyListeners();
  }

  // check if category locked or Free
  Future<void> getLockedCategories({
    required bool mounted,
  }) async {
    _lockedCategories.clear();
    List<Map<String, dynamic>> getCategories =
        await getAllLokalUserCategories(mounted: mounted);

    for (Map<String, dynamic> getCategory in getCategories) {
      if (getCategory["isUnlocked"] == 1) {
        _lockedCategories.add(getCategory);
      }
    }

    notifyListeners();
  }

  Future<void> unlockCategory(
      {required Map<String, dynamic> categorySet,
      required BuildContext context,
      required bool mounted}) async {
    // Code to activate category

    TrackingDB db = TrackingDB();
    bool isCategoryLokalInsertedGet = await isCategoryLokalInserted(
        mounted: mounted, categorySet: categorySet);
    if (!mounted) return;
    if (isCategoryLokalInsertedGet) {
      Map<String, dynamic> isUnlocked = {"isUnlocked": 1};
      await db.updateData(
          tableName: 'categories',
          data: isUnlocked,
          columnId: "id",
          id: categorySet["id"]);
    } else {
      ETMCategory category = ETMCategory(
          unlockExpiry: DateTime.now().add(Duration(days: 1)),
          icon: "icon",
          id: categorySet["id"],
          isUnlocked: true,
          isPremium: true,
          name: {});
      await db.insertData(
          tableName: "categories", data: category.toMapToLokal());
      if (!mounted) return;
      getLockedCategories(mounted: mounted);
    }
  }

  insertCategoryLokal(
      {required Map<String, dynamic> categorySet,
      required BuildContext context,
      required bool mounted}) async {
    TrackingDB db = TrackingDB();
    bool isCategoryLokalInsertedGet = await isCategoryLokalInserted(
        mounted: mounted, categorySet: categorySet);
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
      if (!mounted) return;
      getLockedCategories(mounted: mounted);
    }
  }
}
