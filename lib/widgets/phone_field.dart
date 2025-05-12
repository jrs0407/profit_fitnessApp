import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: 'Teléfono',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
    );
  }
}