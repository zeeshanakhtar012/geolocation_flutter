class UserData {
  final String? id;
  final String name;
  final String age;
  final String dateOfBirth;
  final String phoneNo;
  final String optionalEmail;
  final String selectedImage;

  UserData({
    this.id,
    required this.name,
    required this.age,
    required this.dateOfBirth,
    required this.phoneNo,
    required this.optionalEmail,
    required this.selectedImage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'dateOfBirth': dateOfBirth,
    'phoneNo': phoneNo,
    'optionalEmail': optionalEmail,
    'selectedImage': selectedImage,
  };
}
