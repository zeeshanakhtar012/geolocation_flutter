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
  String? deviceToken;
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
    this.deviceToken,
    this.imageUrl,
    this.linkedRetailers,
    this.modules = const [], // Default to an empty list
  });

  // Factory method to create User from Firestore document snapshot
  factory User.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return User(
      userId: doc['userId'] as String?, // Cast to String?
      phoneNumber: doc['phoneNumber'] as String?,
      fid: doc['fid'] as String?,
      employeeId: doc['employeeId'] as String?,
      email: doc['email'] as String?,
      designation: doc['designation'] as String?,
      region: doc['region'] as String?,
      userAddress: doc['userAddress'] as String?,
      userName: doc['userName'] as String?,
      deviceToken: doc['deviceToken'] as String?,
      mbu: doc['mbu'] as String?,
      imageUrl: doc.containsKey('imageUrl') ? doc['imageUrl'] as String? : null,
      linkedRetailers: doc['linkedRetailers'] != null ? Map<String, dynamic>.from(doc['linkedRetailers']) : null,
      modules: [], // Assign an empty list if no modules are provided
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
      'deviceToken': deviceToken,
      'imageUrl': imageUrl,
      'linkedRetailers': linkedRetailers,
      'modules': modules, // Add modules if needed
    };
  }
}
