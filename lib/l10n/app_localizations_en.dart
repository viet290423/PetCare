// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings_title => 'Settings';

  @override
  String get section_theme => 'Appearance';

  @override
  String get theme_system => 'Follow system';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get section_language => 'Language';

  @override
  String get language_system => 'Follow system';

  @override
  String get language_vi => 'Vietnamese';

  @override
  String get language_en => 'English';

  @override
  String get section_other => 'Other';

  @override
  String get notifications_toggle => 'Receive notifications';

  @override
  String get about => 'About';

  @override
  String get about_description => 'PetCare helps you manage your pets\' health and services';

  @override
  String get clear_cache => 'Clear cache';

  @override
  String get coming_soon => 'Coming soon';

  @override
  String get section_account => 'Account';

  @override
  String get logout => 'Logout';

  @override
  String get error => 'Error';

  @override
  String get professional_pet_care => 'Professional Pet Care';

  @override
  String get comprehensive_pet_care_services => 'Comprehensive care services for your pets';

  @override
  String get care_services => 'Care Services';

  @override
  String get view_all => 'View all';

  @override
  String get doctor_team => 'Doctor Team';

  @override
  String get common_diseases => 'Common Diseases';

  @override
  String get search_diseases => 'Search diseases...';

  @override
  String get contact => 'Contact';

  @override
  String get contact_address => '123 Phan Dinh Giot Street, Ha Dong, Hanoi';

  @override
  String get contact_phone => '0123 456 789';

  @override
  String get contact_email => 'contact@petcare.com';

  @override
  String get high_danger => 'High danger';

  @override
  String get medium_danger => 'Medium danger';

  @override
  String get low_danger => 'Low danger';

  @override
  String get dog_and_cat => 'Dog & Cat';

  @override
  String get dog => 'Dog';

  @override
  String get cat => 'Cat';

  @override
  String get main_symptoms => 'main symptoms';

  @override
  String get book_appointment_feature_coming_soon => 'Appointment booking feature will be updated soon!';

  @override
  String get book_appointment => 'Book appointment';

  @override
  String get service_medical_exam => 'Medical Examination';

  @override
  String get service_medical_exam_desc => 'Examination and treatment of diseases for pets';

  @override
  String get service_spa_care => 'Spa Care';

  @override
  String get service_spa_care_desc => 'Bathing, fur trimming, nail care';

  @override
  String get service_vaccination => 'Vaccination';

  @override
  String get service_vaccination_desc => 'Vaccination and health consultation';

  @override
  String get service_nutrition => 'Nutrition';

  @override
  String get service_nutrition_desc => 'Consultation on appropriate diet';

  @override
  String get login => 'Login';

  @override
  String get password => 'Password';

  @override
  String get login_error => 'Login Error';

  @override
  String get close => 'Close';

  @override
  String get forgot_password => 'Forgot password?';

  @override
  String get or => 'Or';

  @override
  String get login_with_google => 'Login with Google';

  @override
  String get login_google_failed => 'Google login failed';

  @override
  String get login_with_facebook => 'Login with Facebook';

  @override
  String get login_facebook_failed => 'Facebook login failed';

  @override
  String get no_account => 'Don\'t have an account? ';

  @override
  String get signup => 'Sign up';

  @override
  String get signup_title => 'Create Account';

  @override
  String get name => 'Name';

  @override
  String get user => 'User';

  @override
  String get doctor => 'Doctor';

  @override
  String get select_role => 'Select Role';

  @override
  String get cancel => 'Cancel';

  @override
  String get has_account => 'Already have an account? ';

  @override
  String today_how_is(Object petName) {
    return 'How is $petName today?';
  }

  @override
  String get select_pet_to_see_reminders => 'Please select a pet to see reminders';

  @override
  String get no_pets_yet => 'You don\'t have any pets yet';

  @override
  String get reminders => 'Reminders';

  @override
  String get no_reminders => 'No reminders.';

  @override
  String get confirm_delete => 'Confirm Delete';

  @override
  String get confirm_delete_reminder => 'Are you sure you want to delete this reminder?';

  @override
  String get delete => 'Delete';

  @override
  String get delete_reminder_success => 'Reminder deleted successfully!';

  @override
  String delete_reminder_error(Object error) {
    return 'Error deleting reminder: $error';
  }

  @override
  String get appointments => 'Appointments';

  @override
  String get no_appointments => 'No appointments.';

  @override
  String appointment_time(Object time) {
    return 'Time: $time';
  }

  @override
  String doctor_name(Object name) {
    return 'Doctor: $name';
  }

  @override
  String status(Object status) {
    return 'Status: $status';
  }

  @override
  String get select_pet_to_see_tips => 'Please select a pet to see tips';

  @override
  String get add_health_metrics => 'Add health metrics';

  @override
  String get health_records => 'Health Records & Metrics';

  @override
  String get health_summary => 'Health Summary';

  @override
  String get medical_records_auto_update => 'Medical records and vaccinations are automatically updated by doctors';

  @override
  String get weight => 'Weight';

  @override
  String get no_data => 'No data';

  @override
  String get recently_updated => 'Recently updated';

  @override
  String get needs_update => 'Needs update';

  @override
  String get health_status => 'Health Status';

  @override
  String get needs_attention => 'Needs attention';

  @override
  String get normal => 'Normal';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get complete => 'Complete';

  @override
  String overdue_shots(Object count) {
    return '$count overdue shots';
  }

  @override
  String upcoming_shots(Object count) {
    return '$count upcoming shots';
  }

  @override
  String get medical_records => 'Medical Records';

  @override
  String records_count(Object count) {
    return '$count records';
  }

  @override
  String get medical_history => 'Medical History';

  @override
  String get no_medical_records => 'No medical records';

  @override
  String get medical_records_will_show_here => 'Medical records will show here';

  @override
  String get all_reminders => 'All Reminders';

  @override
  String get all_appointments => 'All Appointments';

  @override
  String get growth_chart => 'Growth Chart';

  @override
  String get no_weight_data => 'No weight data';

  @override
  String get unit_kg => 'Unit: kg';

  @override
  String get ai_recommendation => 'AI Recommendation';

  @override
  String get no_doctor_info => 'No information';

  @override
  String get dental_care_tip => 'Dental care for pets';

  @override
  String get dental_care_desc => 'Regular brushing helps prevent dental diseases and fresh breath.';

  @override
  String get bathing_tip => 'Proper bathing';

  @override
  String get bathing_desc => 'Bathe 2-3 times/month with specialized shampoo, avoid water in ears and eyes.';

  @override
  String get nutrition_tip => 'Balanced diet';

  @override
  String get nutrition_desc => 'Provide adequate protein, vitamins and minerals according to age and weight.';

  @override
  String get exercise_tip => 'Daily exercise';

  @override
  String get exercise_desc => 'Spend 30-60 minutes daily playing and exercising with your pet.';

  @override
  String get general_tips => 'General Tips';

  @override
  String get personal_profile => 'Personal Profile';

  @override
  String get user_not_found => 'User information not found';

  @override
  String get veterinarian => 'Veterinarian';

  @override
  String get pet_lover => 'Pet Lover';

  @override
  String get edit_profile => 'Edit Profile';

  @override
  String get pets => 'Pets';

  @override
  String get services => 'Services';

  @override
  String get health => 'Health';

  @override
  String get good => 'Good';

  @override
  String get pet_management => 'Pet Management';

  @override
  String get view_edit_pet_profiles => 'View & edit pet profiles';

  @override
  String get service_history => 'Service History';

  @override
  String get view_service_booking_history => 'View service booking history';

  @override
  String get store_exam_test_results => 'Store exam and test results';

  @override
  String get health_statistics => 'Health Statistics';

  @override
  String get track_pet_health => 'Track pet health';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get menu_nutrition_suggestions => 'Menu and nutrition suggestions';

  @override
  String get exit_account => 'Exit account';

  @override
  String get pet_community => 'Pet Community';

  @override
  String get try_again => 'Try Again';

  @override
  String get add_story => 'Add Story';

  @override
  String get you => 'You';

  @override
  String get no_posts_yet => 'No posts in the community yet.\nBe the first to share adorable pet moments!';

  @override
  String get create_first_post => 'Create First Post';

  @override
  String get all => 'All';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String cannot_load_service_history(Object error) {
    return 'Cannot load service history: $error';
  }

  @override
  String get no_service_history => 'No service history';

  @override
  String get search_by_service_doctor => 'Search by service, doctor...';

  @override
  String get pet_service => 'Pet Service';

  @override
  String get select_doctor => 'Select Doctor';

  @override
  String get no_doctors_available => 'No doctors available for this service';

  @override
  String service(Object title) {
    return 'Service: $title';
  }

  @override
  String date(Object date) {
    return 'Date: $date';
  }

  @override
  String time(Object time) {
    return 'Time: $time';
  }

  @override
  String get reviews => 'reviews';

  @override
  String experience(Object years) {
    return 'Experience: $years';
  }

  @override
  String get no_schedule => 'No schedule';

  @override
  String get contiNue => 'Continue';

  @override
  String get please_select_date_time_first => 'Please select date and time before selecting doctor';

  @override
  String get please_select_all_info => 'Please select all information';

  @override
  String get booking_success => 'Booking successful!';

  @override
  String get book_service => 'Book Service';

  @override
  String get contact_for_price => 'Contact for price';

  @override
  String get service_description => 'Service Description';

  @override
  String get select_pet => 'Select Pet';

  @override
  String get select_date => 'Select Date';

  @override
  String get select_time => 'Select Time';

  @override
  String get book_now => 'Book Now';

  @override
  String get add_new_pet => 'Add New Pet';

  @override
  String get change_date => 'Change Date';

  @override
  String get please_select_date_first => 'Please select date first';

  @override
  String get please_select_date_time => 'Please select date and time first';

  @override
  String get change_doctor => 'Change Doctor';

  @override
  String get category => 'Category';

  @override
  String get service_details => 'Service Details';

  @override
  String get pet_info_title => 'Pet Information';

  @override
  String get no_pets_available => 'You don\'t have any pets yet.';

  @override
  String get update_success => 'Update successful!';

  @override
  String get species => 'Species';

  @override
  String get breed => 'Breed';

  @override
  String get birth_date => 'Birth Date';

  @override
  String get gender => 'Gender';

  @override
  String get pet_weight => 'Weight';

  @override
  String get fur_color => 'Fur Color';

  @override
  String get add_pet_tooltip => 'Add Pet';

  @override
  String get pet_name => 'Pet Name';

  @override
  String get pet_types => 'Dog,Cat,Bird,Fish,Other';

  @override
  String get pet_genders => 'Male,Female';

  @override
  String get select_species => 'Select Species';

  @override
  String get select_species_error => 'Please enter vaccine name';

  @override
  String get empty_field_error => 'Cannot be empty';

  @override
  String get invalid_weight => 'Invalid weight';

  @override
  String get select_gender => 'Select Gender';

  @override
  String get weight_kg => 'Weight (kg)';

  @override
  String get select_birth_date => 'Select Birth Date';

  @override
  String get choose_date => 'Choose Date';

  @override
  String get pet_info => 'Pet Information';

  @override
  String pet_breed_gender(Object breed, Object gender) {
    return '$breed • $gender';
  }

  @override
  String get medical_records_section => 'Medical Records';

  @override
  String get all_types => 'All Types';

  @override
  String get regular_checkup => 'Regular Checkup';

  @override
  String get vaccination_record => 'Title *';

  @override
  String get treatment => 'Treatment';

  @override
  String get surgery => 'Surgery';

  @override
  String get test => 'Test';

  @override
  String get all_statuses => 'All';

  @override
  String get completed_status => 'Completed';

  @override
  String get ongoing_status => 'Ongoing';

  @override
  String get scheduled_status => 'Scheduled';

  @override
  String get cancelled_status => 'Cancelled';

  @override
  String medical_records_pet(Object name) {
    return 'Records of $name';
  }

  @override
  String count_completed(Object count) {
    return '$count Completed';
  }

  @override
  String count_ongoing(Object count) {
    return '$count Ongoing';
  }

  @override
  String count_scheduled(Object count) {
    return '$count Scheduled';
  }

  @override
  String get search_by_title_desc => 'Browse by title, description...';

  @override
  String get no_matching_records => 'No matching records';

  @override
  String get medical_detail_title => 'Record Details';

  @override
  String get pet_info_label => 'Pet Information';

  @override
  String get record_info => 'Record Information';

  @override
  String get record_type => 'Type';

  @override
  String get exam_date => 'Exam Date';

  @override
  String get no_doctor => 'None';

  @override
  String get record_status => 'Status';

  @override
  String get cost => 'Cost';

  @override
  String get next_visit => 'Next Visit';

  @override
  String get diagnosis_treatment => 'Diagnosis & Treatment';

  @override
  String get notes => 'Notes';

  @override
  String get medications => 'Medications';

  @override
  String get attachments => 'Attachments';

  @override
  String get medical_records_title => 'Medical Records';

  @override
  String get no_records_yet => 'No records yet';

  @override
  String get add_medical_record_title => 'Add Medical Record';

  @override
  String get edit_medical_record_title => 'Edit Medical Record';

  @override
  String get record_type_label => 'Record Type *';

  @override
  String get title_label => 'Title *';

  @override
  String get title_error => 'Please enter title';

  @override
  String get record_type_error => 'Cannot be empty';

  @override
  String get exam_date_label => 'Exam Date *';

  @override
  String get doctor_name_label => 'Doctor';

  @override
  String get status_label => 'Status *';

  @override
  String get cost_currency => 'Cost (VND)';

  @override
  String get next_visit_label => 'Next Visit';

  @override
  String get description_label => 'Description *';

  @override
  String get description_error => 'Please enter description';

  @override
  String get notes_label => 'Notes';

  @override
  String get update_record => 'Update';

  @override
  String get add_record => 'Add Record';

  @override
  String get update_success_text => 'Record updated successfully!';

  @override
  String get add_success_text => 'Record added successfully!';

  @override
  String get add_vaccination_title => 'Add Vaccination History';

  @override
  String get edit_vaccination_title => 'Edit Vaccination History';

  @override
  String get vaccine_name_label => 'Vaccine Name *';

  @override
  String get vaccine_type_label => 'Vaccine Type *';

  @override
  String get vaccination_date_label => 'Vaccination Date *';

  @override
  String get next_booster_label => 'Next Booster';

  @override
  String get manufacturer_label => 'Manufacturer';

  @override
  String get batch_number_label => 'Batch Number';

  @override
  String get administered_by_label => 'Administered By';

  @override
  String get vaccination_schedule_info => 'Recommended Vaccination Schedule';

  @override
  String get core_vaccines => 'Core vaccines';

  @override
  String get core_vaccines_schedule => '6-8 weeks, 10-12 weeks, 14-16 weeks, 1 year';

  @override
  String get rabies_schedule => '12-16 weeks, annual booster';

  @override
  String get non_core => 'Non-core';

  @override
  String get non_core_schedule => 'As recommended by doctor';

  @override
  String get update_vaccination => 'Update';

  @override
  String get add_vaccination => 'Add Vaccination History';

  @override
  String get update_vaccination_success => 'Vaccination history updated successfully!';

  @override
  String get add_vaccination_success => 'Vaccination history added successfully!';

  @override
  String get vaccine_core => 'Core vaccine';

  @override
  String get vaccine_non_core => 'Non-core vaccine';

  @override
  String get vaccine_rabies => 'Rabies vaccine';

  @override
  String get vaccine_other => 'Other vaccine';

  @override
  String get add_health_metrics_title => 'Add Health Metrics';

  @override
  String get edit_health_metrics_title => 'Edit Health Metrics';

  @override
  String get record_date_label => 'Record Date *';

  @override
  String get temperature_celsius => 'Temperature (°C)';

  @override
  String get heart_rate_bpm => 'Heart Rate (bpm)';

  @override
  String get respiratory_rate_bpm => 'Respiratory Rate (bpm)';

  @override
  String get blood_pressure_systolic => 'Systolic Blood Pressure';

  @override
  String get blood_pressure_diastolic => 'Diastolic Blood Pressure';

  @override
  String get notes_label_vitals => 'Notes';

  @override
  String get normal_ranges => 'Normal Ranges';

  @override
  String get temperature_range => '37.5 - 39.2°C';

  @override
  String get heart_rate_range => '60 - 140 bpm';

  @override
  String get respiratory_rate_range => '10 - 30 bpm';

  @override
  String get blood_pressure_range => '110/60 - 160/100 mmHg';

  @override
  String get update_metrics => 'Update';

  @override
  String get add_metrics => 'Add Metrics';

  @override
  String get update_metrics_success => 'Metrics updated successfully!';

  @override
  String get add_metrics_success => 'Metrics added successfully!';

  @override
  String get save_text => 'Save';

  @override
  String get about_section => 'About';

  @override
  String get experience_section => 'Experience';

  @override
  String get education_section => 'Education';

  @override
  String get certifications_section => 'Certifications';

  @override
  String get book_medical_appointment => 'Book appointment';

  @override
  String get chat_no_doctor_account => 'Doctor account not found for messaging';

  @override
  String get chat_init_failed => 'Unable to initialize conversation';

  @override
  String get doctor_profile => 'Doctor Profile';

  @override
  String get today_overview => 'Today\'s Overview';

  @override
  String get today => 'Today';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get actions => 'Actions';

  @override
  String get manage_work_schedule => 'Manage Work Schedule';

  @override
  String get view_update_schedule => 'View & update schedule';

  @override
  String get view_medical_records_doctor => 'View medical records';

  @override
  String get appointment_stats => 'Appointment Statistics';

  @override
  String get track_performance => 'Track performance';

  @override
  String get upcoming_appointments => 'Upcoming appointments';

  @override
  String get no_upcoming_appointments => 'No upcoming appointments';

  @override
  String get view_schedule => 'View schedule';

  @override
  String get unspecified_service => 'Unspecified service';

  @override
  String get details => 'Details';

  @override
  String get start => 'Start';

  @override
  String get work_schedule => 'Work Schedule';

  @override
  String appointments_on_date(Object date) {
    return 'Appointments on $date';
  }

  @override
  String appointments_count(Object count) {
    return '$count appointments';
  }

  @override
  String get no_appointments_any => 'No appointments';

  @override
  String no_appointments_on_date(Object date) {
    return 'No appointments on $date';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get period => 'Period:';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get total_appointments => 'Total appointments';

  @override
  String get next_up => 'Upcoming';
}
