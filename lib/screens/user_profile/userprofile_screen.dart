import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/urls.dart';
import '../edit_profile/edit_profile.dart';
import 'user_model.dart';
import 'userprofile_bloc/user_profile_bloc.dart';
import 'userprofile_bloc/user_profile_event.dart';
import 'userprofile_bloc/user_profile_state.dart';

class UserprofileScreen extends StatelessWidget {
  const UserprofileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserProfileBloc()..add(FetchUserProfile()),
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: SafeArea(
          child: BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {
              if (state is UserProfileLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is UserProfileLoaded) {
                final user = (state.user.name.isEmpty ||
                        state.user.email.isEmpty ||
                        state.user.id.isEmpty ||
                        state.user.provider.isEmpty)
                    ? UserModel(
                        id: 'dummy-id-123',
                        name: 'Test User',
                        email: 'testuser@example.com',
                        provider: 'test_provider',
                      )
                    : state.user;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppbar(
                        headingTxt: Strings.profile,
                        okimage: SvgPicture.asset(ImageConstants.editIcon),
                        onOkTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserprofileEditScreen(
                                name: user.name,
                                email: user.email,
                                image: user.image,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 35),
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: (user.image != null &&
                                      user.image!.isNotEmpty)
                                  ? NetworkImage(
                                      "${Urls.baseUrlimages}${user.image!}")
                                  : const AssetImage(ImageConstants.userProfile)
                                      as ImageProvider,
                              backgroundColor: ColorCodes.grey300Color,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                letterSpacing: Fonts.headingLetterSpacing,
                                fontFamily: Fonts.heading,
                                color: ColorCodes.mainheadingcolor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          Strings.accountDetails,
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
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ColorCodes.whitecolor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: ColorCodes.whiteNewReplacement),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(Strings.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: Fonts.body,
                                      color: ColorCodes.selecteddatetextcolor,
                                    )),
                                Text(user.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: Fonts.body,
                                      color: ColorCodes.mainheadingcolor,
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(Strings.emailAddress,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: Fonts.body,
                                      color: ColorCodes.selecteddatetextcolor,
                                    )),
                                Text(user.email,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: Fonts.body,
                                      color: ColorCodes.mainheadingcolor,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is UserProfileError) {
                return Center(child: Text("Error: ${state.message}"));
              }

              return Center(child: Text(Strings.somethingWentWrong));
            },
          ),
        ),
      ),
    );
  }
}
