import 'package:flutter/material.dart';

class SafeNav {
  static void goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  static void safeReplace(BuildContext context, Widget screen) {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    } catch (e) {
      goHome(context);
    }
  }

  static void safePush(BuildContext context, Widget screen) {
    try {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } catch (e) {
      goHome(context);
    }
  }
}
