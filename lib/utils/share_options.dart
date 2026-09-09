import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'image_constants.dart';

class ShareUtils {
  static Future<void> shareImageViaSmsAndroid(String imagePath) async {
    try {
      // Get the file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(imagePath);

      // Check if the file exists
      if (!await file.exists()) {
        return;
      }

      // Create the URI using FileProvider
      final uri = Uri.parse(
          'content://com.mediation.mindfullyevolve.mindfully_evolve_app.provider/external_files/${file.uri.pathSegments.last}');

      // Create and launch the intent
      final intent = AndroidIntent(
        action: 'android.intent.action.SEND',
        type: 'image/*',
        package: 'com.google.android.apps.messaging', // Target Messaging app
        arguments: <String, dynamic>{
          'android.intent.extra.STREAM': uri.toString(),
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK], // Flag to open in new task
      );

      await intent.launch();
    } catch (e) {}
  }

  static Future<void> shareImageViaSms(XFile imageFile) async {
    if (Platform.isAndroid) {
      await shareImageViaSmsAndroid(imageFile.path);
    } else {
      // iOS → Share via share sheet
      await Share.shareXFiles([imageFile], text: 'Today’s Daily Pause');
    }
  }

  static void showShareOptionsWithImage(BuildContext context, XFile imageFile) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share Via',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // WhatsApp
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Share.shareXFiles([imageFile]);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(ImageConstants.whatsappIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          const Text(
                            'WhatsApp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Facebook
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Share.shareXFiles([imageFile]);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(ImageConstants.facebookIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          const Text(
                            'Facebook',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Instagram
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Share.shareXFiles([imageFile]);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(ImageConstants.instaIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          const Text(
                            'Instagram',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Twitter
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Share.shareXFiles([imageFile]);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(ImageConstants.twitterIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          const Text(
                            'Twitter',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Messages / SMS
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await shareImageViaSms(imageFile);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.message,
                            size: 46,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Messages',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static void showShareOptions(
      BuildContext context, String postMessage, String postUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Via',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                child: Row(
                  children: [
                    // WhatsApp Share Button
                    GestureDetector(
                      onTap: () {
                        _sharePost(context, postMessage, postUrl);
                        Navigator.pop(
                            context); // Close the bottom sheet after sharing
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.whatsappIcon,
                              width: 46, height: 46),
                          const SizedBox(width: 10),
                          Text('WhatsApp',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Facebook Share Button
                    GestureDetector(
                      onTap: () {
                        _sharePost(context, postMessage, postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.facebookIcon,
                              width: 46, height: 46),
                          const SizedBox(width: 10),
                          Text('Facebook',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Instagram Share Button
                    GestureDetector(
                      onTap: () {
                        _sharePost(context, postMessage, postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.instaIcon,
                              width: 46, height: 46),
                          const SizedBox(width: 10),
                          Text('Instagram',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Copy Link Button
                    GestureDetector(
                      onTap: () {
                        Share.share(postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.copylinkIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          Text('Copy Link',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Twitter Share Button
                    GestureDetector(
                      onTap: () {
                        Share.share(postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.twitterIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          Text('Twitter',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // A helper method to share the post message, you can keep the implementation or change as needed
  static void _sharePost(BuildContext context, String message, String url) {
    // Custom share logic or you can use any sharing package
    Share.share('$message $url');
  }
}
