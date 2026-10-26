import 'package:flutter/material.dart';

import '../utils/api_service.dart';
import 'postactivity_checkbox.dart';

/// Reload account completion whenever a practice is opened, rather than
/// depending on the cached library list or a previous screen's checkbox state.
class ActivityCompletionControl extends StatefulWidget {
  const ActivityCompletionControl({
    super.key,
    required this.activityId,
    required this.videoTimestamp,
    required this.totalVideoTime,
    this.enabled = true,
    this.loadCompletion,
  });

  final String activityId;
  final String videoTimestamp;
  final String totalVideoTime;
  final bool enabled;
  final Future<bool> Function(String activityId)? loadCompletion;

  @override
  State<ActivityCompletionControl> createState() => _ActivityCompletionControlState();
}

class _ActivityCompletionControlState extends State<ActivityCompletionControl> {
  late Future<bool> _completion;

  Future<bool> _load() async {
    if (widget.loadCompletion != null) {
      return widget.loadCompletion!(widget.activityId);
    }
    final activity = await ApiService.fetchActivity(widget.activityId)
        .timeout(const Duration(seconds: 30));
    return activity.isCompleted;
  }

  @override
  void initState() {
    super.initState();
    _completion = _load();
  }

  @override
  void didUpdateWidget(covariant ActivityCompletionControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activityId != widget.activityId) _completion = _load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: _completion,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Row(children: [
              SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Expanded(child: Text('Checking your saved practice…')),
            ]);
          }
          if (snapshot.hasError) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Couldn’t check your saved practice. Please try again.'),
              TextButton.icon(
                onPressed: () => setState(() { _completion = _load(); }),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ]);
          }
          return MarkAsCompleteCheckbox(
            key: ValueKey(widget.activityId),
            activityId: widget.activityId,
            videoTimestamp: widget.videoTimestamp,
            totalVideoTime: widget.totalVideoTime,
            isChecked: snapshot.data == true,
            enabled: widget.enabled,
          );
        },
      );
}
