/// Data extracted from identity documents
class DocumentData {
  const DocumentData({
    required this.name,
    required this.surname,
    required this.idNumber,
    required this.nationality,
    this.dateOfBirth,
    this.expirationDate,
    this.documentType,
  });

  final String name;
  final String surname;
  final String idNumber;
  final String nationality;
  final DateTime? dateOfBirth;
  final DateTime? expirationDate;
  final String? documentType;

  /// Convert to JSON map for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'idNumber': idNumber,
      'nationality': nationality,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (expirationDate != null) 'expirationDate': expirationDate!.toIso8601String(),
      if (documentType != null) 'documentType': documentType,
    };
  }

  /// Create from JSON map
  factory DocumentData.fromJson(Map<String, dynamic> json) {
    return DocumentData(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      idNumber: json['idNumber'] ?? '',
      nationality: json['nationality'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
        ? DateTime.tryParse(json['dateOfBirth'])
        : null,
      expirationDate: json['expirationDate'] != null
        ? DateTime.tryParse(json['expirationDate'])
        : null,
      documentType: json['documentType'],
    );
  }

  /// Check if all required fields are present
  bool get isValid => name.isNotEmpty && surname.isNotEmpty && idNumber.isNotEmpty && nationality.isNotEmpty;

  /// Get display name
  String get fullName => '$name $surname';

  @override
  String toString() => 'DocumentData(name: $name, surname: $surname, idNumber: $idNumber, nationality: $nationality)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          surname == other.surname &&
          idNumber == other.idNumber &&
          nationality == other.nationality;

  @override
  int get hashCode => name.hashCode ^ surname.hashCode ^ idNumber.hashCode ^ nationality.hashCode;
}