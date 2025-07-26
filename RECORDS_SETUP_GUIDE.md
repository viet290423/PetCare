# Hướng Dẫn Setup Hệ Thống Records

## Tổng Quan

Hệ thống Records đã được điều chỉnh theo workflow thực tế:

### **Luồng hoạt động:**

1. **Người dùng** đặt lịch hẹn khám/tiêm chủng
2. **Bác sĩ** xác nhận lịch hẹn
3. **Bác sĩ** ghi lại hồ sơ y tế và lịch sử tiêm chủng sau khi khám
4. **Người dùng** chỉ nhập chỉ số sức khỏe hàng ngày
5. **RECORDS** hiển thị dữ liệu từ cả 2 nguồn

### **Tính năng:**

- **Hồ sơ y tế**: Được bác sĩ ghi sau khi khám
- **Chỉ số sức khỏe**: Người dùng tự nhập hàng ngày
- **Lịch sử tiêm chủng**: Được bác sĩ ghi sau khi tiêm

## Bước 1: Tạo Database Schema

Chạy script SQL sau trong Supabase SQL Editor:

```sql
-- 1. Bảng medical_records (Hồ sơ y tế)
CREATE TABLE IF NOT EXISTS medical_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    record_type VARCHAR(50) NOT NULL CHECK (record_type IN ('checkup', 'vaccination', 'treatment', 'surgery', 'test')),
    record_date TIMESTAMP WITH TIME ZONE NOT NULL,
    doctor_id UUID REFERENCES doctors(id),
    doctor_name VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'ongoing', 'scheduled', 'cancelled')),
    cost DECIMAL(10,2),
    notes TEXT,
    attachments TEXT[],
    vitals JSONB,
    medications TEXT[],
    next_visit_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Bảng health_metrics (Chỉ số sức khỏe)
CREATE TABLE IF NOT EXISTS health_metrics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    weight DECIMAL(5,2),
    temperature DECIMAL(4,2),
    heart_rate INTEGER,
    respiratory_rate INTEGER,
    blood_pressure_systolic DECIMAL(5,2),
    blood_pressure_diastolic DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Bảng vaccination_records (Lịch sử tiêm chủng)
CREATE TABLE IF NOT EXISTS vaccination_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
    vaccine_name VARCHAR(255) NOT NULL,
    vaccine_type VARCHAR(50) NOT NULL CHECK (vaccine_type IN ('core', 'non-core', 'rabies', 'other')),
    vaccination_date DATE NOT NULL,
    next_due_date DATE,
    batch_number VARCHAR(100),
    manufacturer VARCHAR(255),
    administered_by VARCHAR(255),
    notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'scheduled', 'overdue')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tạo indexes
CREATE INDEX IF NOT EXISTS idx_medical_records_pet_id ON medical_records(pet_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_record_date ON medical_records(record_date);
CREATE INDEX IF NOT EXISTS idx_medical_records_record_type ON medical_records(record_type);

CREATE INDEX IF NOT EXISTS idx_health_metrics_pet_id ON health_metrics(pet_id);
CREATE INDEX IF NOT EXISTS idx_health_metrics_date ON health_metrics(date);

CREATE INDEX IF NOT EXISTS idx_vaccination_records_pet_id ON vaccination_records(pet_id);
CREATE INDEX IF NOT EXISTS idx_vaccination_records_vaccination_date ON vaccination_records(vaccination_date);
CREATE INDEX IF NOT EXISTS idx_vaccination_records_next_due_date ON vaccination_records(next_due_date);

-- RLS Policies
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE vaccination_records ENABLE ROW LEVEL SECURITY;

-- Policies cho medical_records
CREATE POLICY "Users can view their own pets' medical records" ON medical_records
    FOR SELECT USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can insert medical records for their own pets" ON medical_records
    FOR INSERT WITH CHECK (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can update medical records for their own pets" ON medical_records
    FOR UPDATE USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can delete medical records for their own pets" ON medical_records
    FOR DELETE USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

-- Policies cho health_metrics
CREATE POLICY "Users can view their own pets' health metrics" ON health_metrics
    FOR SELECT USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can insert health metrics for their own pets" ON health_metrics
    FOR INSERT WITH CHECK (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can update health metrics for their own pets" ON health_metrics
    FOR UPDATE USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can delete health metrics for their own pets" ON health_metrics
    FOR DELETE USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

-- Policies cho vaccination_records
CREATE POLICY "Users can view their own pets' vaccination records" ON vaccination_records
    FOR SELECT USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can insert vaccination records for their own pets" ON vaccination_records
    FOR INSERT WITH CHECK (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can update vaccination records for their own pets" ON vaccination_records
    FOR UPDATE USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

CREATE POLICY "Users can delete vaccination records for their own pets" ON vaccination_records
    FOR DELETE USING (pet_id IN (SELECT id FROM pets WHERE user_id = auth.uid()));

-- Trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger cho medical_records
CREATE TRIGGER update_medical_records_updated_at
    BEFORE UPDATE ON medical_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Bước 2: Cài đặt Dependencies

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  uuid: ^4.0.0
```

Chạy:

```bash
flutter pub get
```

## Bước 3: Test Ứng Dụng

### **Cho người dùng:**

1. Khởi động ứng dụng
2. Vào tab RECORDS trong PetScreen
3. Sử dụng nút "+" để thêm chỉ số sức khỏe
4. Xem hồ sơ y tế và tiêm chủng được cập nhật tự động

### **Cho bác sĩ:**

1. Vào màn hình lịch hẹn
2. Xác nhận lịch hẹn
3. Sau khi khám, nhấn "Ghi hồ sơ" hoặc "Ghi tiêm chủng"
4. Điền thông tin và lưu

## Tính Năng Đã Hoàn Thiện

### 1. Hồ sơ y tế (Bác sĩ)

- ✅ Ghi hồ sơ sau khi khám
- ✅ Phân loại: Khám định kỳ, Tiêm chủng, Điều trị, Phẫu thuật, Xét nghiệm
- ✅ Thông tin bác sĩ, chi phí, chẩn đoán
- ✅ Ngày tái khám tự động tính

### 2. Chỉ số sức khỏe (Người dùng)

- ✅ Người dùng tự nhập hàng ngày
- ✅ Theo dõi cân nặng, nhiệt độ, nhịp tim, nhịp thở, huyết áp
- ✅ Hiển thị chỉ số bình thường
- ✅ Ghi chú cho từng lần đo

### 3. Lịch sử tiêm chủng (Bác sĩ)

- ✅ Ghi sau khi tiêm chủng
- ✅ Quản lý vaccine cốt lõi, bổ sung, dại
- ✅ Tự động tính ngày tiêm nhắc lại
- ✅ Thông tin nhà sản xuất, số lô, bác sĩ tiêm

### 4. Tóm tắt sức khỏe (Người dùng)

- ✅ Hiển thị cân nặng mới nhất
- ✅ Tình trạng vaccine (quá hạn/sắp đến hạn)
- ✅ Số lượng hồ sơ y tế
- ✅ Thông báo dữ liệu được cập nhật tự động

## Các Bước Tiếp Theo

### 1. Tính năng nâng cao

- [ ] Biểu đồ theo dõi sức khỏe
- [ ] Nhắc nhở vaccine tự động
- [ ] Xuất báo cáo PDF
- [ ] Chia sẻ hồ sơ với bác sĩ

### 2. Tích hợp

- [ ] Liên kết với appointments
- [ ] Thông báo push cho vaccine
- [ ] Upload ảnh/xét nghiệm

### 3. Analytics

- [ ] Thống kê sức khỏe theo thời gian
- [ ] So sánh với chỉ số chuẩn
- [ ] Dự đoán sức khỏe

## Cấu Trúc Files

```
lib/
├── data/
│   ├── model/
│   │   ├── MedicalRecordModel.dart
│   │   ├── HealthMetricsModel.dart
│   │   └── VaccinationRecordModel.dart
│   ├── repository/
│   │   └── PetRepositoryImpl.dart (updated)
│   └── source/
│       └── PetDataSource.dart (updated)
├── domain/
│   ├── repository/
│   │   └── PetRepository.dart (updated)
│   └── usecase/
│       └── pet/
│           ├── GetMedicalRecordsUseCase.dart
│           ├── GetHealthMetricsUseCase.dart
│           ├── GetVaccinationRecordsUseCase.dart
│           ├── AddMedicalRecordUseCase.dart
│           ├── AddHealthMetricsUseCase.dart
│           └── AddVaccinationRecordUseCase.dart
└── presentation/
    └── ui/
        ├── user/
        │   └── petScreen/
        │       ├── AddHealthMetricsScreen.dart (chỉ người dùng)
        │       └── PetScreen.dart (updated)
        └── doctor/
            ├── AddMedicalRecordByDoctorScreen.dart (bác sĩ ghi hồ sơ)
            ├── AddVaccinationRecordByDoctorScreen.dart (bác sĩ ghi tiêm chủng)
            └── DoctorAppointmentsScreen.dart (updated với nút ghi hồ sơ)
```

## Troubleshooting

### Lỗi thường gặp:

1. **Database connection**: Kiểm tra Supabase URL và API key
2. **RLS policies**: Đảm bảo user đã đăng nhập
3. **UUID generation**: Cài đặt package uuid

### Debug:

- Kiểm tra console logs
- Verify database tables đã được tạo
- Test API calls trong Supabase dashboard
