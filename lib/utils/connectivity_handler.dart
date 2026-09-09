import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'color_constants.dart';

class ConnectivityHandler extends StatefulWidget {
  final Widget child;

  const ConnectivityHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<ConnectivityHandler> createState() => _ConnectivityHandlerState();
}

class _ConnectivityHandlerState extends State<ConnectivityHandler> {
  late StreamSubscription _subscription;
  bool _hasShownSnackbar = false;

  @override
  void initState() {
    super.initState();
    _subscription =
        Connectivity().onConnectivityChanged.listen((_) => _checkConnection());
    _checkConnection(); // initial check
  }

  Future<void> _checkConnection() async {
    bool hasInternet = await InternetConnectionChecker().hasConnection;
    if (!hasInternet && !_hasShownSnackbar) {
      _hasShownSnackbar = true;
      _showSnackbar("Please check your internet connection");
    } else if (hasInternet) {
      _hasShownSnackbar = false;
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorCodes.buttoncolor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
