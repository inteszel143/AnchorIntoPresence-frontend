import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/activity_details/activity_bloc/post_activity_bloc.dart';
import '../screens/activity_details/activity_bloc/post_activity_event.dart';
import '../screens/activity_details/activity_bloc/post_activity_state.dart';
import '../utils/string_constants.dart';

class MarkAsCompleteCheckbox extends StatefulWidget {
  final String activityId;
  final String videoTimestamp;
  final String totalVideoTime;
  final bool isChecked;
  final bool enabled;

  const MarkAsCompleteCheckbox({
    super.key,
    required this.activityId,
    required this.videoTimestamp,
    required this.totalVideoTime,
    required this.isChecked,
    this.enabled = true,
  });

  @override
  State<MarkAsCompleteCheckbox> createState() => _MarkAsCompleteCheckboxState();
}

class _MarkAsCompleteCheckboxState extends State<MarkAsCompleteCheckbox> {
  bool _saved = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PostActivityBloc, PostActivityState>(
        listener: (context, state) {
          if (!_saving) return;
          if (state is PostActivitySuccess &&
              state.isCompleted &&
              state.response.data.activityId == widget.activityId) {
            setState(() {
              _saved = true;
              _saving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Practice saved. You can find it in Track.')),
            );
          } else if (state is PostActivityFailure && state.isCompletion) {
            setState(() => _saving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Could not save your practice: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          final complete = _saved || widget.isChecked;
          return Row(children: [
            Checkbox(
              value: complete,
              onChanged: !widget.enabled ||
                      complete ||
                      _saving ||
                      state is PostActivitySubmitting
                  ? null
                  : (value) {
                      if (value != true) return;
                      setState(() => _saving = true);
                      context.read<PostActivityBloc>().add(MarkActivityComplete(
                            activityId: widget.activityId,
                            videoTimestamp: widget.videoTimestamp,
                            totalVideoTime: widget.totalVideoTime,
                            isCompleted: true,
                          ));
                    },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              activeColor: Theme.of(context).colorScheme.primary,
              checkColor: Theme.of(context).colorScheme.onPrimary,
            ),
            Expanded(
                child: Text(
              _saving
                  ? 'Saving your practice…'
                  : complete
                      ? Strings.markedAsComplete
                      : Strings.markAsComplete,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            )),
          ]);
        },
      );
}
