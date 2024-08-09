import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({required String message, required bool err}) {
  Color _color = err ? Colors.red : Colors.green;

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 5,
    backgroundColor: _color,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
