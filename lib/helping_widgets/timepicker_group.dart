import 'package:flutter/cupertino.dart';

import '../utils/color_constants.dart';
import '../utils/fonts.dart';

class TimePickerGroup extends StatelessWidget {
  final int selectedHour;
  final int selectedMinute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const TimePickerGroup({
    super.key,
    required this.selectedHour,
    required this.selectedMinute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 50;
    const double pickerWidth = 80;

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: (250 / 2) - (itemHeight / 2),
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                height: itemHeight,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ColorCodes.whitecolor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour Picker
              SizedBox(
                width: pickerWidth,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedHour),
                  itemExtent: itemHeight,
                  onSelectedItemChanged: onHourChanged,
                  selectionOverlay: Container(),
                  children: List.generate(24, (index) {
                    final isSelected = index == selectedHour;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: isSelected
                              ? ColorCodes.selectedtimepickertextcolor
                              : ColorCodes.timepickertextcolor,
                          fontSize: isSelected ? 28 : 24,
                          fontWeight: FontWeight.w500,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Text(
                ":",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: ColorCodes.selectedtimepickertextcolor,
                  fontFamily: Fonts.body,
                ),
              ),
              // Minute Picker
              SizedBox(
                width: pickerWidth,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedMinute),
                  itemExtent: itemHeight,
                  onSelectedItemChanged: onMinuteChanged,
                  selectionOverlay: Container(),
                  children: List.generate(60, (index) {
                    final isSelected = index == selectedMinute;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: isSelected
                              ? ColorCodes.selectedtimepickertextcolor
                              : ColorCodes.timepickertextcolor,
                          fontSize: isSelected ? 28 : 24,
                          fontWeight: FontWeight.w500,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
