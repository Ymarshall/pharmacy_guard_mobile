import 'package:flutter/material.dart';

/// Convertit un nom d'icône String en IconData Material Icons
class IconUtils {
  static final Map<String, IconData> _iconMap = {
    'local_police': Icons.local_police,
    'local_hospital': Icons.local_hospital,
    'fire_extinguisher': Icons.fire_extinguisher,
    'bloodtype': Icons.bloodtype,
    'info': Icons.info,
    'emergency': Icons.emergency,
    'phone': Icons.phone,
    'add': Icons.add,
    'call': Icons.call,
    'medical_services': Icons.medical_services,
    'emergency_outlined': Icons.emergency_outlined,
    'local_police_outlined': Icons.local_police_outlined,
    'local_hospital_outlined': Icons.local_hospital_outlined,
    'fire_extinguisher_outlined': Icons.fire_extinguisher_outlined,
    'bloodtype_outlined': Icons.bloodtype_outlined,
    'info_outline': Icons.info_outline,
  };

  /// Convertit un nom d'icône en IconData
  /// Retourne Icons.info si l'icône n'est pas trouvée
  static IconData getIcon(String iconName) {
    // Retirer le préfixe "Icons." si présent
    final cleanName = iconName.replaceAll('Icons.', '').trim();
    return _iconMap[cleanName] ?? Icons.info;
  }

  /// Convertit une couleur hexadécimale en Color
  /// Retourne Colors.red si la conversion échoue
  static Color hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) {
        buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      }
      return Colors.red;
    } catch (e) {
      return Colors.red;
    }
  }
}

