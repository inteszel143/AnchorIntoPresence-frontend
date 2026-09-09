import 'package:flutter/material.dart';
import '../utils/color_constants.dart';
import '../utils/fonts.dart';

class FAQItemTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItemTile({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _StatelessFAQTile(
      question: question,
      answer: answer,
    );
  }
}

class _StatelessFAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const _StatelessFAQTile({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isExpanded = false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: ColorCodes.whitecolor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded ? Colors.white : Colors.white,
                width: isExpanded ? 1.5 : 1,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor: ColorCodes.transparentcolor,
                collapsedBackgroundColor: ColorCodes.transparentcolor,
                childrenPadding: EdgeInsets.zero,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide.none,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide.none,
                ),
                title: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: Fonts.body,
                    color: ColorCodes.mainheadingcolor,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                    child: Text(
                      answer,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: Fonts.body,
                        color: ColorCodes.descriptioncolor,
                      ),
                    ),
                  ),
                ],
                onExpansionChanged: (expanded) {
                  setInnerState(() {
                    isExpanded = expanded;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
