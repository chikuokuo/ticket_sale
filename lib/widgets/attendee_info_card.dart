import 'package:flutter/material.dart';
import '../models/attendee.dart';
import '../theme/app_theme.dart';

class AttendeeInfoCard extends StatelessWidget {
  final List<Attendee> attendees;
  final TextEditingController emailController;

  const AttendeeInfoCard({
    super.key,
    required this.attendees,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendee Information', style: AppTheme.titleLarge),
            const SizedBox(height: 16),
            ...attendees.asMap().entries.map((entry) {
              final index = entry.key;
              final attendee = entry.value;
              final fullName =
                  '${attendee.givenNameController.text} ${attendee.familyNameController.text}'
                      .trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 12),
                    Text(fullName.isNotEmpty ? fullName : 'Attendee ${index + 1}'),
                    const Spacer(),
                    Text(attendee.type == AttendeeType.adult ? 'Adult' : 'Child'),
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 24),
            Text('Contact Information', style: AppTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
