class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is verplicht";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;

    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value)) {
      return "Voer een geldig e-mailadres in";
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;

    final regex = RegExp(r'^[0-9 +()-]{6,}$');
    if (!regex.hasMatch(value)) {
      return "Voer een geldig telefoonnummer in";
    }
    return null;
  }

  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) return null;

    final regex = RegExp(r'^[0-9]{4}\s?[A-Za-z]{2}$');
    if (!regex.hasMatch(value)) {
      return "Gebruik het formaat 1234 AB";
    }
    return null;
  }

  static String? notInFuture(DateTime? date, String fieldName) {
    if (date == null) return null;

    final now = DateTime.now();
    if (date.isAfter(DateTime(now.year, now.month, now.day))) {
      return "$fieldName mag niet in de toekomst liggen";
    }
    return null;
  }

  static String? deathAfterBirth(DateTime? birth, DateTime? death) {
    if (birth == null || death == null) return null;

    if (death.isBefore(birth)) {
      return "Overlijdensdatum moet na geboortedatum liggen";
    }
    return null;
  }
}
