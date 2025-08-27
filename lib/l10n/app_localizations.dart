import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('ar')
  ];

  /// No description provided for @titleRoutines.
  ///
  /// In fr, this message translates to:
  /// **'Routines'**
  String get titleRoutines;

  /// No description provided for @manage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer'**
  String get manage;

  /// No description provided for @newRoutine.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle routine'**
  String get newRoutine;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @filterDaily.
  ///
  /// In fr, this message translates to:
  /// **'Quotidien'**
  String get filterDaily;

  /// No description provided for @filterWeekly.
  ///
  /// In fr, this message translates to:
  /// **'Hebdomadaire'**
  String get filterWeekly;

  /// No description provided for @filterMonthly.
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get filterMonthly;

  /// No description provided for @reorderCategoriesUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Ordre des catégories mis à jour'**
  String get reorderCategoriesUpdated;

  /// No description provided for @reorderRoutinesUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Ordre des routines mis à jour'**
  String get reorderRoutinesUpdated;

  /// No description provided for @reorderTasksUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Ordre des tâches mis à jour'**
  String get reorderTasksUpdated;

  /// No description provided for @settingsReorderSnackTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer les réordonnancements'**
  String get settingsReorderSnackTitle;

  /// No description provided for @settingsReorderSnackSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Snack discret après appui-glissé'**
  String get settingsReorderSnackSubtitle;

  /// No description provided for @settingsReorderHapticsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retour haptique réorganisation'**
  String get settingsReorderHapticsTitle;

  /// No description provided for @settingsReorderHapticsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vibration légère après un déplacement'**
  String get settingsReorderHapticsSubtitle;

  /// No description provided for @emptyRoutinesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune routine'**
  String get emptyRoutinesTitle;

  /// No description provided for @emptyRoutinesBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez une routine personnelle ou générez un exemple pour découvrir l\'interface.'**
  String get emptyRoutinesBody;

  /// No description provided for @generateExample.
  ///
  /// In fr, this message translates to:
  /// **'Générer un exemple'**
  String get generateExample;

  /// No description provided for @suggestions.
  ///
  /// In fr, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @existing.
  ///
  /// In fr, this message translates to:
  /// **'Existants'**
  String get existing;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @rename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @reassign.
  ///
  /// In fr, this message translates to:
  /// **'Réaffecter'**
  String get reassign;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @destination.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @newSubcategory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle sous-catégorie'**
  String get newSubcategory;

  /// No description provided for @noSubcategoryForPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sous-catégorie pour cette période.'**
  String get noSubcategoryForPeriod;

  /// No description provided for @nameFrLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom FR'**
  String get nameFrLabel;

  /// No description provided for @nameArLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom AR'**
  String get nameArLabel;

  /// No description provided for @periodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get periodLabel;

  /// No description provided for @subcatFrLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sous-catégorie FR (ex: Richesse, Pardon)'**
  String get subcatFrLabel;

  /// No description provided for @subcatArLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sous-catégorie AR'**
  String get subcatArLabel;

  /// No description provided for @routineDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Routine supprimée'**
  String get routineDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
