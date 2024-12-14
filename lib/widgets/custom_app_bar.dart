import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Remove o botão de retorno
      backgroundColor: backgroundColor,
      title: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centraliza na largura total
        children: [
          Image.asset(
            'android/icons/icons8-nasa-96.png',
            height: 48,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
