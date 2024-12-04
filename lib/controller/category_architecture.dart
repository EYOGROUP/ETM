import 'package:flutter/material.dart';

class ETMCategory {
  final String id; // Unique identifier for the category
  final Map<String, dynamic> name; // Name of the category (e.g., "Fitness")
  final Map<String, dynamic>? description; // Short description (optional)
  final bool isPremium; // Indicates if the category requires a premium account
  final bool
      isUnlocked; // Tracks if the category is unlocked (e.g., via ad or premium)
  final DateTime?
      unlockExpiry; // Expiry timestamp if unlocked temporarily (e.g., via ad)
  final String icon;
  ETMCategory({
    this.description,
    this.isPremium = false,
    this.isUnlocked = false,
    required this.unlockExpiry,
    required this.icon,
    required this.id,
    required this.name,
  });
  Map<String, dynamic> toMap({required bool isLokal}) {
    return {
      "id": id,
      "name": name,
      "description": description,
      "isPremium": isLokal
          ? isPremium
              ? 1
              : 0
          : isPremium,
      "unlockExpiry": isLokal ? unlockExpiry.toString() : unlockExpiry,
      "isUnlocked": isLokal
          ? isUnlocked
              ? 1
              : 0
          : isUnlocked,
      "icon": icon,
    };
  }

  Map<String, dynamic> toMapToLokal() {
    return {
      "id": id,
      "unlockExpiry": unlockExpiry.toString(),
      "isUnlocked": isUnlocked ? 1 : 0,
      "isPremium": isPremium ? 1 : 0
    };
  }

  static final List<ETMCategory> categories = [
    ETMCategory(
      id: "6dd44514-2116-4425-973b-91555472592a",
      name: {"en": "Work", "fr": "Travail", "de": "Arbeiten"},
      description: {
        "en": "Tasks and responsibilities related to your professional life.",
        "fr": "Tâches et responsabilités liées à votre vie professionnelle.",
        "de": "Aufgaben und Verantwortlichkeiten im beruflichen Leben."
      },
      icon: Icons.work_outline.toString(),
      unlockExpiry: null,
      isUnlocked: true,
      isPremium: true,
    ),
    ETMCategory(
      id: "575afc7a-e6c7-42d9-858d-1dac275393d1",
      name: {"en": "Learning", "fr": "Apprentissage", "de": "Lernen"},
      description: {
        "en": "Activities aimed at acquiring knowledge or skills.",
        "fr":
            "Activités visant à acquérir des connaissances ou des compétences.",
        "de": "Aktivitäten zur Wissens- oder Fähigkeitenvermittlung."
      },
      icon: Icons.school.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "96a15db4-0aa0-437a-9a64-1791e53a3f3b",
      name: {"en": "Fitness", "fr": "Fitness", "de": "Fitness"},
      description: {
        "en":
            "Physical activities to improve or maintain your health and fitness.",
        "fr":
            "Activités physiques pour améliorer ou maintenir votre santé et votre forme.",
        "de":
            "Körperliche Aktivitäten zur Verbesserung oder Erhaltung der Gesundheit."
      },
      icon: Icons.fitness_center.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "3e5c351c-e7bd-4750-af09-20b1da779df2",
      name: {"en": "Leisure", "fr": "Loisir", "de": "Freizeit"},
      description: {
        "en":
            "Activities for relaxation and enjoyment outside of work or responsibilities.",
        "fr":
            "Activités de détente et de plaisir en dehors du travail ou des responsabilités.",
        "de":
            "Aktivitäten zur Entspannung und zum Vergnügen außerhalb der Arbeit."
      },
      icon: Icons.beach_access.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "e276dc10-7fb3-48ae-9d3f-8fbf39e8b99c",
      name: {"en": "Household", "fr": "Ménage", "de": "Haushalt"},
      description: {
        "en": "Tasks related to maintaining and organizing your home.",
        "fr": "Tâches liées à l'entretien et à l'organisation de la maison.",
        "de": "Aufgaben zur Pflege und Organisation des Haushalts."
      },
      icon: Icons.house.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "c885a9c2-a09d-43d1-bc7c-fd45959110d2",
      name: {"en": "Finances", "fr": "Finances", "de": "Finanzen"},
      description: {
        "en": "Managing your income, expenses, investments, and savings.",
        "fr": "Gestion de vos revenus, dépenses, investissements et économies.",
        "de":
            "Verwaltung von Einnahmen, Ausgaben, Investitionen und Ersparnissen."
      },
      icon: Icons.account_balance.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "9cf65abb-9c26-46ad-b8d9-729ef2320111",
      name: {"en": "Family", "fr": "Famille", "de": "Familie"},
      description: {
        "en": "Activities and responsibilities related to your family life.",
        "fr": "Activités et responsabilités liées à votre vie familiale.",
        "de": "Aktivitäten und Verantwortlichkeiten im Familienleben."
      },
      icon: Icons.family_restroom.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "d695ed76-b765-4017-90c2-1db518c1567d",
      name: {"en": "Meditation", "fr": "Méditation", "de": "Meditation"},
      description: {
        "en": "Activities for mindfulness, relaxation, and mental well-being.",
        "fr":
            "Activités de pleine conscience, de relaxation et de bien-être mental.",
        "de":
            "Aktivitäten zur Achtsamkeit, Entspannung und geistigem Wohlbefinden."
      },
      icon: Icons.spa.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "ee5abcec-b5de-4349-b344-370368c42c52",
      name: {"en": "Travel", "fr": "Voyage", "de": "Reisen"},
      description: {
        "en": "Exploring new places and experiencing different cultures.",
        "fr":
            "Explorer de nouveaux endroits et découvrir différentes cultures.",
        "de": "Neue Orte entdecken und verschiedene Kulturen erleben."
      },
      icon: Icons.airplanemode_active.toString(),
      unlockExpiry: null,
    ),
    ETMCategory(
      id: "396627d6-bf79-4d95-bdc7-b552c211b005",
      name: {"en": "Projects", "fr": "Projets", "de": "Projekte"},
      description: {
        "en": "Tasks and goals related to personal or professional projects.",
        "fr":
            "Tâches et objectifs liés à des projets personnels ou professionnels.",
        "de":
            "Aufgaben und Ziele im Zusammenhang mit persönlichen oder beruflichen Projekten."
      },
      icon: Icons.assignment.toString(),
      unlockExpiry: null,
    ),
  ];
}
