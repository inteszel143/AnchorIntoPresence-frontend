import 'package:flutter/foundation.dart';

/// Signals a confirmed server save, without retaining any user's activity data.
final activityLogRevision = ValueNotifier<int>(0);
