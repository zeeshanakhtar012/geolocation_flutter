import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter_practices/controllers/controller_register.dart';
import 'package:flutter_practices/screens/screen_live_location.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import 'screen_add_information.dart';

class ScreenShowDatabaseData extends StatefulWidget {
  const ScreenShowDatabaseData({super.key});

  @override
  State<ScreenShowDatabaseData> createState() => _ScreenShowDatabaseDataState();
}

class _ScreenShowDatabaseDataState extends State<ScreenShowDatabaseData> {
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("post");
    var searchController = TextEditingController().obs;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(ScreenAddInformation(
            dataId: null,
            editData: false,
          ));
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "Stored Data",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(onPressed: (){
            Get.find<ControllerRegister>().logout();
          }, child: Text("Logout", style: TextStyle(
            color: Colors.red,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),))
        ],
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          gradient: AppColors.appBackgroundColor,
        ),
        child: Column(
          children: [
            Obx(() {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 10.h,
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 10.w),
                  height: 50.h,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Color(0xFF190733),
                  ),
                  child: TextFormField(
                    controller: searchController.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: "Search",
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15.h,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              );
            }),
            Expanded(
              child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    );
                  }
                  if(snapshot.data == null){
                    Center(child: Text("No data found", style: TextStyle(
                      color: Colors.white,
                    ),));
                  }
                  print(snapshot.data!.snapshot.value);
                  return FirebaseAnimatedList(
                    query: ref,
                    itemBuilder: (context, snapshot, animation, index) {
                      final imageUrl = snapshot.child('selectedImage').value?.toString() ?? '';
                      final name = snapshot.child('name').value?.toString() ?? '';
                      final age = snapshot.child('age').value?.toString() ?? '';
                      final dataId = snapshot.key;
                      print('Item $index: Name: $name, Age: $age, Image URL: $imageUrl');

                      if (name.isNotEmpty) {
                        return ListTile(
                          onTap: () {
                            print('Data ID: $dataId');
                            Get.to(ScreenAddInformation(
                              dataId: dataId,
                              editData: true,
                            ));
                          },
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : AssetImage('assets/images/icon_circle.png') as ImageProvider,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Age: $age',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text("Edit"),
                                  onTap: () {
                                    print('Editing Data ID: $dataId'); // Print the dataId here
                                    Get.to(ScreenAddInformation(
                                      dataId: dataId, // Pass the dataId for editing
                                      editData: true,
                                    ));
                                  },
                                ),
                                PopupMenuItem(
                                  child: Text("Delete"),
                                  onTap: () {
                                    if (snapshot.key != null) {
                                      ref.child(snapshot.key!).remove();
                                    }
                                  },
                                ),
                              ];
                            },
                          ),
                        );
                      } else {
                        return Container(); // Return an empty container if no name
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
