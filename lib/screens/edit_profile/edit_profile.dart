import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';

import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/user_provider/user_provider.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../../utils/urls.dart';
import 'editprofile_bloc/edit_profile_bloc.dart';
import 'editprofile_bloc/edit_profile_event.dart';
import 'editprofile_bloc/edit_profile_state.dart';

class UserprofileEditScreen extends StatelessWidget {
  final String name;
  final String email;
  final String? image;

  const UserprofileEditScreen({
    super.key,
    required this.name,
    required this.email,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorCodes.backgroundcolor,
        body: SafeArea(
          child: _UserProfileEditForm(
            initialName: name,
            email: email,
            initialImage: image,
          ),
        ),
      ),
    );
  }
}

class _UserProfileEditForm extends StatelessWidget {
  final String initialName;
  final String email;
  final String? initialImage;

  const _UserProfileEditForm({
    super.key,
    required this.initialName,
    required this.email,
    this.initialImage,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      context.read<EditProfileBloc>().add(ImagePicked(File(picked.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileBloc, EditProfileState>(
      builder: (context, state) {
        final nameController = TextEditingController(
            text: state.name.isNotEmpty ? state.name : initialName);

        return Stack(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                    //  bottom: 100),
                    bottom: MediaQuery.of(context).viewInsets.bottom + 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(headingTxt: Strings.editProfile),
                    const SizedBox(height: 35),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: state.pickedImage != null
                                ? FileImage(state.pickedImage!)
                                : (initialImage != null &&
                                        initialImage!.isNotEmpty)
                                    ? NetworkImage(
                                            "${Urls.baseUrlimages}$initialImage")
                                        as ImageProvider
                                    : const AssetImage(
                                        'assets/images/user_profile.png'),
                            backgroundColor: ColorCodes.grey300Color,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              //onTap: () => _pickImage(context),
                              onTap: () => showProfileImageDialog(context),

                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: ColorCodes.whitecolor,
                                child: ClipOval(
                                  child: Image(
                                    image: AssetImage(
                                        'assets/images/upload_icon.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        state.name.isNotEmpty ? state.name : initialName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: Fonts.headingLetterSpacing,
                          fontFamily: Fonts.heading,
                          color: ColorCodes.mainheadingcolor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        "Account Details",
                        style: TextStyle(
                          color: ColorCodes.mainheadingcolor,
                          fontWeight: FontWeight.w400,
                          letterSpacing: Fonts.headingLetterSpacing,
                          fontFamily: Fonts.heading,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorCodes.whitecolor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  ColorCodes.editprofilecontainerbordercolor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(Strings.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: Fonts.body,
                                    color: ColorCodes.bellefairheadingtextcolor,
                                  )),
                              const SizedBox(height: 10),
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: ColorCodes.whitecolor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: ColorCodes.searchboxcolor),
                                ),
                                child: TextFormField(
                                  //controller: nameController,
                                  initialValue: state.name.isNotEmpty
                                      ? state.name
                                      : initialName,
                                  onChanged: (val) {
                                    context
                                        .read<EditProfileBloc>()
                                        .add(NameChanged(val));
                                  },
                                  scrollPadding: EdgeInsets.only(bottom: 220),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(15),
                                    border: InputBorder.none,
                                    hintText: Strings.name,
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: Fonts.body,
                                      color:
                                          ColorCodes.bellefairheadingtextcolor,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: Fonts.body,
                                    color: ColorCodes.bellefairheadingtextcolor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(Strings.emailAddress,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: Fonts.body,
                                    color: ColorCodes.bellefairheadingtextcolor,
                                  )),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                height: 52,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                decoration: BoxDecoration(
                                  color: ColorCodes.whiteNewReplacement,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: ColorCodes.searchboxcolor),
                                ),
                                child: Text(
                                  email,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: Fonts.body,
                                    fontSize: 14,
                                    color: ColorCodes.bellefairheadingtextcolor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            BlocListener<EditProfileBloc, EditProfileState>(
              listener: (context, state) {
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.successMessage!),
                        backgroundColor: ColorCodes.buttoncolor),
                  );
                  final userProvider = context.read<UserProvider>();
                  userProvider.updateUserProfile(
                      state.name, state.pickedImage?.path ?? "");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MainScreen(
                              initialIndex: 0,
                            )),
                  );
                } else if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.error!),
                        backgroundColor: ColorCodes.buttoncolor),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),
            Positioned(
              left: 23,
              right: 23,
              bottom: 30,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  final updatedName = state.name.trim();
                  context.read<EditProfileBloc>().add(
                        UpdateProfile(
                            name: updatedName, image: state.pickedImage),
                      );
                },
                child: ButtonWidget(
                  btnTxt: state is EditProfileLoading
                      ? Strings.updating
                      : Strings.update,
                  widthFactor: 0.9,
                  height: 52,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showProfileImageDialog(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: ColorCodes.backgroundcolor,
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(),
                    SizedBox(width: 30),
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Select',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontFamily: Fonts.body,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Close dialog
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Divider(height: 1, color: ColorCodes.whiteNewReplacement),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await picker.pickImage(
                                source: ImageSource.camera);
                            if (picked != null) {
                              // Dispatch event to Bloc with picked image file
                              context
                                  .read<EditProfileBloc>()
                                  .add(ImagePicked(File(picked.path)));
                            }
                            Navigator.of(ctx).pop(); // Close dialog
                          },
                          child: Container(
                            width: 130,
                            height: 97,
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: ColorCodes.whiteNewReplacement,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 0.6,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Image.asset(
                                      ImageConstants.cameraIcon,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Camera",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: Fonts.body,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (picked != null) {
                              // Dispatch event to Bloc with picked image file
                              context
                                  .read<EditProfileBloc>()
                                  .add(ImagePicked(File(picked.path)));
                            }
                            Navigator.of(ctx).pop(); // Close dialog
                          },
                          child: Container(
                            width: 130,
                            height: 97,
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: ColorCodes.whiteNewReplacement,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 0.6,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Image.asset(
                                      ImageConstants.gallaryIcon,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Gallery",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: Fonts.body,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
