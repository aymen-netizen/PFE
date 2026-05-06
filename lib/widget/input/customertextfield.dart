import 'package:flutter/material.dart';

class Customertextfield extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Icon? perfixIcon;
  final Icon? suffixIcon;
  final VoidCallback? onPressed;
  final bool enabled;

  const Customertextfield({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.isPassword,
    this.validator,
    this.perfixIcon,
    this.suffixIcon,
    this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<Customertextfield> createState() => _CustomertextfieldState();
}

class _CustomertextfieldState extends State<Customertextfield> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      validator: widget.validator,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.perfixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() => _obscure = !_obscure);
                },
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
        border: const OutlineInputBorder(),
        // Fields look visually different when disabled
        filled: !widget.enabled,
        fillColor: widget.enabled ? null : Colors.grey[100],
      ),
    );
  }
}