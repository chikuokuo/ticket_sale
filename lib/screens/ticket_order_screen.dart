import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';

class TicketOrderScreen extends StatefulWidget {
  const TicketOrderScreen({super.key});

  @override
  State<TicketOrderScreen> createState() => _TicketOrderScreenState();
}

class _TicketOrderScreenState extends State<TicketOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final double _adultTicketPrice = 23.5;
  final double _childTicketPrice = 2.5;
  List<Attendee> _attendees = [Attendee()];

  final _lastFiveDigitsController = TextEditingController();
  final _customerEmailController = TextEditingController();
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;

  void _addAttendee() {
    setState(() {
      _attendees.add(Attendee());
    });
  }

  void _removeAttendee(int index) {
    // dispose controllers before removing
    _attendees[index].givenNameController.dispose();
    _attendees[index].familyNameController.dispose();
    setState(() {
      _attendees.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now().add(const Duration(days: 2)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
        return;
      }
      if (_selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot (AM/PM)')),
        );
        return;
      }

      final int adultCount = _attendees.where((a) => a.type == AttendeeType.adult).length;
      final int childCount = _attendees.where((a) => a.type == AttendeeType.child).length;
      final double totalAmount = (adultCount * _adultTicketPrice) + (childCount * _childTicketPrice);

      final String lastFive = _lastFiveDigitsController.text;
      final String customerEmail = _customerEmailController.text;
      final String date = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final String timeSlot = _selectedTimeSlot == TimeSlot.am ? 'Morning' : 'Afternoon';

      final String attendeesDetails = _attendees.map((a) {
        final type = a.type == AttendeeType.adult ? 'Adult' : 'Child';
        return '- ${a.givenNameController.text} ${a.familyNameController.text} ($type)';
      }).join('\n');

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'chikuokuo@msn.com',
        query: _encodeQueryParameters(<String, String>{
          'subject': 'Ticket Order for Neuschwanstein Castle',
          'body': '''
Hello,

Here are my order details:
Customer Email: $customerEmail
Date: $date ($timeSlot)
Number of Tickets: ${_attendees.length} (Adults: $adultCount, Children: $childCount)
Total Amount: €$totalAmount
Last 5 digits of bank account: $lastFive

Attendees:
$attendeesDetails

Thank you.
''',
        }),
      );

      try {
        await launchUrl(emailLaunchUri);
        
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order submitted successfully!')),
        );

        // Reset the form
        _lastFiveDigitsController.clear();
        _customerEmailController.clear();
        setState(() {
          for (var attendee in _attendees) {
            attendee.givenNameController.dispose();
            attendee.familyNameController.dispose();
          }
          _attendees = [Attendee()];
          _selectedDate = null;
          _selectedTimeSlot = null;
        });
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch email client: $e')),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  void dispose() {
    for (var attendee in _attendees) {
      attendee.givenNameController.dispose();
      attendee.familyNameController.dispose();
    }
    _lastFiveDigitsController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int adultCount = _attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = _attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = (adultCount * _adultTicketPrice) + (childCount * _childTicketPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuschwanstein Castle Ticket'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                  'Ticket Price: €$_adultTicketPrice (Adult), €$_childTicketPrice (Child)',
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
                    '(${_attendees.length} people)',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey),
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
                        _selectedDate == null
                            ? 'No date chosen'
                            : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
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
                      groupValue: _selectedTimeSlot,
                      onChanged: (TimeSlot? value) {
                        setState(() { _selectedTimeSlot = value; });
                      },
                    ),
                    const Text('AM'),
                    Radio<TimeSlot>(
                      value: TimeSlot.pm,
                      groupValue: _selectedTimeSlot,
                      onChanged: (TimeSlot? value) {
                        setState(() { _selectedTimeSlot = value; });
                      },
                    ),
                    const Text('PM'),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customerEmailController,
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
                  controller: _lastFiveDigitsController,
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
                  itemCount: _attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = _attendees[index];
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
                                if (_attendees.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () => _removeAttendee(index),
                                  ),
                              ],
                            ),
                            TextFormField(
                              controller: attendee.givenNameController,
                              decoration: const InputDecoration(labelText: 'Given Name'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a given name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: attendee.familyNameController,
                              decoration: const InputDecoration(labelText: 'Family Name'),
                               validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a family name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<AttendeeType>(
                              value: attendee.type,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: AttendeeType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    attendee.type = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addAttendee,
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
                    onPressed: _submitOrder,
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
