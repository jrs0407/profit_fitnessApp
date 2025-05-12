import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class DatePickerField extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerField({
    Key? key,
    this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar el texto si hay una fecha seleccionada
    if (widget.selectedDate != null) {
      _updateDateText(widget.selectedDate!);
    }
  }

  void _updateDateText(DateTime date) {
    _controller.text = "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    
    if (picked != null) {
      _updateDateText(picked);
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      label: 'Fecha de nacimiento',
      icon: Icons.calendar_today,
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}