import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/color_constants.dart';
import '../utils/image_constants.dart';
import '../utils/urls.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final File? pickedImage;
  final void Function(File?) onImagePicked;

  const ProfileImagePicker({
    Key? key,
    required this.imageUrl,
    required this.pickedImage,
    required this.onImagePicked,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onImagePicked(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (pickedImage != null) {
      imageProvider = FileImage(pickedImage!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage("${Urls.baseUrlimages}$imageUrl!");
    } else {
      imageProvider = const AssetImage(ImageConstants.profilePic);
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: imageProvider,
            backgroundColor: ColorCodes.grey300Color,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: ColorCodes.whitecolor,
                child: ClipOval(
                  child: Image.asset(
                    ImageConstants.uploadIcon,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
