import 'package:flutter/material.dart';

class AlarmInputField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final bool obscureText;

  const AlarmInputField({
    super.key,
    required this.labelText,
    this.hintText = '',
    this.controller,
    this.autofocus = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
  });

  @override
  State<AlarmInputField> createState() => _AlarmInputFieldState();
}

class _AlarmInputFieldState extends State<AlarmInputField> {
  late TextEditingController _internalController; // 위젯 내부에서 관리할 컨트롤러

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant AlarmInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _internalController.dispose();
      }
      _internalController = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextField(
        controller: _internalController,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        // 값이 변경될 때마다 외부 콜백 호출
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(), // 외곽선 테두리
        ),
      ),
    );
  }
}
