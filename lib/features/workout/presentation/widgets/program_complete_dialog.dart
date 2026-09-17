import 'package:flutter/material.dart';

/// Dialog shown when user completes the final day of their program.
/// 
/// Offers options to restart the program or generate a new one.
/// 
/// **Validates: Requirements 13.1, 13.2**
class ProgramCompleteDialog extends StatelessWidget {
  final String programName;
  final VoidCallback onRestart;
  final VoidCallback onGenerateNew;
  
  const ProgramCompleteDialog({
    required this.programName,
    required this.onRestart,
    required this.onGenerateNew,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Program Complete!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.celebration,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'You\'ve completed $programName!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to do next?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRestart();
          },
          child: const Text('Restart Program'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onGenerateNew();
          },
          child: const Text('Generate New Program'),
        ),
      ],
    );
  }
}
