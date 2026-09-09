import 'package:flutter/material.dart';

import '../../utils/image_constants.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          ImageConstants.mainPageImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
