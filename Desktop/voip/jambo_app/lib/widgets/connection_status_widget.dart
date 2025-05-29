import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onRetry;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Déconnecté du serveur',
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Réessayer',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
