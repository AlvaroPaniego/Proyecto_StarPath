import 'package:flutter/material.dart';

class FontSizeOption extends StatefulWidget {
  const FontSizeOption({super.key});

  @override
  State<FontSizeOption> createState() => _FontSizeOptionState();
}

class _FontSizeOptionState extends State<FontSizeOption> {
  double fontSize = 12;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Tamaño de la fuente: $fontSize"),
        IconButton(onPressed: () {
          setState(() {
            fontSize++;
          });
        }, icon: const Icon(Icons.arrow_upward)),
        IconButton(onPressed: () {
          setState(() {
            fontSize--;
          });
        }, icon: const Icon(Icons.arrow_downward)),
      ],
    );
  }
}
