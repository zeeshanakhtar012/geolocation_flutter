import 'package:Jazz/model/retailers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ControllerRetailers extends GetxController {

  Future<RetailerModel?> getRetailerFromFirestore(String retailerId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('retailers').doc(retailerId).get();

    if (doc.exists) {
      return RetailerModel.fromMap(doc.data() as Map<String, dynamic>); // Changed from fromDocumentSnapshot to fromMap
    }
    return null;
  }

  // Fetch retailers using posid
  Future<RetailerModel?> getRetailerByPosId(String posId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('retailers')
        .where('posId', isEqualTo: posId)
        .get();

    if (query.docs.isNotEmpty) {
      return RetailerModel.fromMap(query.docs.first.data() as Map<String, dynamic>); // Changed from fromDocumentSnapshot to fromMap
    }
    return null;
  }

}
