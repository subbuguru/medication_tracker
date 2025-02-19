class UserProfile {
  int? id;
  String name;
  String dob; // Date of Birth as String
  String pcp; // Primary Care Physician
  String healthConditions;
  String pharmacy;

  UserProfile(
      {this.id,
      required this.name,
      required this.dob,
      this.pcp = '',
      this.healthConditions = '',
      this.pharmacy = ''});

  // Convert a UserProfile instance into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'pcp': pcp,
      'healthConditions': healthConditions,
      'pharmacy': pharmacy,
    };
  }

  // Create a UserProfile from a map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      dob: map['dob'],
      pcp: map['pcp'] ?? '',
      healthConditions: map['healthConditions'] ?? '',
      pharmacy: map['pharmacy'] ?? '',
    );
  }
}
