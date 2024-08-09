import 'package:flutter/material.dart';

// Define a callback function type
typedef DateSelectedCallback = void Function(DateTime? selectedDate);

class DatePicker extends StatefulWidget {
  final DateSelectedCallback? onDateSelected;

  const DatePicker({Key? key, this.onDateSelected}) : super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected?.call(_selectedDate);
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return 
    AlertDialog(
      content: IconButton(
        onPressed: () => _selectDate(context),            
        icon: Icon(Icons.calendar_today_rounded),
      ),
    );
  }
}
