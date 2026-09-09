import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../common/logoutconfirmation_dialog.dart';
import '../utils/color_constants.dart';
import '../utils/string_constants.dart';
import '../utils/fonts.dart';

class SettingItemTile extends StatelessWidget {
  final String iconPath;
  final String option;
  final bool showToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const SettingItemTile({
    Key? key,
    required this.iconPath,
    required this.option,
    this.showToggle = false,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (option == Strings.logout) {
          showLogoutConfirmationDialog(context);
        } else {
          onTap?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: ColorCodes.settingDarkContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorCodes.searchboxcolor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 43.08,
                width: 44,
                decoration: BoxDecoration(
                  color: ColorCodes.settingLightContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(iconPath),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: Fonts.body,
                    color: ColorCodes.mainheadingcolor,
                  ),
                ),
              ),
              if (showToggle && toggleValue != null && onToggle != null)
                FlutterSwitch(
                  width: 50,
                  height: 25,
                  toggleSize: 20,
                  activeColor: ColorCodes.settingLightContainer,
                  inactiveColor: ColorCodes.grey300Color,
                  value: toggleValue!,
                  onToggle: onToggle!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}