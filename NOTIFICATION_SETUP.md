# Hướng dẫn Setup Thông báo cho Reminder

## Tổng quan

Để thêm thông báo push notification cho lịch nhắc nhở thú cưng, bạn cần thực hiện các bước sau:

## 1. Cài đặt Dependencies

Cập nhật `pubspec.yaml` với các dependencies sau:

```yaml
dependencies:
  flutter_local_notifications: ^19.2.1
  timezone: ^0.10.0 # Cần cập nhật từ ^0.9.4 lên ^0.10.0
```

Chạy lệnh:

```bash
flutter pub get
```

## 2. Cấu hình Android

### AndroidManifest.xml

Đã thêm các quyền cần thiết vào `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

## 3. Cấu hình iOS

### Info.plist

Thêm vào `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 4. Các tính năng đã được thêm

### NotificationService

- Tạo file `lib/core/services/notification_service.dart`
- Quản lý việc lên lịch thông báo
- Hỗ trợ các loại lặp lại: Không lặp, Hàng ngày, Hàng tuần, Hàng tháng, Hàng năm
- Tự động tính toán thời gian thông báo tiếp theo

### Tích hợp vào AddReminderScreen

- Tự động lên lịch thông báo khi tạo reminder mới
- Hiển thị thông báo thành công/thất bại
- Xử lý lỗi gracefully

### Chức năng xóa Reminder

- Thêm use case `DeleteReminderUseCase`
- Tích hợp vào PetViewModel
- Tự động hủy thông báo khi xóa reminder
- Confirmation dialog trước khi xóa

### Cập nhật PetScreen

- Thêm nút xóa cho mỗi reminder
- Refresh danh sách sau khi xóa
- Hiển thị thông báo kết quả

## 5. Cách hoạt động

1. **Tạo Reminder**: Khi người dùng tạo reminder mới, hệ thống sẽ:

   - Lưu reminder vào database
   - Lên lịch thông báo với thời gian và loại lặp lại
   - Hiển thị thông báo thành công

2. **Thông báo**: Khi đến giờ, hệ thống sẽ:

   - Hiển thị notification với tiêu đề và nội dung
   - Phát âm thanh và rung (nếu được cấu hình)
   - Tự động lên lịch thông báo tiếp theo (nếu có lặp lại)

3. **Xóa Reminder**: Khi người dùng xóa reminder:
   - Hiển thị dialog xác nhận
   - Hủy thông báo đã lên lịch
   - Xóa dữ liệu khỏi database
   - Refresh giao diện

## 6. Lưu ý quan trọng

- **Quyền thông báo**: Người dùng cần cấp quyền thông báo cho app
- **Battery optimization**: Một số thiết bị có thể tắt thông báo để tiết kiệm pin
- **Time zone**: Hệ thống sử dụng timezone local của thiết bị
- **Background execution**: Thông báo vẫn hoạt động khi app đóng

## 7. Testing

Để test thông báo:

1. Tạo reminder với thời gian trong tương lai gần (1-2 phút)
2. Đóng app hoặc để app chạy background
3. Chờ đến giờ và kiểm tra thông báo
4. Test các loại lặp lại khác nhau

## 8. Troubleshooting

### Thông báo không hiển thị:

- Kiểm tra quyền thông báo trong Settings
- Kiểm tra Battery optimization
- Kiểm tra Do Not Disturb mode

### Lỗi dependency:

- Chạy `flutter clean` và `flutter pub get`
- Kiểm tra version compatibility
- Cập nhật Flutter SDK nếu cần
