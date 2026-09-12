import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;

  const BackgroundScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AppScaffold(
      body: Stack(
        children: [

          // Foreground content
          SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight,
              ),
              child: IntrinsicHeight(
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
