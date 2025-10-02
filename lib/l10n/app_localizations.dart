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

  /// No description provided for @pet_info_title.
  ///
  /// In en, this message translates to:
  /// **'Pet Information'**
  String get pet_info_title;

  /// No description provided for @no_pets_available.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any pets yet.'**
  String get no_pets_available;

  /// No description provided for @update_success.
  ///
  /// In en, this message translates to:
  /// **'Update successful!'**
  String get update_success;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @birth_date.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birth_date;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @pet_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get pet_weight;

  /// No description provided for @fur_color.
  ///
  /// In en, this message translates to:
  /// **'Fur Color'**
  String get fur_color;

  /// No description provided for @add_pet_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get add_pet_tooltip;

  /// No description provided for @pet_name.
  ///
  /// In en, this message translates to:
  /// **'Pet Name'**
  String get pet_name;

  /// No description provided for @pet_types.
  ///
  /// In en, this message translates to:
  /// **'Dog,Cat,Bird,Fish,Other'**
  String get pet_types;

  /// No description provided for @pet_genders.
  ///
  /// In en, this message translates to:
  /// **'Male,Female'**
  String get pet_genders;

  /// No description provided for @select_species.
  ///
  /// In en, this message translates to:
  /// **'Select Species'**
  String get select_species;

  /// No description provided for @select_species_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter vaccine name'**
  String get select_species_error;

  /// No description provided for @empty_field_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty'**
  String get empty_field_error;

  /// No description provided for @invalid_weight.
  ///
  /// In en, this message translates to:
  /// **'Invalid weight'**
  String get invalid_weight;

  /// No description provided for @select_gender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get select_gender;

  /// No description provided for @weight_kg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight_kg;

  /// No description provided for @select_birth_date.
  ///
  /// In en, this message translates to:
  /// **'Select Birth Date'**
  String get select_birth_date;

  /// No description provided for @choose_date.
  ///
  /// In en, this message translates to:
  /// **'Choose Date'**
  String get choose_date;

  /// No description provided for @pet_info.
  ///
  /// In en, this message translates to:
  /// **'Pet Information'**
  String get pet_info;

  /// No description provided for @pet_breed_gender.
  ///
  /// In en, this message translates to:
  /// **'{breed} • {gender}'**
  String pet_breed_gender(Object breed, Object gender);

  /// No description provided for @medical_records_section.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medical_records_section;

  /// No description provided for @all_types.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get all_types;

  /// No description provided for @regular_checkup.
  ///
  /// In en, this message translates to:
  /// **'Regular Checkup'**
  String get regular_checkup;

  /// No description provided for @vaccination_record.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get vaccination_record;

  /// No description provided for @treatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// No description provided for @surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get surgery;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @all_statuses.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_statuses;

  /// No description provided for @completed_status.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed_status;

  /// No description provided for @ongoing_status.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing_status;

  /// No description provided for @scheduled_status.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled_status;

  /// No description provided for @cancelled_status.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled_status;

  /// No description provided for @medical_records_pet.
  ///
  /// In en, this message translates to:
  /// **'Records of {name}'**
  String medical_records_pet(Object name);

  /// No description provided for @count_completed.
  ///
  /// In en, this message translates to:
  /// **'{count} Completed'**
  String count_completed(Object count);

  /// No description provided for @count_ongoing.
  ///
  /// In en, this message translates to:
  /// **'{count} Ongoing'**
  String count_ongoing(Object count);

  /// No description provided for @count_scheduled.
  ///
  /// In en, this message translates to:
  /// **'{count} Scheduled'**
  String count_scheduled(Object count);

  /// No description provided for @search_by_title_desc.
  ///
  /// In en, this message translates to:
  /// **'Browse by title, description...'**
  String get search_by_title_desc;

  /// No description provided for @no_matching_records.
  ///
  /// In en, this message translates to:
  /// **'No matching records'**
  String get no_matching_records;

  /// No description provided for @medical_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Record Details'**
  String get medical_detail_title;

  /// No description provided for @pet_info_label.
  ///
  /// In en, this message translates to:
  /// **'Pet Information'**
  String get pet_info_label;

  /// No description provided for @record_info.
  ///
  /// In en, this message translates to:
  /// **'Record Information'**
  String get record_info;

  /// No description provided for @record_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get record_type;

  /// No description provided for @exam_date.
  ///
  /// In en, this message translates to:
  /// **'Exam Date'**
  String get exam_date;

  /// No description provided for @no_doctor.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get no_doctor;

  /// No description provided for @record_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get record_status;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @next_visit.
  ///
  /// In en, this message translates to:
  /// **'Next Visit'**
  String get next_visit;

  /// No description provided for @diagnosis_treatment.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis & Treatment'**
  String get diagnosis_treatment;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @medical_records_title.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medical_records_title;

  /// No description provided for @no_records_yet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get no_records_yet;

  /// No description provided for @add_medical_record_title.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Record'**
  String get add_medical_record_title;

  /// No description provided for @edit_medical_record_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Medical Record'**
  String get edit_medical_record_title;

  /// No description provided for @record_type_label.
  ///
  /// In en, this message translates to:
  /// **'Record Type *'**
  String get record_type_label;

  /// No description provided for @title_label.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get title_label;

  /// No description provided for @title_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get title_error;

  /// No description provided for @record_type_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty'**
  String get record_type_error;

  /// No description provided for @exam_date_label.
  ///
  /// In en, this message translates to:
  /// **'Exam Date *'**
  String get exam_date_label;

  /// No description provided for @doctor_name_label.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor_name_label;

  /// No description provided for @status_label.
  ///
  /// In en, this message translates to:
  /// **'Status *'**
  String get status_label;

  /// No description provided for @cost_currency.
  ///
  /// In en, this message translates to:
  /// **'Cost (VND)'**
  String get cost_currency;

  /// No description provided for @next_visit_label.
  ///
  /// In en, this message translates to:
  /// **'Next Visit'**
  String get next_visit_label;

  /// No description provided for @description_label.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get description_label;

  /// No description provided for @description_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get description_error;

  /// No description provided for @notes_label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes_label;

  /// No description provided for @update_record.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_record;

  /// No description provided for @add_record.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get add_record;

  /// No description provided for @update_success_text.
  ///
  /// In en, this message translates to:
  /// **'Record updated successfully!'**
  String get update_success_text;

  /// No description provided for @add_success_text.
  ///
  /// In en, this message translates to:
  /// **'Record added successfully!'**
  String get add_success_text;

  /// No description provided for @add_vaccination_title.
  ///
  /// In en, this message translates to:
  /// **'Add Vaccination History'**
  String get add_vaccination_title;

  /// No description provided for @edit_vaccination_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Vaccination History'**
  String get edit_vaccination_title;

  /// No description provided for @vaccine_name_label.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Name *'**
  String get vaccine_name_label;

  /// No description provided for @vaccine_type_label.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Type *'**
  String get vaccine_type_label;

  /// No description provided for @vaccination_date_label.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Date *'**
  String get vaccination_date_label;

  /// No description provided for @next_booster_label.
  ///
  /// In en, this message translates to:
  /// **'Next Booster'**
  String get next_booster_label;

  /// No description provided for @manufacturer_label.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer_label;

  /// No description provided for @batch_number_label.
  ///
  /// In en, this message translates to:
  /// **'Batch Number'**
  String get batch_number_label;

  /// No description provided for @administered_by_label.
  ///
  /// In en, this message translates to:
  /// **'Administered By'**
  String get administered_by_label;

  /// No description provided for @vaccination_schedule_info.
  ///
  /// In en, this message translates to:
  /// **'Recommended Vaccination Schedule'**
  String get vaccination_schedule_info;

  /// No description provided for @core_vaccines.
  ///
  /// In en, this message translates to:
  /// **'Core vaccines'**
  String get core_vaccines;

  /// No description provided for @core_vaccines_schedule.
  ///
  /// In en, this message translates to:
  /// **'6-8 weeks, 10-12 weeks, 14-16 weeks, 1 year'**
  String get core_vaccines_schedule;

  /// No description provided for @rabies_schedule.
  ///
  /// In en, this message translates to:
  /// **'12-16 weeks, annual booster'**
  String get rabies_schedule;

  /// No description provided for @non_core.
  ///
  /// In en, this message translates to:
  /// **'Non-core'**
  String get non_core;

  /// No description provided for @non_core_schedule.
  ///
  /// In en, this message translates to:
  /// **'As recommended by doctor'**
  String get non_core_schedule;

  /// No description provided for @update_vaccination.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_vaccination;

  /// No description provided for @add_vaccination.
  ///
  /// In en, this message translates to:
  /// **'Add Vaccination History'**
  String get add_vaccination;

  /// No description provided for @update_vaccination_success.
  ///
  /// In en, this message translates to:
  /// **'Vaccination history updated successfully!'**
  String get update_vaccination_success;

  /// No description provided for @add_vaccination_success.
  ///
  /// In en, this message translates to:
  /// **'Vaccination history added successfully!'**
  String get add_vaccination_success;

  /// No description provided for @vaccine_core.
  ///
  /// In en, this message translates to:
  /// **'Core vaccine'**
  String get vaccine_core;

  /// No description provided for @vaccine_non_core.
  ///
  /// In en, this message translates to:
  /// **'Non-core vaccine'**
  String get vaccine_non_core;

  /// No description provided for @vaccine_rabies.
  ///
  /// In en, this message translates to:
  /// **'Rabies vaccine'**
  String get vaccine_rabies;

  /// No description provided for @vaccine_other.
  ///
  /// In en, this message translates to:
  /// **'Other vaccine'**
  String get vaccine_other;

  /// No description provided for @add_health_metrics_title.
  ///
  /// In en, this message translates to:
  /// **'Add Health Metrics'**
  String get add_health_metrics_title;

  /// No description provided for @edit_health_metrics_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Health Metrics'**
  String get edit_health_metrics_title;

  /// No description provided for @record_date_label.
  ///
  /// In en, this message translates to:
  /// **'Record Date *'**
  String get record_date_label;

  /// No description provided for @temperature_celsius.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperature_celsius;

  /// No description provided for @heart_rate_bpm.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate (bpm)'**
  String get heart_rate_bpm;

  /// No description provided for @respiratory_rate_bpm.
  ///
  /// In en, this message translates to:
  /// **'Respiratory Rate (bpm)'**
  String get respiratory_rate_bpm;

  /// No description provided for @blood_pressure_systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic Blood Pressure'**
  String get blood_pressure_systolic;

  /// No description provided for @blood_pressure_diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic Blood Pressure'**
  String get blood_pressure_diastolic;

  /// No description provided for @notes_label_vitals.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes_label_vitals;

  /// No description provided for @normal_ranges.
  ///
  /// In en, this message translates to:
  /// **'Normal Ranges'**
  String get normal_ranges;

  /// No description provided for @temperature_range.
  ///
  /// In en, this message translates to:
  /// **'37.5 - 39.2°C'**
  String get temperature_range;

  /// No description provided for @heart_rate_range.
  ///
  /// In en, this message translates to:
  /// **'60 - 140 bpm'**
  String get heart_rate_range;

  /// No description provided for @respiratory_rate_range.
  ///
  /// In en, this message translates to:
  /// **'10 - 30 bpm'**
  String get respiratory_rate_range;

  /// No description provided for @blood_pressure_range.
  ///
  /// In en, this message translates to:
  /// **'110/60 - 160/100 mmHg'**
  String get blood_pressure_range;

  /// No description provided for @update_metrics.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_metrics;

  /// No description provided for @add_metrics.
  ///
  /// In en, this message translates to:
  /// **'Add Metrics'**
  String get add_metrics;

  /// No description provided for @update_metrics_success.
  ///
  /// In en, this message translates to:
  /// **'Metrics updated successfully!'**
  String get update_metrics_success;

  /// No description provided for @add_metrics_success.
  ///
  /// In en, this message translates to:
  /// **'Metrics added successfully!'**
  String get add_metrics_success;

  /// No description provided for @save_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_text;

  /// No description provided for @about_section.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about_section;

  /// No description provided for @experience_section.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience_section;

  /// No description provided for @education_section.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education_section;

  /// No description provided for @certifications_section.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications_section;

  /// No description provided for @book_medical_appointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get book_medical_appointment;

  /// No description provided for @chat_no_doctor_account.
  ///
  /// In en, this message translates to:
  /// **'Doctor account not found for messaging'**
  String get chat_no_doctor_account;

  /// No description provided for @chat_init_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to initialize conversation'**
  String get chat_init_failed;

  /// No description provided for @doctor_profile.
  ///
  /// In en, this message translates to:
  /// **'Doctor Profile'**
  String get doctor_profile;

  /// No description provided for @today_overview.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Overview'**
  String get today_overview;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @manage_work_schedule.
  ///
  /// In en, this message translates to:
  /// **'Manage Work Schedule'**
  String get manage_work_schedule;

  /// No description provided for @view_update_schedule.
  ///
  /// In en, this message translates to:
  /// **'View & update schedule'**
  String get view_update_schedule;

  /// No description provided for @view_medical_records_doctor.
  ///
  /// In en, this message translates to:
  /// **'View medical records'**
  String get view_medical_records_doctor;

  /// No description provided for @appointment_stats.
  ///
  /// In en, this message translates to:
  /// **'Appointment Statistics'**
  String get appointment_stats;

  /// No description provided for @track_performance.
  ///
  /// In en, this message translates to:
  /// **'Track performance'**
  String get track_performance;

  /// No description provided for @upcoming_appointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming appointments'**
  String get upcoming_appointments;

  /// No description provided for @no_upcoming_appointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get no_upcoming_appointments;

  /// No description provided for @view_schedule.
  ///
  /// In en, this message translates to:
  /// **'View schedule'**
  String get view_schedule;

  /// No description provided for @unspecified_service.
  ///
  /// In en, this message translates to:
  /// **'Unspecified service'**
  String get unspecified_service;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @work_schedule.
  ///
  /// In en, this message translates to:
  /// **'Work Schedule'**
  String get work_schedule;

  /// No description provided for @appointments_on_date.
  ///
  /// In en, this message translates to:
  /// **'Appointments on {date}'**
  String appointments_on_date(Object date);

  /// No description provided for @appointments_count.
  ///
  /// In en, this message translates to:
  /// **'{count} appointments'**
  String appointments_count(Object count);

  /// No description provided for @no_appointments_any.
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get no_appointments_any;

  /// No description provided for @no_appointments_on_date.
  ///
  /// In en, this message translates to:
  /// **'No appointments on {date}'**
  String no_appointments_on_date(Object date);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period:'**
  String get period;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @total_appointments.
  ///
  /// In en, this message translates to:
  /// **'Total appointments'**
  String get total_appointments;

  /// No description provided for @next_up.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get next_up;
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
