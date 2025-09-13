import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';
import '../providers/ticket_order_provider.dart';
import '../widgets/attendee_card.dart';

// 1. Convert StatefulWidget to ConsumerWidget
class TicketOrderScreen extends ConsumerWidget {
  const TicketOrderScreen({super.key});

  // Helper method to reduce nesting in the build method
  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(ticketOrderProvider.notifier);
    final selectedDate = ref.read(ticketOrderProvider).selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now().add(const Duration(days: 2)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      notifier.selectDate(picked);
    }
  }

  // 2. The build method now receives a WidgetRef
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Watch the provider to get the current state
    final orderState = ref.watch(ticketOrderProvider);
    final orderNotifier = ref.read(ticketOrderProvider.notifier);
    
    final int adultCount = orderState.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = orderState.attendees.where((a) => a.type == AttendeeType.child).length;
    final double adultPrice = 23.5;
    final double childPrice = 2.5;
    final double totalAmount = (adultCount * adultPrice) + (childCount * childPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuschwanstein Castle Ticket'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // 4. The Form now uses the key from the state
          child: Form(
            key: orderState.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Bank Transfer Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Account: 1234-5678-9999', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text(
                  'Ticket Price: €$adultPrice (Adult), €$childPrice (Child)',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Total: €${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                Center(
                  child: Text(
                    '(${orderState.attendees.length} people)',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Your Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        orderState.selectedDate == null
                            ? 'No date chosen'
                            : 'Date: ${DateFormat('yyyy-MM-dd').format(orderState.selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      // 5. UI events now call methods on the notifier
                      onPressed: () => _selectDate(context, ref),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    const Text('Time Slot: '),
                    Radio<TimeSlot>(
                      value: TimeSlot.am,
                      groupValue: orderState.selectedTimeSlot,
                      onChanged: (value) => orderNotifier.selectTimeSlot(value),
                    ),
                    const Text('AM'),
                    Radio<TimeSlot>(
                      value: TimeSlot.pm,
                      groupValue: orderState.selectedTimeSlot,
                      onChanged: (value) => orderNotifier.selectTimeSlot(value),
                    ),
                    const Text('PM'),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: orderState.customerEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: orderState.lastFiveDigitsController,
                  decoration: const InputDecoration(
                    labelText: 'Last 5 digits of your account',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the last 5 digits';
                    }
                    if (value.length != 5) {
                      return 'Must be exactly 5 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Attendees:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: orderState.attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = orderState.attendees[index];
                    return AttendeeCard(
                      attendee: attendee,
                      index: index,
                      canRemove: orderState.attendees.length > 1,
                      onRemove: () => orderNotifier.removeAttendee(index),
                      onTypeChanged: (value) {
                        if (value != null) {
                          orderNotifier.updateAttendeeType(index, value);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: orderNotifier.addAttendee,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Person'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Show snackbar if date/time is not selected
                      if (orderState.selectedDate == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Please select a date')),
                         );
                         return;
                      }
                      if (orderState.selectedTimeSlot == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Please select a time slot (AM/PM)')),
                         );
                         return;
                      }
                      orderNotifier.submitOrder().catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch email client: $e')),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
