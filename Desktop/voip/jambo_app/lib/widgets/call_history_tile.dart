import 'package:flutter/material.dart';
import '../models/call_log.dart';
import '../utils/call_utils.dart';

class CallHistoryTile extends StatelessWidget {
  final CallLog callLog;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const CallHistoryTile({
    Key? key,
    required this.callLog,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getCallStatusColor(),
        child: Icon(
          _getCallStatusIcon(),
          color: Colors.white,
        ),
      ),
      title: Text(
        CallUtils.formatPhoneNumber(callLog.number),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${callLog.timestamp.day}/${callLog.timestamp.month}/${callLog.timestamp.year} '
            '${callLog.timestamp.hour}:${callLog.timestamp.minute.toString().padLeft(2, '0')}',
          ),
          Text(
            'Durée: ${CallUtils.formatDuration(callLog.duration)}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            const Icon(Icons.check_circle, color: Colors.blue)
          else
            Icon(
              Icons.phone,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Color _getCallStatusColor() {
    switch (callLog.status) {
      case 'connected':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'missed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCallStatusIcon() {
    switch (callLog.status) {
      case 'connected':
        return callLog.type == 'outgoing'
            ? Icons.call_made
            : Icons.call_received;
      case 'failed':
        return Icons.call_end;
      case 'missed':
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }
}
