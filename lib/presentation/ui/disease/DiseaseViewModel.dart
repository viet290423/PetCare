import 'package:flutter/foundation.dart';

import '../../../data/model/DiseaseModel.dart';

class DiseaseViewModel extends ChangeNotifier {
  List<DiseaseModel> _diseases = [];
  bool _isLoading = false;
  String? _error;

  List<DiseaseModel> get diseases => _diseases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for now - in a real app, this would come from an API
  Future<void> fetchDiseases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _diseases = [
        DiseaseModel(
          id: '1',
          title: 'Bệnh Dại',
          description: 'Bệnh truyền nhiễm nguy hiểm, cần tiêm phòng định kỳ',
          detailedDescription: 'Bệnh dại là một bệnh truyền nhiễm nguy hiểm do virus dại gây ra, có thể lây truyền từ động vật sang người thông qua vết cắn hoặc vết thương hở tiếp xúc với nước bọt của động vật bị bệnh.',
          symptoms: [
            'Thay đổi hành vi đột ngột',
            'Chảy nhiều nước dãi',
            'Sợ nước, sợ ánh sáng',
            'Co giật, liệt',
            'Tử vong sau 2-7 ngày khi có triệu chứng'
          ],
          causes: [
            'Bị động vật nhiễm bệnh cắn',
            'Tiếp xúc với nước bọt của động vật bị bệnh qua vết thương hở',
            'Không tiêm phòng vaccine định kỳ'
          ],
          treatments: [
            'Tiêm phòng ngay sau khi bị cắn',
            'Rửa vết thương bằng xà phòng và nước sạch',
            'Đến cơ sở y tế ngay lập tức',
            'Không có cách điều trị khi đã có triệu chứng'
          ],
          preventions: [
            'Tiêm phòng vaccine định kỳ cho thú cưng',
            'Tránh tiếp xúc với động vật hoang dã',
            'Giữ thú cưng trong nhà hoặc có rào chắn an toàn',
            'Báo cáo động vật có dấu hiệu bệnh dại cho cơ quan chức năng'
          ],
          severity: 'high',
          petType: 'both',
          imageUrl: 'https://example.com/rabies.jpg',
          faqs: [
            'Bệnh dại có chữa được không?',
            'Thời gian ủ bệnh dại là bao lâu?',
            'Có cần tiêm phòng lại không?',
            'Dấu hiệu sớm của bệnh dại là gì?'
          ],
        ),
        DiseaseModel(
          id: '2',
          title: 'Bệnh Parvo',
          description: 'Bệnh đường ruột nguy hiểm ở chó, cần phát hiện sớm',
          detailedDescription: 'Bệnh Parvo là một bệnh truyền nhiễm nguy hiểm do virus Parvovirus gây ra, chủ yếu ảnh hưởng đến hệ tiêu hóa của chó, đặc biệt là chó con.',
          symptoms: [
            'Nôn mửa dữ dội',
            'Tiêu chảy ra máu',
            'Mất nước nhanh chóng',
            'Suy nhược, bỏ ăn',
            'Sốt cao'
          ],
          causes: [
            'Tiếp xúc với phân của chó bị bệnh',
            'Lây truyền qua các vật dụng nhiễm virus',
            'Không tiêm phòng vaccine',
            'Hệ miễn dịch yếu'
          ],
          treatments: [
            'Truyền dịch tĩnh mạch',
            'Thuốc chống nôn',
            'Kháng sinh phòng bội nhiễm',
            'Chăm sóc đặc biệt tại bệnh viện'
          ],
          preventions: [
            'Tiêm phòng vaccine đầy đủ',
            'Vệ sinh môi trường sống',
            'Cách ly chó bị bệnh',
            'Khử trùng các vật dụng'
          ],
          severity: 'high',
          petType: 'dog',
          imageUrl: 'https://example.com/parvo.jpg',
          faqs: [
            'Bệnh Parvo có lây sang người không?',
            'Chó con bao nhiêu tuổi có thể tiêm phòng?',
            'Tỷ lệ sống sót của chó bị Parvo là bao nhiêu?',
            'Cách vệ sinh nhà cửa khi có chó bị Parvo?'
          ],
        ),
        DiseaseModel(
          id: '3',
          title: 'Bệnh Giun Sán',
          description: 'Ký sinh trùng phổ biến, cần tẩy giun định kỳ',
          detailedDescription: 'Bệnh giun sán là tình trạng nhiễm ký sinh trùng phổ biến ở thú cưng, có thể gây ra các vấn đề về tiêu hóa và sức khỏe nếu không được điều trị.',
          symptoms: [
            'Sụt cân không rõ nguyên nhân',
            'Tiêu chảy hoặc táo bón',
            'Nôn mửa',
            'Bụng phình to',
            'Lông xù, kém bóng'
          ],
          causes: [
            'Ăn phải trứng giun từ môi trường',
            'Tiếp xúc với động vật bị nhiễm',
            'Không tẩy giun định kỳ',
            'Vệ sinh kém'
          ],
          treatments: [
            'Thuốc tẩy giun theo chỉ định',
            'Tẩy giun định kỳ',
            'Vệ sinh môi trường sống',
            'Kiểm tra phân định kỳ'
          ],
          preventions: [
            'Tẩy giun định kỳ 3-4 tháng/lần',
            'Vệ sinh môi trường sống',
            'Không cho ăn thịt sống',
            'Rửa tay sau khi tiếp xúc với thú cưng'
          ],
          severity: 'medium',
          petType: 'both',
          imageUrl: 'https://example.com/worms.jpg',
          faqs: [
            'Bao lâu nên tẩy giun một lần?',
            'Có thể tẩy giun tại nhà không?',
            'Dấu hiệu nhận biết thú cưng bị nhiễm giun?',
            'Giun sán có lây sang người không?'
          ],
        ),
      ];
    } catch (e) {
      _error = 'Không thể tải danh sách bệnh: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<DiseaseModel> getDiseasesByPetType(String petType) {
    return _diseases.where((disease) =>
    disease.petType == petType || disease.petType == 'both'
    ).toList();
  }

  List<DiseaseModel> searchDiseases(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _diseases.where((disease) =>
    disease.title.toLowerCase().contains(lowercaseQuery) ||
        disease.description.toLowerCase().contains(lowercaseQuery) ||
        disease.symptoms.any((symptom) =>
            symptom.toLowerCase().contains(lowercaseQuery)
        )
    ).toList();
  }
}