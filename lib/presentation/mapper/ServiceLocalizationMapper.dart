import '../../l10n/app_localizations.dart';

class ServiceLocalizationMapper {
  static String getLocalizedTitle(String originalTitle, AppLocalizations localizations) {
    switch (originalTitle.toLowerCase()) {
      case 'khám bệnh':
        return localizations.service_medical_exam;
      case 'chăm sóc spa':
        return localizations.service_spa_care;
      case 'tiêm chủng':
        return localizations.service_vaccination;
      case 'dinh dưỡng':
        return localizations.service_nutrition;
      default:
        return originalTitle; // Fallback to original if no translation found
    }
  }

  static String getLocalizedDescription(String originalDescription, AppLocalizations localizations) {
    switch (originalDescription.toLowerCase()) {
      case 'khám và điều trị bệnh cho thú cưng':
        return localizations.service_medical_exam_desc;
      case 'tắm rửa, cắt tỉa lông, móng':
        return localizations.service_spa_care_desc;
      case 'tiêm phòng và tư vấn sức khỏe':
        return localizations.service_vaccination_desc;
      case 'tư vấn chế độ ăn phù hợp':
        return localizations.service_nutrition_desc;
      default:
        return originalDescription; // Fallback to original if no translation found
    }
  }
}
