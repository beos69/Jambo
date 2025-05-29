import 'package:flutter/material.dart';
import '../models/call_state.dart';

class CallStatusWidget extends StatelessWidget {
  final CallStateInfo callState;

  const CallStatusWidget({
    Key? key,
    required this.callState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (callState.state) {
      case CallState.calling:
        return Icons.call;
      case CallState.ringing:
        return Icons.phone_in_talk;
      case CallState.connected:
        return Icons.call_connected;
      case CallState.ended:
        return Icons.call_end;
      case CallState.failed:
        return Icons.call_failed;
      default:
        return Icons.call;
    }
  }

  Color _getStatusColor() {
    switch (callState.state) {
      case CallState.calling:
      case CallState.ringing:
        return Colors.orange;
      case CallState.connected:
        return Colors.green;
      case CallState.ended:
        return Colors.blue;
      case CallState.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (callState.state) {
      case CallState.calling:
        return 'Appel en cours...';
      case CallState.ringing:
        return 'Ça sonne...';
      case CallState.connected:
        return 'En communication';
      case CallState.ended:
        return 'Appel terminé';
      case CallState.failed:
        return 'Échec de l\'appel';
      default:
        return 'En attente';
    }
  }
}
