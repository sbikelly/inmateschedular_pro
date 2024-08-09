

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static const cardBackgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const mainColor = Color(0xFF63CF93); // hex equivalent #63CF93
  static const backgroundColor = Color.fromARGB(255, 242, 243, 226);

  static Future<void> selectDate(BuildContext context, Function(String?) onDateSelected) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        onDateSelected(DateFormat('yyyy-MM-dd').format(picked));
      } else {
        onDateSelected(null); // No date selected
      }
    } catch (e) {
      debugPrint('Error selecting date: $e');
      onDateSelected(null); // Handle error case
    }
  }

  static Future<void> selectPhoto(Function(String?) onPhotoSelected) async {
    try {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          if (file.size > 1048487 ) {
            debugPrint('File size exceeds limit');
            onPhotoSelected(null); // Handle error case
            return;
          }
          final reader = html.FileReader();
          reader.readAsDataUrl(file);
          reader.onLoadEnd.listen((e) {
            onPhotoSelected(reader.result as String?);
          });
        } else {
          onPhotoSelected(null); // No file selected
        }
      });
    } catch (e) {
      debugPrint('Error selecting photo: $e');
      onPhotoSelected(null); // Handle error case
    }
  }
}
