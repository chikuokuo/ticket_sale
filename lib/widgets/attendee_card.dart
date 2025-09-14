import 'package:flutter/material.dart';
import '../models/attendee.dart';
import '../theme/colors.dart';

class AttendeeCard extends StatelessWidget {
  final Attendee attendee;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<AttendeeType?> onTypeChanged;

  const AttendeeCard({
    super.key,
    required this.attendee,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Person ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (canRemove)
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: AppColorScheme.error),
                    onPressed: onRemove,
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: attendee.givenNameController,
                    decoration: const InputDecoration(
                      labelText: 'Given Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a given name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: attendee.familyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Family Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a family name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AttendeeType>(
              value: attendee.type,
              items: AttendeeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: onTypeChanged,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
