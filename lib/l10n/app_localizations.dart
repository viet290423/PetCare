import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @section_theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get section_theme;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get theme_system;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @section_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get section_language;

  /// No description provided for @language_system.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get language_system;

  /// No description provided for @language_vi.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get language_vi;

  /// No description provided for @language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_en;

  /// No description provided for @section_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get section_other;

  /// No description provided for @notifications_toggle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications'**
  String get notifications_toggle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_description.
  ///
  /// In en, this message translates to:
  /// **'PetCare helps you manage your pets\' health and services'**
  String get about_description;

  /// No description provided for @clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clear_cache;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get coming_soon;

  /// No description provided for @section_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get section_account;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @professional_pet_care.
  ///
  /// In en, this message translates to:
  /// **'Professional Pet Care'**
  String get professional_pet_care;

  /// No description provided for @comprehensive_pet_care_services.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive care services for your pets'**
  String get comprehensive_pet_care_services;

  /// No description provided for @care_services.
  ///
  /// In en, this message translates to:
  /// **'Care Services'**
  String get care_services;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get view_all;

  /// No description provided for @doctor_team.
  ///
  /// In en, this message translates to:
  /// **'Doctor Team'**
  String get doctor_team;

  /// No description provided for @common_diseases.
  ///
  /// In en, this message translates to:
  /// **'Common Diseases'**
  String get common_diseases;

  /// No description provided for @search_diseases.
  ///
  /// In en, this message translates to:
  /// **'Search diseases...'**
  String get search_diseases;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contact_address.
  ///
  /// In en, this message translates to:
  /// **'123 Phan Dinh Giot Street, Ha Dong, Hanoi'**
  String get contact_address;

  /// No description provided for @contact_phone.
  ///
  /// In en, this message translates to:
  /// **'0123 456 789'**
  String get contact_phone;

  /// No description provided for @contact_email.
  ///
  /// In en, this message translates to:
  /// **'contact@petcare.com'**
  String get contact_email;

  /// No description provided for @high_danger.
  ///
  /// In en, this message translates to:
  /// **'High danger'**
  String get high_danger;

  /// No description provided for @medium_danger.
  ///
  /// In en, this message translates to:
  /// **'Medium danger'**
  String get medium_danger;

  /// No description provided for @low_danger.
  ///
  /// In en, this message translates to:
  /// **'Low danger'**
  String get low_danger;

  /// No description provided for @dog_and_cat.
  ///
  /// In en, this message translates to:
  /// **'Dog & Cat'**
  String get dog_and_cat;

  /// No description provided for @dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get dog;

  /// No description provided for @cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get cat;

  /// No description provided for @main_symptoms.
  ///
  /// In en, this message translates to:
  /// **'main symptoms'**
  String get main_symptoms;

  /// No description provided for @book_appointment_feature_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Appointment booking feature will be updated soon!'**
  String get book_appointment_feature_coming_soon;

  /// No description provided for @book_appointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get book_appointment;

  /// No description provided for @service_medical_exam.
  ///
  /// In en, this message translates to:
  /// **'Medical Examination'**
  String get service_medical_exam;

  /// No description provided for @service_medical_exam_desc.
  ///
  /// In en, this message translates to:
  /// **'Examination and treatment of diseases for pets'**
  String get service_medical_exam_desc;

  /// No description provided for @service_spa_care.
  ///
  /// In en, this message translates to:
  /// **'Spa Care'**
  String get service_spa_care;

  /// No description provided for @service_spa_care_desc.
  ///
  /// In en, this message translates to:
  /// **'Bathing, fur trimming, nail care'**
  String get service_spa_care_desc;

  /// No description provided for @service_vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get service_vaccination;

  /// No description provided for @service_vaccination_desc.
  ///
  /// In en, this message translates to:
  /// **'Vaccination and health consultation'**
  String get service_vaccination_desc;

  /// No description provided for @service_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get service_nutrition;

  /// No description provided for @service_nutrition_desc.
  ///
  /// In en, this message translates to:
  /// **'Consultation on appropriate diet'**
  String get service_nutrition_desc;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Login Error'**
  String get login_error;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @login_with_google.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get login_with_google;

  /// No description provided for @login_google_failed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed'**
  String get login_google_failed;

  /// No description provided for @login_with_facebook.
  ///
  /// In en, this message translates to:
  /// **'Login with Facebook'**
  String get login_with_facebook;

  /// No description provided for @login_facebook_failed.
  ///
  /// In en, this message translates to:
  /// **'Facebook login failed'**
  String get login_facebook_failed;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get no_account;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// No description provided for @signup_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signup_title;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @select_role.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get select_role;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @has_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get has_account;

  /// No description provided for @today_how_is.
  ///
  /// In en, this message translates to:
  /// **'How is {petName} today?'**
  String today_how_is(Object petName);

  /// No description provided for @select_pet_to_see_reminders.
  ///
  /// In en, this message translates to:
  /// **'Please select a pet to see reminders'**
  String get select_pet_to_see_reminders;

  /// No description provided for @no_pets_yet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any pets yet'**
  String get no_pets_yet;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @no_reminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders.'**
  String get no_reminders;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirm_delete;

  /// No description provided for @confirm_delete_reminder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get confirm_delete_reminder;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_reminder_success.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted successfully!'**
  String get delete_reminder_success;

  /// No description provided for @delete_reminder_error.
  ///
  /// In en, this message translates to:
  /// **'Error deleting reminder: {error}'**
  String delete_reminder_error(Object error);

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @no_appointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments.'**
  String get no_appointments;

  /// No description provided for @appointment_time.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String appointment_time(Object time);

  /// No description provided for @doctor_name.
  ///
  /// In en, this message translates to:
  /// **'Doctor: {name}'**
  String doctor_name(Object name);

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String status(Object status);

  /// No description provided for @select_pet_to_see_tips.
  ///
  /// In en, this message translates to:
  /// **'Please select a pet to see tips'**
  String get select_pet_to_see_tips;

  /// No description provided for @add_health_metrics.
  ///
  /// In en, this message translates to:
  /// **'Add health metrics'**
  String get add_health_metrics;

  /// No description provided for @health_records.
  ///
  /// In en, this message translates to:
  /// **'Health Records & Metrics'**
  String get health_records;

  /// No description provided for @health_summary.
  ///
  /// In en, this message translates to:
  /// **'Health Summary'**
  String get health_summary;

  /// No description provided for @medical_records_auto_update.
  ///
  /// In en, this message translates to:
  /// **'Medical records and vaccinations are automatically updated by doctors'**
  String get medical_records_auto_update;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @no_data.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get no_data;

  /// No description provided for @recently_updated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get recently_updated;

  /// No description provided for @needs_update.
  ///
  /// In en, this message translates to:
  /// **'Needs update'**
  String get needs_update;

  /// No description provided for @health_status.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get health_status;

  /// No description provided for @needs_attention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needs_attention;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @overdue_shots.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue shots'**
  String overdue_shots(Object count);

  /// No description provided for @upcoming_shots.
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming shots'**
  String upcoming_shots(Object count);

  /// No description provided for @medical_records.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medical_records;

  /// No description provided for @records_count.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String records_count(Object count);

  /// No description provided for @medical_history.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medical_history;

  /// No description provided for @no_medical_records.
  ///
  /// In en, this message translates to:
  /// **'No medical records'**
  String get no_medical_records;

  /// No description provided for @medical_records_will_show_here.
  ///
  /// In en, this message translates to:
  /// **'Medical records will show here'**
  String get medical_records_will_show_here;

  /// No description provided for @all_reminders.
  ///
  /// In en, this message translates to:
  /// **'All Reminders'**
  String get all_reminders;

  /// No description provided for @all_appointments.
  ///
  /// In en, this message translates to:
  /// **'All Appointments'**
  String get all_appointments;

  /// No description provided for @growth_chart.
  ///
  /// In en, this message translates to:
  /// **'Growth Chart'**
  String get growth_chart;

  /// No description provided for @no_weight_data.
  ///
  /// In en, this message translates to:
  /// **'No weight data'**
  String get no_weight_data;

  /// No description provided for @unit_kg.
  ///
  /// In en, this message translates to:
  /// **'Unit: kg'**
  String get unit_kg;

  /// No description provided for @ai_recommendation.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendation'**
  String get ai_recommendation;

  /// No description provided for @no_doctor_info.
  ///
  /// In en, this message translates to:
  /// **'No information'**
  String get no_doctor_info;

  /// No description provided for @dental_care_tip.
  ///
  /// In en, this message translates to:
  /// **'Dental care for pets'**
  String get dental_care_tip;

  /// No description provided for @dental_care_desc.
  ///
  /// In en, this message translates to:
  /// **'Regular brushing helps prevent dental diseases and fresh breath.'**
  String get dental_care_desc;

  /// No description provided for @bathing_tip.
  ///
  /// In en, this message translates to:
  /// **'Proper bathing'**
  String get bathing_tip;

  /// No description provided for @bathing_desc.
  ///
  /// In en, this message translates to:
  /// **'Bathe 2-3 times/month with specialized shampoo, avoid water in ears and eyes.'**
  String get bathing_desc;

  /// No description provided for @nutrition_tip.
  ///
  /// In en, this message translates to:
  /// **'Balanced diet'**
  String get nutrition_tip;

  /// No description provided for @nutrition_desc.
  ///
  /// In en, this message translates to:
  /// **'Provide adequate protein, vitamins and minerals according to age and weight.'**
  String get nutrition_desc;

  /// No description provided for @exercise_tip.
  ///
  /// In en, this message translates to:
  /// **'Daily exercise'**
  String get exercise_tip;

  /// No description provided for @exercise_desc.
  ///
  /// In en, this message translates to:
  /// **'Spend 30-60 minutes daily playing and exercising with your pet.'**
  String get exercise_desc;

  /// No description provided for @general_tips.
  ///
  /// In en, this message translates to:
  /// **'General Tips'**
  String get general_tips;

  /// No description provided for @personal_profile.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get personal_profile;

  /// No description provided for @user_not_found.
  ///
  /// In en, this message translates to:
  /// **'User information not found'**
  String get user_not_found;

  /// No description provided for @veterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get veterinarian;

  /// No description provided for @pet_lover.
  ///
  /// In en, this message translates to:
  /// **'Pet Lover'**
  String get pet_lover;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @pet_management.
  ///
  /// In en, this message translates to:
  /// **'Pet Management'**
  String get pet_management;

  /// No description provided for @view_edit_pet_profiles.
  ///
  /// In en, this message translates to:
  /// **'View & edit pet profiles'**
  String get view_edit_pet_profiles;

  /// No description provided for @service_history.
  ///
  /// In en, this message translates to:
  /// **'Service History'**
  String get service_history;

  /// No description provided for @view_service_booking_history.
  ///
  /// In en, this message translates to:
  /// **'View service booking history'**
  String get view_service_booking_history;

  /// No description provided for @store_exam_test_results.
  ///
  /// In en, this message translates to:
  /// **'Store exam and test results'**
  String get store_exam_test_results;

  /// No description provided for @health_statistics.
  ///
  /// In en, this message translates to:
  /// **'Health Statistics'**
  String get health_statistics;

  /// No description provided for @track_pet_health.
  ///
  /// In en, this message translates to:
  /// **'Track pet health'**
  String get track_pet_health;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @menu_nutrition_suggestions.
  ///
  /// In en, this message translates to:
  /// **'Menu and nutrition suggestions'**
  String get menu_nutrition_suggestions;

  /// No description provided for @exit_account.
  ///
  /// In en, this message translates to:
  /// **'Exit account'**
  String get exit_account;

  /// No description provided for @pet_community.
  ///
  /// In en, this message translates to:
  /// **'Pet Community'**
  String get pet_community;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @add_story.
  ///
  /// In en, this message translates to:
  /// **'Add Story'**
  String get add_story;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @no_posts_yet.
  ///
  /// In en, this message translates to:
  /// **'No posts in the community yet.\nBe the first to share adorable pet moments!'**
  String get no_posts_yet;

  /// No description provided for @create_first_post.
  ///
  /// In en, this message translates to:
  /// **'Create First Post'**
  String get create_first_post;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @cannot_load_service_history.
  ///
  /// In en, this message translates to:
  /// **'Cannot load service history: {error}'**
  String cannot_load_service_history(Object error);

  /// No description provided for @no_service_history.
  ///
  /// In en, this message translates to:
  /// **'No service history'**
  String get no_service_history;

  /// No description provided for @search_by_service_doctor.
  ///
  /// In en, this message translates to:
  /// **'Search by service, doctor...'**
  String get search_by_service_doctor;

  /// No description provided for @pet_service.
  ///
  /// In en, this message translates to:
  /// **'Pet Service'**
  String get pet_service;

  /// No description provided for @select_doctor.
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get select_doctor;

  /// No description provided for @no_doctors_available.
  ///
  /// In en, this message translates to:
  /// **'No doctors available for this service'**
  String get no_doctors_available;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service: {title}'**
  String service(Object title);

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String date(Object date);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String time(Object time);

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience: {years}'**
  String experience(Object years);

  /// No description provided for @no_schedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule'**
  String get no_schedule;

  /// No description provided for @continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get contiNue;

  /// No description provided for @please_select_date_time_first.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time before selecting doctor'**
  String get please_select_date_time_first;

  /// No description provided for @please_select_all_info.
  ///
  /// In en, this message translates to:
  /// **'Please select all information'**
  String get please_select_all_info;

  /// No description provided for @booking_success.
  ///
  /// In en, this message translates to:
  /// **'Booking successful!'**
  String get booking_success;

  /// No description provided for @book_service.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get book_service;

  /// No description provided for @contact_for_price.
  ///
  /// In en, this message translates to:
  /// **'Contact for price'**
  String get contact_for_price;

  /// No description provided for @service_description.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get service_description;

  /// No description provided for @select_pet.
  ///
  /// In en, this message translates to:
  /// **'Select Pet'**
  String get select_pet;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get select_date;

  /// No description provided for @select_time.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get select_time;

  /// No description provided for @book_now.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get book_now;

  /// No description provided for @add_new_pet.
  ///
  /// In en, this message translates to:
  /// **'Add New Pet'**
  String get add_new_pet;

  /// No description provided for @change_date.
  ///
  /// In en, this message translates to:
  /// **'Change Date'**
  String get change_date;

  /// No description provided for @please_select_date_first.
  ///
  /// In en, this message translates to:
  /// **'Please select date first'**
  String get please_select_date_first;

  /// No description provided for @please_select_date_time.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time first'**
  String get please_select_date_time;

  /// No description provided for @change_doctor.
  ///
  /// In en, this message translates to:
  /// **'Change Doctor'**
  String get change_doctor;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @service_details.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get service_details;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
