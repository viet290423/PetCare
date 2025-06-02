import 'package:flutter/material.dart';

IconData getIconFromName(String name) {
  switch (name) {
    case 'medical_services':
      return Icons.medical_services;
    case 'spa':
      return Icons.spa;
    case 'vaccines':
      return Icons.vaccines;
    case 'restaurant':
      return Icons.restaurant;
    case 'bug_report':
      return Icons.bug_report;
    case 'sick':
      return Icons.sick;
    case 'warning':
      return Icons.warning;
    case 'pets':
      return Icons.pets;
  // Thêm các icon khác tại đây
    default:
      return Icons.help_outline;
  }
}
