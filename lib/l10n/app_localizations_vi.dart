// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get settings_title => 'Cài đặt';

  @override
  String get section_theme => 'Giao diện';

  @override
  String get theme_system => 'Theo hệ thống';

  @override
  String get theme_light => 'Sáng';

  @override
  String get theme_dark => 'Tối';

  @override
  String get section_language => 'Ngôn ngữ';

  @override
  String get language_system => 'Theo hệ thống';

  @override
  String get language_vi => 'Tiếng Việt';

  @override
  String get language_en => 'Tiếng Anh';

  @override
  String get section_other => 'Khác';

  @override
  String get notifications_toggle => 'Nhận thông báo';

  @override
  String get about => 'Giới thiệu';

  @override
  String get about_description => 'PetCare giúp bạn quản lý sức khỏe và dịch vụ cho thú cưng';

  @override
  String get clear_cache => 'Xóa bộ nhớ đệm';

  @override
  String get coming_soon => 'Tính năng sẽ sớm có';

  @override
  String get section_account => 'Tài khoản';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get error => 'Lỗi';

  @override
  String get professional_pet_care => 'Chăm Sóc Thú Cưng Chuyên Nghiệp';

  @override
  String get comprehensive_pet_care_services => 'Dịch vụ chăm sóc toàn diện cho thú cưng của bạn';

  @override
  String get care_services => 'Dịch Vụ Chăm Sóc';

  @override
  String get view_all => 'Xem tất cả';

  @override
  String get doctor_team => 'Đội Ngũ Bác Sĩ';

  @override
  String get common_diseases => 'Bệnh Thường Gặp';

  @override
  String get search_diseases => 'Tìm kiếm bệnh...';

  @override
  String get contact => 'Liên Hệ';

  @override
  String get contact_address => '123 Đường Phan Đình Giót, Hà Đông, Hà Nội';

  @override
  String get contact_phone => '0123 456 789';

  @override
  String get contact_email => 'contact@petcare.com';

  @override
  String get high_danger => 'Nguy hiểm cao';

  @override
  String get medium_danger => 'Nguy hiểm trung bình';

  @override
  String get low_danger => 'Nguy hiểm thấp';

  @override
  String get dog_and_cat => 'Chó & Mèo';

  @override
  String get dog => 'Chó';

  @override
  String get cat => 'Mèo';

  @override
  String get main_symptoms => 'triệu chứng chính';

  @override
  String get book_appointment_feature_coming_soon => 'Tính năng đặt lịch sẽ được cập nhật sớm!';

  @override
  String get book_appointment => 'Đặt lịch';

  @override
  String get service_medical_exam => 'Khám bệnh';

  @override
  String get service_medical_exam_desc => 'Khám và điều trị bệnh cho thú cưng';

  @override
  String get service_spa_care => 'Chăm sóc spa';

  @override
  String get service_spa_care_desc => 'Tắm rửa, cắt tỉa lông, móng';

  @override
  String get service_vaccination => 'Tiêm Chủng';

  @override
  String get service_vaccination_desc => 'Tiêm phòng và tư vấn sức khỏe';

  @override
  String get service_nutrition => 'Dinh Dưỡng';

  @override
  String get service_nutrition_desc => 'Tư vấn chế độ ăn phù hợp';

  @override
  String get login => 'Đăng nhập';

  @override
  String get password => 'Mật khẩu';

  @override
  String get login_error => 'Lỗi đăng nhập';

  @override
  String get close => 'Đóng';

  @override
  String get forgot_password => 'Quên mật khẩu?';

  @override
  String get or => 'Hoặc';

  @override
  String get login_with_google => 'Đăng nhập với Google';

  @override
  String get login_google_failed => 'Đăng nhập Google thất bại';

  @override
  String get login_with_facebook => 'Đăng nhập với Facebook';

  @override
  String get login_facebook_failed => 'Đăng nhập Facebook thất bại';

  @override
  String get no_account => 'Bạn chưa có tài khoản? ';

  @override
  String get signup => 'Đăng ký';

  @override
  String get signup_title => 'Đăng ký tài khoản';

  @override
  String get name => 'Tên';

  @override
  String get user => 'Người dùng';

  @override
  String get doctor => 'Bác sĩ';

  @override
  String get select_role => 'Chọn vai trò';

  @override
  String get cancel => 'Hủy';

  @override
  String get has_account => 'Đã có tài khoản? ';

  @override
  String today_how_is(Object petName) {
    return 'Hôm nay $petName thế nào?';
  }

  @override
  String get select_pet_to_see_reminders => 'Hãy chọn thú cưng để xem nhắc nhở';

  @override
  String get no_pets_yet => 'Bạn chưa có thú cưng nào';

  @override
  String get reminders => 'Nhắc nhở';

  @override
  String get no_reminders => 'Không có nhắc nhở nào.';

  @override
  String get confirm_delete => 'Xác nhận xóa';

  @override
  String get confirm_delete_reminder => 'Bạn có chắc muốn xóa nhắc nhở này?';

  @override
  String get delete => 'Xóa';

  @override
  String get delete_reminder_success => 'Xóa nhắc nhở thành công!';

  @override
  String delete_reminder_error(Object error) {
    return 'Lỗi khi xóa nhắc nhở: $error';
  }

  @override
  String get appointments => 'Lịch hẹn';

  @override
  String get no_appointments => 'Không có lịch hẹn nào.';

  @override
  String appointment_time(Object time) {
    return 'Thời gian: $time';
  }

  @override
  String doctor_name(Object name) {
    return 'Bác sĩ: $name';
  }

  @override
  String status(Object status) {
    return 'Trạng thái: $status';
  }

  @override
  String get select_pet_to_see_tips => 'Hãy chọn thú cưng để xem các tips';

  @override
  String get add_health_metrics => 'Thêm chỉ số sức khỏe';

  @override
  String get health_records => 'Hồ sơ & Chỉ số sức khỏe';

  @override
  String get health_summary => 'Tóm tắt sức khỏe';

  @override
  String get medical_records_auto_update => 'Hồ sơ y tế và tiêm chủng được cập nhật tự động từ bác sĩ';

  @override
  String get weight => 'Cân nặng';

  @override
  String get no_data => 'Chưa có dữ liệu';

  @override
  String get recently_updated => 'Cập nhật gần đây';

  @override
  String get needs_update => 'Cần cập nhật';

  @override
  String get health_status => 'Tình trạng';

  @override
  String get needs_attention => 'Cần chú ý';

  @override
  String get normal => 'Bình thường';

  @override
  String get vaccination => 'Tiêm chủng';

  @override
  String get complete => 'Đầy đủ';

  @override
  String overdue_shots(Object count) {
    return '$count mũi quá hạn';
  }

  @override
  String upcoming_shots(Object count) {
    return '$count mũi sắp đến hạn';
  }

  @override
  String get medical_records => 'Hồ sơ y tế';

  @override
  String records_count(Object count) {
    return '$count bản ghi';
  }

  @override
  String get medical_history => 'Lịch sử y tế';

  @override
  String get no_medical_records => 'Chưa có hồ sơ y tế';

  @override
  String get medical_records_will_show_here => 'Hồ sơ y tế sẽ hiển thị ở đây';

  @override
  String get all_reminders => 'Tất cả lời nhắc';

  @override
  String get all_appointments => 'Tất cả lịch hẹn';

  @override
  String get growth_chart => 'Biểu đồ tăng trưởng';

  @override
  String get no_weight_data => 'Chưa có dữ liệu cân nặng';

  @override
  String get unit_kg => 'Đơn vị: kg';

  @override
  String get ai_recommendation => 'AI Khuyến nghị';

  @override
  String get no_doctor_info => 'Không có thông tin';

  @override
  String get dental_care_tip => 'Chăm sóc răng miệng cho thú cưng';

  @override
  String get dental_care_desc => 'Đánh răng thường xuyên giúp ngăn ngừa các bệnh về răng miệng và hơi thở thơm mát.';

  @override
  String get bathing_tip => 'Tắm rửa đúng cách';

  @override
  String get bathing_desc => 'Tắm 2-3 lần/tháng với sữa tắm chuyên dụng, tránh để nước vào tai và mắt.';

  @override
  String get nutrition_tip => 'Chế độ ăn cân bằng';

  @override
  String get nutrition_desc => 'Cung cấp đầy đủ protein, vitamin và khoáng chất theo độ tuổi và cân nặng.';

  @override
  String get exercise_tip => 'Vận động hàng ngày';

  @override
  String get exercise_desc => 'Dành 30-60 phút mỗi ngày để chơi đùa và tập thể dục cùng thú cưng.';

  @override
  String get general_tips => 'Tips chung';

  @override
  String get personal_profile => 'Hồ sơ cá nhân';

  @override
  String get user_not_found => 'Không tìm thấy thông tin người dùng';

  @override
  String get veterinarian => 'Bác sĩ thú y';

  @override
  String get pet_lover => 'Pet Lover';

  @override
  String get edit_profile => 'Chỉnh sửa hồ sơ';

  @override
  String get pets => 'Thú cưng';

  @override
  String get services => 'Dịch vụ';

  @override
  String get health => 'Sức khỏe';

  @override
  String get good => 'Tốt';

  @override
  String get pet_management => 'Quản lý thú cưng';

  @override
  String get view_edit_pet_profiles => 'Xem & chỉnh sửa hồ sơ thú cưng';

  @override
  String get service_history => 'Lịch sử dịch vụ';

  @override
  String get view_service_booking_history => 'Xem lịch sử đặt dịch vụ';

  @override
  String get store_exam_test_results => 'Lưu trữ kết quả khám, xét nghiệm';

  @override
  String get health_statistics => 'Thống kê sức khỏe';

  @override
  String get track_pet_health => 'Theo dõi sức khỏe thú cưng';

  @override
  String get nutrition => 'Dinh dưỡng';

  @override
  String get menu_nutrition_suggestions => 'Gợi ý thực đơn, dinh dưỡng';

  @override
  String get exit_account => 'Thoát tài khoản';

  @override
  String get pet_community => 'Cộng đồng thú cưng';

  @override
  String get try_again => 'Thử lại';

  @override
  String get add_story => 'Thêm tin';

  @override
  String get you => 'Bạn';

  @override
  String get no_posts_yet => 'Chưa có bài viết nào trong cộng đồng.\nHãy là người đầu tiên chia sẻ những khoảnh khắc đáng yêu của thú cưng!';

  @override
  String get create_first_post => 'Tạo bài viết đầu tiên';

  @override
  String get all => 'Tất cả';

  @override
  String get pending => 'Chờ xác nhận';

  @override
  String get confirmed => 'Đã xác nhận';

  @override
  String get completed => 'Hoàn thành';

  @override
  String get cancelled => 'Đã hủy';

  @override
  String cannot_load_service_history(Object error) {
    return 'Không thể tải lịch sử dịch vụ: $error';
  }

  @override
  String get no_service_history => 'Chưa có lịch sử dịch vụ';

  @override
  String get search_by_service_doctor => 'Tìm theo dịch vụ, bác sĩ...';

  @override
  String get pet_service => 'Dịch vụ thú cưng';

  @override
  String get select_doctor => 'Chọn bác sĩ';

  @override
  String get no_doctors_available => 'Không có bác sĩ nào phù hợp cho dịch vụ này';

  @override
  String service(Object title) {
    return 'Dịch vụ: $title';
  }

  @override
  String date(Object date) {
    return 'Ngày: $date';
  }

  @override
  String time(Object time) {
    return 'Giờ: $time';
  }

  @override
  String get reviews => 'đánh giá';

  @override
  String experience(Object years) {
    return 'Kinh nghiệm: $years';
  }

  @override
  String get no_schedule => 'Không có lịch';

  @override
  String get contiNue => 'Tiếp tục';

  @override
  String get please_select_date_time_first => 'Vui lòng chọn ngày và giờ trước khi chọn bác sĩ';

  @override
  String get please_select_all_info => 'Vui lòng chọn đầy đủ thông tin';

  @override
  String get booking_success => 'Đặt lịch thành công!';

  @override
  String get book_service => 'Đặt lịch dịch vụ';

  @override
  String get contact_for_price => 'Liên hệ để biết giá';

  @override
  String get service_description => 'Mô tả dịch vụ';

  @override
  String get select_pet => 'Chọn thú cưng';

  @override
  String get select_date => 'Chọn ngày';

  @override
  String get select_time => 'Chọn giờ';

  @override
  String get book_now => 'Đặt lịch ngay';

  @override
  String get add_new_pet => 'Thêm thú cưng mới';

  @override
  String get change_date => 'Thay đổi ngày';

  @override
  String get please_select_date_first => 'Vui lòng chọn ngày trước';

  @override
  String get please_select_date_time => 'Vui lòng chọn ngày và giờ trước';

  @override
  String get change_doctor => 'Thay đổi bác sĩ';

  @override
  String get category => 'Danh mục';

  @override
  String get service_details => 'Chi tiết dịch vụ';
}
