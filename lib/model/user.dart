class User {
  String? userId;
  String? phoneNumber;
  String? fid;
  String? employeeId;
  String? designation;
  String? email;
  String? region;
  String? mbu;
  String? userName;
  String? userAddress;
  String? imageUrl;
  Map<String, dynamic>? linkedRetailers;
  List<Map<String, dynamic>> modules; // Property to hold module data

  User({
    this.userId,
    this.phoneNumber,
    this.fid,
    this.employeeId,
    this.designation,
    this.email,
    this.region,
    this.mbu,
    this.userAddress,
    this.userName,
    this.imageUrl,
    this.linkedRetailers,
    this.modules = const [], // Default to an empty list
  });

  // Factory method to create User from Firestore document snapshot
  factory User.fromDocumentSnapshot(Map<String, dynamic> doc, List<Map<String, dynamic>> modules) {
    return User(
      userId: doc['userId'],
      phoneNumber: doc['phoneNumber'],
      fid: doc['fid'],
      employeeId: doc['employeeId'],
      email: doc['email'],
      designation: doc['designation'],
      region: doc['region'],
      userAddress: doc['userAddress'],
      userName: doc['userName'],
      mbu: doc['mbu'],
      imageUrl: doc.containsKey('imageUrl') ? doc['imageUrl'] : null,
      linkedRetailers: doc['linkedRetailers'] != null ? Map<String, dynamic>.from(doc['linkedRetailers']) : null,
      modules: modules, // Assign the modules fetched from Firestore
    );
  }

  // Convert User to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'fid': fid,
      'employeeId': employeeId,
      'email': email,
      'designation': designation,
      'region': region,
      'userName': userName,
      'userAddress': userAddress,
      'mbu': mbu,
      'imageUrl': imageUrl,
      'linkedRetailers': linkedRetailers,
      // Note: Handle modules if you want to store them back to Firestore
    };
  }
}
