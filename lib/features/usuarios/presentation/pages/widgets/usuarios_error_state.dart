import 'package:flutter/material.dart';

class UsuariosErrorState extends StatelessWidget {
  const UsuariosErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SelectableText.rich(
          TextSpan(
            text: message,
            style: const TextStyle(color: Colors.red),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
