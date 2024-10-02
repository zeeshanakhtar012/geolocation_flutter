import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePickerContainer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final IconData? icon;
  final Color iconColor;
  final double iconSize;
  final BoxShadow? boxShadow;
  final ValueChanged<String>? onImagePicked;

  CustomImagePickerContainer({
    Key? key,
    this.width = 104,
    this.height = 163,
    this.borderRadius = 10,
    this.backgroundColor = Colors.grey,
    this.icon = CupertinoIcons.plus_circle,
    this.iconColor = const Color(0xFFA7713F),
    this.iconSize = 40,
    this.boxShadow,
    this.onImagePicked,
  }) : super(key: key);

  @override
  _CustomImagePickerContainerState createState() => _CustomImagePickerContainerState();
}

class _CustomImagePickerContainerState extends State<CustomImagePickerContainer> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              // ListTile(
              //   leading: Icon(Icons.photo_library),
              //   title: Text('Gallery'),
              //   onTap: () async {
              //     Navigator.of(context).pop();
              //     final pickedFile = await _picker.pickImage(
              //       source: ImageSource.gallery,
              //       maxWidth: 800,
              //       maxHeight: 800,
              //     );
              //     if (pickedFile != null) {
              //       setState(() {
              //         _imageFile = pickedFile;
              //       });
              //       if (widget.onImagePicked != null) {
              //         widget.onImagePicked!(pickedFile.path);
              //       }
              //     }
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = pickedFile;
                    });
                    if (widget.onImagePicked != null) {
                      widget.onImagePicked!(pickedFile.path);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickImage(context),
      child: Container(
        width: widget.width.sp,
        height: widget.height.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: widget.backgroundColor.withOpacity(.4),
        ),
        child: _imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.file(
            File(_imageFile!.path),
            fit: BoxFit.cover,
            width: widget.width.sp,
            height: widget.height.sp,
          ),
        )
            : Center(
          child: Icon(CupertinoIcons.add_circled, color: Colors.white, size: widget.iconSize,),
        ),
      ),
    );
  }
}

