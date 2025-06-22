# Hướng Dẫn Triển Khai Tính Năng Bác Sĩ

## Tổng Quan

Tài liệu này mô tả cách triển khai tính năng quản lý bác sĩ và tích hợp với hệ thống đặt lịch hẹn trong ứng dụng PetCare.

## Các Tính Năng Đã Triển Khai

### 1. Quản Lý Thông Tin Bác Sĩ

- **Model dữ liệu mở rộng**: `DoctorModel` với các trường mới:
  - `specializations`: Danh sách chuyên ngành
  - `workingDays`: Các ngày làm việc
  - `workingHours`: Giờ làm việc
  - `isAvailable`: Trạng thái có sẵn
  - `serviceIds`: Danh sách dịch vụ có thể thực hiện

### 2. Quản Lý Lịch Làm Việc

- **TimeSlotModel**: Quản lý các khung giờ có thể đặt lịch
- Kiểm tra tính khả dụng theo ngày và giờ
- Tự động ẩn các khung giờ đã qua

### 3. Tích Hợp Với Đặt Lịch Hẹn

- **AppointmentModel mở rộng**: Thêm `doctorId` và `doctorName`
- Quy trình đặt lịch: Dịch vụ → Ngày → Giờ → Bác sĩ
- Kiểm tra tính khả dụng của bác sĩ theo thời gian

### 4. Giao Diện Người Dùng

- **SelectDoctorScreen**: Màn hình chọn bác sĩ
- **AllDoctorsScreen**: Màn hình xem tất cả bác sĩ với tìm kiếm và lọc
- **BookServiceScreenV2**: Màn hình đặt lịch với tích hợp chọn bác sĩ

## Kiến Trúc Hệ Thống

### Domain Layer

```
domain/
├── repository/
│   └── DoctorRepository.dart
└── usecase/
    └── doctor/
        ├── GetDoctorsByServiceUseCase.dart
        └── GetAvailableTimeSlotsUseCase.dart
```

### Data Layer

```
data/
├── model/
│   ├── DoctorModel.dart (updated)
│   ├── AppointmentModel.dart (updated)
│   └── TimeSlotModel.dart (new)
├── repository/
│   └── DoctorRepositoryImpl.dart
└── source/
    └── DoctorDataSource.dart
```

### Presentation Layer

```
presentation/
├── ui/
│   ├── doctor/
│   │   ├── DoctorViewModel.dart (updated)
│   │   ├── AllDoctorsScreen.dart (new)
│   │   └── DoctorDetailScreen.dart
│   └── user/
│       └── serviceScreen/
│           ├── SelectDoctorScreen.dart (new)
│           └── BookServiceScreenV2.dart (new)
```

## Quy Trình Đặt Lịch Hẹn

### 1. Chọn Dịch Vụ

- Người dùng chọn dịch vụ từ danh sách

### 2. Chọn Thú Cưng

- Chọn thú cưng cần khám/chăm sóc

### 3. Chọn Ngày

- Chọn ngày từ calendar (tối thiểu 1 ngày sau)

### 4. Chọn Giờ

- Hiển thị các khung giờ có sẵn (8:00-17:00)

### 5. Chọn Bác Sĩ

- Hiển thị danh sách bác sĩ phù hợp với:
  - Dịch vụ đã chọn
  - Ngày và giờ đã chọn
  - Trạng thái có sẵn

### 6. Xác Nhận Đặt Lịch

- Hiển thị thông tin tổng hợp
- Xác nhận đặt lịch

## Xử Lý Trường Hợp Đặc Biệt

### 1. Bác Sĩ Kín Lịch

- **Hiển thị trạng thái**: "Không có lịch" với màu đỏ
- **Không cho phép chọn**: Disable button chọn
- **Gợi ý thay thế**: Hiển thị bác sĩ khác cùng chuyên ngành

### 2. Không Có Bác Sĩ Phù Hợp

- **Thông báo rõ ràng**: "Không có bác sĩ nào phù hợp"
- **Gợi ý**: Chọn ngày/giờ khác hoặc dịch vụ khác

### 3. Bác Sĩ Nghỉ Làm

- **Cập nhật trạng thái**: `isAvailable = false`
- **Ẩn khỏi danh sách**: Không hiển thị trong lựa chọn

## Cấu Hình Dữ Liệu

### 1. Chuyên Ngành Bác Sĩ

```dart
final specializations = [
  'Thú y tổng hợp',
  'Phẫu thuật',
  'Da liễu thú y',
  'Tim mạch',
  'Tiêm chủng',
  'Dị ứng',
  'Ký sinh trùng',
  'Chấn thương',
  'Chỉnh hình',
  'Siêu âm',
  'Điện tâm đồ'
];
```

### 2. Khung Giờ Làm Việc

```dart
final timeSlots = [
  '08:00', '09:00', '10:00', '11:00',
  '13:00', '14:00', '15:00', '16:00', '17:00'
];
```

### 3. Ngày Làm Việc

```dart
final workingDays = [
  'Monday', 'Tuesday', 'Wednesday',
  'Thursday', 'Friday', 'Saturday'
];
```

## Triển Khai Firebase/Supabase

### 1. Cấu Trúc Database

#### Collection: doctors

```json
{
  "id": "string",
  "name": "string",
  "specialization": "string",
  "specializations": ["array"],
  "experience": "string",
  "education": "string",
  "image_url": "string",
  "description": "string",
  "certifications": ["array"],
  "rating": "number",
  "review_count": "number",
  "working_days": ["array"],
  "working_hours": "string",
  "is_available": "boolean",
  "service_ids": ["array"]
}
```

#### Collection: time_slots

```json
{
  "id": "string",
  "doctor_id": "string",
  "date": "date",
  "start_time": "string",
  "end_time": "string",
  "is_available": "boolean",
  "appointment_id": "string"
}
```

#### Collection: appointments (updated)

```json
{
  "id": "string",
  "service_id": "number",
  "pet_id": "string",
  "user_id": "string",
  "doctor_id": "string",
  "doctor_name": "string",
  "appointment_time": "datetime",
  "status": "string",
  "notes": "string"
}
```

### 2. Rules và Indexes

#### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Doctors collection
    match /doctors/{doctorId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }

    // Time slots collection
    match /time_slots/{slotId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Appointments collection
    match /appointments/{appointmentId} {
      allow read: if request.auth != null &&
        (resource.data.user_id == request.auth.uid ||
         request.auth.token.admin == true);
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (resource.data.user_id == request.auth.uid ||
         request.auth.token.admin == true);
    }
  }
}
```

## Testing

### 1. Unit Tests

```dart
// Test DoctorModel
test('should create doctor with correct data', () {
  final doctor = DoctorModel(
    id: '1',
    name: 'Dr. Test',
    specialization: 'Test',
    specializations: ['Test'],
    experience: '5 years',
    education: 'Test University',
    imageUrl: 'test.jpg',
    description: 'Test description',
    certifications: ['Test Cert'],
    rating: 4.5,
    reviewCount: 10,
    workingDays: ['Monday'],
    workingHours: '09:00-17:00',
    isAvailable: true,
    serviceIds: ['1'],
  );

  expect(doctor.name, 'Dr. Test');
  expect(doctor.canPerformService('1'), true);
  expect(doctor.isWorkingOnDay('Monday'), true);
});
```

### 2. Integration Tests

```dart
// Test booking flow
testWidgets('should complete booking flow with doctor selection', (tester) async {
  await tester.pumpWidget(MyApp());

  // Navigate to service booking
  await tester.tap(find.text('Đặt lịch'));
  await tester.pumpAndSettle();

  // Select pet
  await tester.tap(find.text('Pet Name'));
  await tester.pumpAndSettle();

  // Select date
  await tester.tap(find.text('Chọn ngày'));
  await tester.pumpAndSettle();

  // Select time
  await tester.tap(find.text('09:00'));
  await tester.pumpAndSettle();

  // Select doctor
  await tester.tap(find.text('Chọn bác sĩ'));
  await tester.pumpAndSettle();

  // Verify doctor selection
  expect(find.text('Dr. Test'), findsOneWidget);
});
```

## Monitoring và Analytics

### 1. Key Metrics

- Số lượng đặt lịch thành công
- Tỷ lệ bác sĩ được chọn
- Thời gian trung bình để hoàn thành đặt lịch
- Tỷ lệ hủy lịch

### 2. Error Tracking

- Lỗi khi tải danh sách bác sĩ
- Lỗi khi kiểm tra tính khả dụng
- Lỗi khi đặt lịch

## Bảo Mật

### 1. Data Protection

- Mã hóa thông tin cá nhân bác sĩ
- Kiểm soát quyền truy cập theo role
- Audit log cho các thay đổi quan trọng

### 2. Input Validation

- Validate tất cả input từ user
- Sanitize data trước khi lưu
- Rate limiting cho API calls

## Tương Lai

### 1. Tính Năng Nâng Cao

- **Video call**: Tích hợp khám từ xa
- **AI scheduling**: Tự động sắp xếp lịch tối ưu
- **Multi-language**: Hỗ trợ đa ngôn ngữ
- **Push notifications**: Thông báo lịch hẹn

### 2. Performance Optimization

- **Caching**: Cache danh sách bác sĩ
- **Pagination**: Phân trang cho danh sách lớn
- **Lazy loading**: Tải hình ảnh theo nhu cầu

## Kết Luận

Tính năng quản lý bác sĩ đã được triển khai hoàn chỉnh với:

- Kiến trúc clean architecture
- UI/UX thân thiện
- Xử lý lỗi robust
- Khả năng mở rộng cao

Hệ thống sẵn sàng cho production và có thể dễ dàng mở rộng thêm tính năng mới.
