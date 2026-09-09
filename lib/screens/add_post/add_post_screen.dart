import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindfully_evolve_app/screens/add_post/add_post_bloc/add_post_bloc.dart';
import 'package:mindfully_evolve_app/screens/add_post/add_post_bloc/add_post_state.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:mindfully_evolve_app/utils/global.dart';

import '../../utils/image_constants.dart';
import '../../utils/urls.dart';
import '../community/community_screen.dart';
import 'add_post_bloc/add_post_event.dart';

// Screen for creating and submitting a new community post.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final List<String> postTypes = ["Reflection", "Questions", "Encouragement"];
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool isAnonymous = false;
  List<String> selectedImages = [];
  int selectedPostIndex = 0;
  final int maxLength = 500;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(),
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: SafeArea(
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              int selectedPostIndex = 0;
              if (state is PostTypeChanged) {
                selectedPostIndex = state.selectedPostTypeIndex;
              } else if (state is PostInitial) {
                selectedPostIndex = 0;
              }
              if (state is PostCreating) {
                return _buildLoadingState();
              } else if (state is PostCreated) {
                Future.delayed(Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Post created successfully!'),
                    backgroundColor: ColorCodes.buttoncolor,
                  ));
                  _resetForm();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CommunityScreen()),
                  );
                });
              } else if (state is PostError) {
                Future.delayed(Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: ColorCodes.buttoncolor,
                    ),
                  );
                  _resetForm();
                });
                return _buildPostFormUI(context);
              }

              return _buildPostFormUI(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

// Clears the post form after successful or failed submission.
  void _resetForm() {
    messageController.clear();
    selectedImages.clear();
    isAnonymous = false;
  }

// Builds the post creation form with message, image, and submission options.
  Widget _buildPostFormUI(BuildContext context) {
    return Container(
      color: ColorCodes.whiteNewReplacement,
      margin: const EdgeInsets.only(top: 50),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(''),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorCodes.containerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(''),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: Fonts.body,
                            color: Color(0xff0E1A2B)))),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          userImage != null && userImage!.isNotEmpty
                              ? NetworkImage('${Urls.baseUrlimages}$userImage')
                              : const AssetImage(ImageConstants.userProfile)
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Text(userName,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: Fonts.body)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text("What do you want to talk about?",
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Message",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: Fonts.body)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorCodes.descriptionColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    maxLines: 6,
                    controller: messageController,
                    maxLength: maxLength,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          "Share your thoughts, reflections, or questions with the community...",
                      hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: Fonts.body,
                          color: Color(0xff808080)),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                    "${messageController.text.length}/${maxLength - messageController.text.length} characters",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff51585C))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          buildActionTile(
            title: "Add Photo",
            subtitle: "Share an image with your post",
            imagePath: ImageConstants.coloredCameraIcon,
            onTap: () => showProfileImageDialog(context),
          ),
          if (selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(selectedImages[0])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImages.clear();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  String message = messageController.text.trim();
                  bool postAnonymously = isAnonymous;
                  List<String> images = selectedImages;
                  String postType = postTypes[selectedPostIndex];

                  if (message.isEmpty && images.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add a message or photo'),
                        backgroundColor: ColorCodes.buttoncolor,
                      ),
                    );
                    return;
                  }

                  context.read<PostBloc>().add(CreatePostEvent(
                        message: message,
                        postType: postType,
                        postAnonymously: postAnonymously,
                        imagePaths: images.isEmpty ? null : images,
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorCodes.buttoncolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text("Post",
                    style: TextStyle(
                        fontSize: 18,
                        color: ColorCodes.blackcolor,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Provides options for selecting a post image from the camera or gallery.
  void showProfileImageDialog(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: ColorCodes.whiteNewReplacement,
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
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Divider(height: 1, color: Colors.grey.shade200),
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
                              setState(() {
                                selectedImages = [picked.path];
                              });
                            }
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            width: 130,
                            height: 97,
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: ColorCodes.backgroundcolor,
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
                            // Captures an image using the device camera.
                            final picked = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (picked != null) {
                              setState(() {
                                selectedImages = [picked.path];
                              });
                            }
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            width: 130,
                            height: 97,
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: ColorCodes.backgroundcolor,
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

// Reusable action tile for post options such as adding an image or enabling post settings.
  Widget buildActionTile({
    required String title,
    required String subtitle,
    required String imagePath,
    VoidCallback? onTap,
    bool isAnonymousPost = false,
    bool? value,
    ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ColorCodes.descriptionColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Image.asset(imagePath,
                  width: 26, height: 26, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: Fonts.body)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff51585C))),
                  ],
                ),
              ),
              isAnonymousPost
                  ? Switch(
                      value: value ?? false,
                      onChanged: onChanged,
                      activeThumbColor: Colors.blue,
                    )
                  : Image.asset('assets/images/forward_arrow_icon.png'),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable button for selecting the type of community post.
class PostTypeButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedPostIndex;
  final Function(int) onTap;

  const PostTypeButton({
    super.key,
    required this.label,
    required this.index,
    required this.selectedPostIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedPostIndex == index;

    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.5, vertical: 7.25),
        decoration: BoxDecoration(
          color:
              isSelected ? ColorCodes.buttoncolor : ColorCodes.transparentcolor,
          border: Border.all(
            color: isSelected
                ? ColorCodes.lightDescriptionColor
                : ColorCodes.lightDescriptionColor,
          ),
          borderRadius: BorderRadius.circular(5.8),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected ? ColorCodes.whitecolor : ColorCodes.blackcolor,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              letterSpacing: Fonts.headingLetterSpacing,
              fontFamily: Fonts.heading),
        ),
      ),
    );
  }
}
