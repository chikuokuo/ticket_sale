import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  // This is needed to trust self-signed certificates in development.
  // DO NOT USE in production.
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  // Your Stripe publishable key is set here.
  Stripe.publishableKey = 'pk_test_51S6oar2Z7txq4ZPOJ5dfijly6A17SUoXDsx9nK0JheaNo8XjLAMsLqLbm4fodqNdnD3XpB7S7c9TPFMlb8ZoXz9000Z5Wj34b6';
  
  await Stripe.instance.applySettings();
  
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


enum AttendeeType { adult, child }

enum TimeSlot { am, pm }

class Attendee {
  final TextEditingController givenNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  AttendeeType type = AttendeeType.adult;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuschwanstein Castle Ticket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TicketOrderScreen(),
    );
  }
}

class TicketOrderScreen extends StatefulWidget {
  const TicketOrderScreen({super.key});

  @override
  State<TicketOrderScreen> createState() => _TicketOrderScreenState();
}

class _TicketOrderScreenState extends State<TicketOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final double _ticketPrice = 23.5;
  List<Attendee> _attendees = [Attendee()];

  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  bool _isProcessingPayment = false;

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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handlePayAndSubmit() async {
    if (_isProcessingPayment) return; // Prevent double taps
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // 1. Create payment intent on your server
      final clientSecret = await _createPaymentIntent();
      if (clientSecret == null) {
        // Error is already shown in the function
        setState(() { _isProcessingPayment = false; });
        return;
      }

      // 2. Present the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Neuschwanstein Tickets',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // 3. Payment successful, now submit the order to your server
      await _submitOrderToServer();

    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.error.localizedMessage}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  Future<String?> _createPaymentIntent() async {
    try {
      final totalAmount = _attendees.length * _ticketPrice;
      // Convert to smallest currency unit (cents)
      final amountInCents = (totalAmount * 100).toInt();

      final url = Uri.parse('https://192.168.24.108:44372/create-payment-intent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountInCents,
          'currency': 'eur',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['clientSecret'];
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create payment intent. Server responded with ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not connect to payment server: $e')),
      );
      return null;
    }
  }

  Future<void> _submitOrderToServer() async {
    final String date = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final String timeSlot = _selectedTimeSlot == TimeSlot.am ? 'AM' : 'PM';
    
    final attendeesList = _attendees.map((a) {
      return {
        'givenName': a.givenNameController.text,
        'familyName': a.familyNameController.text,
        'type': a.type.name,
      };
    }).toList();

    final body = jsonEncode({
      'date': date,
      'timeSlot': timeSlot,
      'attendees': attendeesList,
    });

    const String url = 'https://172.20.10.3:44372/Order';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    // ignore: use_build_context_synchronously
    if (!context.mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted successfully!')),
      );

      // Reset the form
      setState(() {
        for (var attendee in _attendees) {
          attendee.givenNameController.dispose();
          attendee.familyNameController.dispose();
        }
        _attendees = [Attendee()];
        _selectedDate = null;
        _selectedTimeSlot = null;
      });
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment was successful, but failed to save order. Status code: ${response.statusCode}')),
      );
    }
  }

  // This function is no longer needed as we are not using mailto links anymore.
  // String? _encodeQueryParameters(Map<String, String> params) {
  //   return params.entries
  //       .map((MapEntry<String, String> e) =>
  //           '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
  //       .join('&');
  // }

  @override
  void dispose() {
    for (var attendee in _attendees) {
      attendee.givenNameController.dispose();
      attendee.familyNameController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = _attendees.length * _ticketPrice;

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
                  'Order Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ticket Price: €$_ticketPrice per person',
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
                    onPressed: _handlePayAndSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: _isProcessingPayment
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pay €${totalAmount.toStringAsFixed(2)} with Stripe',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
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
