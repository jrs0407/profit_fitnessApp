import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEmail;
  final bool isPhone;

  const ProfileTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.isEmail = false,
    this.isPhone = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey[850]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : isPhone
                    ? TextInputType.phone
                    : TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              if (isEmail && !value.contains('@')) {
                return 'Introduce un email válido';
              }
              if (isPhone && value.length < 8) {
                return 'Introduce un teléfono válido';
              }
              return null;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: Icon(
                isEmail
                    ? Icons.email_outlined
                    : isPhone
                        ? Icons.phone_outlined
                        : Icons.person_outline,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }
}