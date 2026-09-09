import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/activity_details/activity_bloc/post_activity_bloc.dart';
import '../screens/activity_details/activity_bloc/post_activity_event.dart';
import '../screens/activity_details/activity_bloc/post_activity_state.dart';
import '../utils/color_constants.dart';
import '../utils/string_constants.dart';
import 'checkbox_cubic.dart';

class MarkAsCompleteCheckbox extends StatelessWidget {
  final String activityId;
  final String videoTimestamp;
  final String totalVideoTime;
  final bool isChecked;

  const MarkAsCompleteCheckbox({
    Key? key,
    required this.activityId,
    required this.videoTimestamp,
    required this.totalVideoTime,
    required this.isChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostActivityBloc, PostActivityState>(
      listener: (context, state) {
        if (state is PostActivitySuccess && state.isCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                Strings.markedAsComplete,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              backgroundColor: ColorCodes.settingDarkContainer,
            ),
          );
        } else if (state is PostActivityFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed: ${state.error}"),
              backgroundColor: ColorCodes.buttoncolor,
            ),
          );
        }
      },
      child: BlocBuilder<CheckboxCubit, Set<String>>(
        builder: (context, completedSet) {
          final bool isComplete =
              completedSet.contains(activityId) || isChecked;

          return Row(
            children: [
              Transform.scale(
                scale: 1.1,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: ColorCodes.greyColor,
                  ),
                  child: Checkbox(
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: const BorderSide(
                      color: ColorCodes.canceltextcolor,
                      width: 1.5,
                    ),
                    activeColor: ColorCodes.settingDarkContainer,
                    checkColor: ColorCodes.whitecolor,
                    value: isComplete,
                    onChanged: (value) {
                      context
                          .read<CheckboxCubit>()
                          .toggleCheckbox(activityId, value!);

                      if (value) {
                        context.read<PostActivityBloc>().add(
                              MarkActivityComplete(
                                activityId: activityId,
                                videoTimestamp: videoTimestamp,
                                totalVideoTime: totalVideoTime,
                                isCompleted: true,
                              ),
                            );
                      }
                    },
                  ),
                ),
              ),
              Text(
                isComplete ? Strings.markedAsComplete : Strings.markAsComplete,
                style: const TextStyle(
                  color: ColorCodes.canceltextcolor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  fontFamily: Fonts.body,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
