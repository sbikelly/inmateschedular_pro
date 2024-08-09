import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const MyCard({super.key, this.color, this.padding, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          color: color ?? Color.fromARGB(31, 58, 30, 30),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12.0),
          child: child,
        ));
  }
}
