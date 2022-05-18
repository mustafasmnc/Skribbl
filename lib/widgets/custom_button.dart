import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? title;
  final Color? color;
  final VoidCallback? onTap;
  const CustomButton({Key? key, this.title, this.color, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        width: 120,
        decoration: BoxDecoration(
          border: Border.all(color: color!, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Text(
          title!,
          textAlign: TextAlign.center,
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}
