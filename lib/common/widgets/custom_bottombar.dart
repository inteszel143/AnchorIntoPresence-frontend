import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';

import '../../utils/color_constants.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const CustomBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": "assets/images/home_icon.svg", "label": "Home"},
      {"icon": "assets/images/community_icon.svg", "label": "Community"},
      {"icon": "assets/images/track_icon.svg", "label": "Track"},
      {"icon": "assets/images/setting_icon.svg", "label": "Settings"},
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: ColorCodes.whiteNewReplacement,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, -1)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final isActive = index == selectedIndex;
            return GestureDetector(
              onTap: () => onItemTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    items[index]['icon']!,
                    //height: 24,
                    color: isActive
                        ? const Color(0xff9C8F84)
                        : const Color(0xff8D8D8D),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: Fonts.body,
                      color: isActive
                          ? const Color(0xff9C8F84)
                          : const Color(0xff8D8D8D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 3,
                    width: 70,
                    decoration: BoxDecoration(
                      color: isActive ? Color(0xff9C8F84) : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
