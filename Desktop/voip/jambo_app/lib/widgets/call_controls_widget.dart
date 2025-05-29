import 'package:flutter/material.dart';

class CallControlsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isSpeakerOn;
  final VoidCallback onMutePressed;
  final VoidCallback onSpeakerPressed;
  final VoidCallback onEndCall;
  final VoidCallback? onKeypadPressed;

  const CallControlsWidget({
    Key? key,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.onMutePressed,
    required this.onSpeakerPressed,
    required this.onEndCall,
    this.onKeypadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.mic_off,
                label: 'Muet',
                isActive: isMuted,
                onPressed: onMutePressed,
                activeColor: Colors.red,
              ),
              _buildControlButton(
                icon: Icons.volume_up,
                label: 'Haut-parleur',
                isActive: isSpeakerOn,
                onPressed: onSpeakerPressed,
                activeColor: Colors.blue,
              ),
              if (onKeypadPressed != null)
                _buildControlButton(
                  icon: Icons.dialpad,
                  label: 'Clavier',
                  onPressed: onKeypadPressed!,
                ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onEndCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24),
            ),
            child: const Icon(Icons.call_end, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    Color activeColor = Colors.blue,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? activeColor : Colors.grey[300],
            foregroundColor: isActive ? Colors.white : Colors.black54,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? activeColor : Colors.black54,
          ),
        ),
      ],
    );
  }
}
