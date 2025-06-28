// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final double? sizePadding;
  final Color? colorContainer;
  final String? text;
  final bool borderDelete;
  final TextEditingController controller;
  final TextAlign? textAlign;
  final Widget? prefix;
  final Widget? suffix;
  final Function()? suffixPressed;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextDirection? textDirection;
  final Function()? onTap;
  final bool? obscureText;
  final Color? fillColor;
  final Function(String)? onchanged;
  final TextStyle textStyle;
  final TextStyle heintStyle;
  final bool isDense;

  const CustomTextField({
    super.key,
    this.borderDelete = false,
    this.fillColor = Colors.white,
    this.obscureText = true,
    required this.onTap,
    this.textDirection,
    required this.validator,
    this.sizePadding = 10,
    this.keyboardType = TextInputType.text,
    required this.text,
    required this.controller,
    this.textAlign = TextAlign.end,
    this.suffix,
    this.prefix,
    this.suffixPressed,
    this.onchanged,
    this.colorContainer,
    this.isDense = false,
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    this.heintStyle = const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: textStyle,
      obscureText: obscureText!,
      onTap: onTap,
      onChanged: onchanged,
      textDirection: textDirection,
      controller: controller,
      textAlign: textAlign!,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        isDense: isDense,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        suffixIconColor: Colors.grey,
        fillColor: fillColor,
        hintStyle: heintStyle,
        hintText: text,
        filled: true,
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: borderDelete == false
            ? outlineInputBorder1()
            : outlineInputBorderNote(),
        focusedBorder: borderDelete == false
            ? outlineInputBorder2()
            : outlineInputBorderNote(),
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
  }
  //!ده لما تبقي مش focuse

  OutlineInputBorder outlineInputBorder1() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(
        color: Colors.white,
        width: 0.7,
      ),
    );
  }
  //!ده لما تبقي مش focuse

  OutlineInputBorder outlineInputBorderNote() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0.7,
      ),
    );
  }

  //!ده لما تبقي focuse
  OutlineInputBorder outlineInputBorder2() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(
        color: Colors.white,
        width: 0.7,
      ),
    );
  }
}
