import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/widgets/loading_skeleton.dart';
import '../../utils/api_service.dart';
import '../totalmedication/total_meditation_model.dart';

class YourWeekCard extends StatefulWidget {
  const YourWeekCard({super.key, this.load});

  final Future<TotalMeditationDataResponse> Function()? load;

  @override
  State<YourWeekCard> createState() => _YourWeekCardState();
}

class _YourWeekCardState extends State<YourWeekCard> {
  late Future<TotalMeditationDataResponse> _week;

  @override
  void initState() {
    super.initState();
    _week = _load();
  }

  Future<TotalMeditationDataResponse> _load() async {
    final response =
        await (widget.load ?? ApiService.fetchTotalMeditationData)()
            .timeout(const Duration(seconds: 30));
    if (!response.status) throw StateError('Weekly practice is unavailable');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FutureBuilder<TotalMeditationDataResponse>(
          future: _week,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingSkeleton(
                label: 'Loading your week',
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBlock(width: 150, height: 18),
                      SizedBox(height: 16),
                      SkeletonBlock(height: 120),
                    ]),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your week couldn’t load. Please try again.'),
                    TextButton(
                      onPressed: () {
                        final nextWeek = _load();
                        setState(() {
                          _week = nextWeek;
                        });
                      },
                      child: const Text('Try again'),
                    ),
                  ]);
            }
            const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            final values = {
              for (final day in snapshot.data!.data.week)
                day.day: math.max(0, day.value),
            };
            final minutes = [for (final label in labels) values[label] ?? 0];
            final total = minutes.fold<int>(0, (sum, value) => sum + value);
            final maximum = minutes.fold<int>(1, math.max);
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monday–Sunday · Daily minutes',
                      style: text.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  LayoutBuilder(builder: (context, constraints) {
                    final width = math.max(constraints.maxWidth,
                        7 * MediaQuery.textScalerOf(context).scale(34));
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: width,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var index = 0;
                                  index < labels.length;
                                  index++)
                                Expanded(
                                    child: Semantics(
                                  label:
                                      '${labels[index]}: ${minutes[index]} minutes of practice',
                                  child: ExcludeSemantics(
                                      child: Column(children: [
                                    Text('${minutes[index]}',
                                        style: text.labelSmall),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 20,
                                      height: 100,
                                      alignment: Alignment.bottomCenter,
                                      decoration: BoxDecoration(
                                        color: colors.primary
                                            .withValues(alpha: .08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: FractionallySizedBox(
                                        heightFactor: minutes[index] / maximum,
                                        child: Container(
                                            decoration: BoxDecoration(
                                          color: colors.primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(labels[index], style: text.bodySmall),
                                  ])),
                                )),
                            ]),
                      ),
                    );
                  }),
                  if (total == 0) ...[
                    const SizedBox(height: 16),
                    Text('No practice recorded this week yet.',
                        style: text.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ]);
          },
        ),
      ]),
    );
  }
}
