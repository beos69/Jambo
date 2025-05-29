class CallUtils {
  static String formatPhoneNumber(String number) {
    if (number.isEmpty) return '';

    // Format international pour la Belgique
    if (number.startsWith('0032')) {
      return '+32 ${number.substring(4)}';
    }

    // Format local belge
    if (number.startsWith('0')) {
      return number.replaceAllMapped(RegExp(r'(\d{3})(\d{2})(\d{2})(\d{2})'),
          (Match m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}');
    }

    return number;
  }

  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds s';
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes < 60) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String getCallStatusText(String status) {
    switch (status) {
      case 'connected':
        return 'Appel réussi';
      case 'failed':
        return 'Échec de l\'appel';
      case 'missed':
        return 'Appel manqué';
      case 'busy':
        return 'Occupé';
      default:
        return 'Statut inconnu';
    }
  }
}
