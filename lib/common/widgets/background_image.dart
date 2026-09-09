import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;

  const BackgroundScaffold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/new-sigin_bg.png',
              fit: BoxFit.cover,
            ),
          ),

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
