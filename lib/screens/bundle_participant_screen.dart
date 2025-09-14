import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bundle_provider.dart';
import '../screens/bundle_order_summary_screen.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

class BundleParticipantScreen extends ConsumerStatefulWidget {
  const BundleParticipantScreen({super.key});

  @override
  ConsumerState<BundleParticipantScreen> createState() => _BundleParticipantScreenState();
}

class _BundleParticipantScreenState extends ConsumerState<BundleParticipantScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, TextEditingController>> _controllers = [];
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final bundleOrder = ref.read(bundleOrderProvider);
    if (bundleOrder.currentOrder != null) {
      _controllers.clear();
      
      for (int i = 0; i < bundleOrder.currentOrder!.participantCount; i++) {
        final participant = i < bundleOrder.currentOrder!.participants.length
            ? bundleOrder.currentOrder!.participants[i]
            : null;
            
        _controllers.add({
          'givenName': TextEditingController(text: participant?.givenName ?? ''),
          'familyName': TextEditingController(text: participant?.familyName ?? ''),
        });
      }
      
      _emailController.text = bundleOrder.currentOrder!.contactEmail;
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final controllerMap in _controllers) {
      for (final controller in controllerMap.values) {
        controller.dispose();
      }
    }
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundleOrder = ref.watch(bundleOrderProvider);
    
    if (bundleOrder.currentOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Participant Information')),
        body: const Center(
          child: Text('No bundle order found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: Text(
          'Participant Information',
          style: AppTheme.headlineSmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorScheme.neutral900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary header
              _buildOrderSummaryHeader(bundleOrder),
              
              const SizedBox(height: 32),
              
              // Participant information
              _buildParticipantSection(bundleOrder),
              
              const SizedBox(height: 32),
              
              // Contact information
              _buildContactSection(),
              
              const SizedBox(height: 40),
              
              // Continue button
              _buildContinueButton(bundleOrder),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryHeader(BundleOrderState bundleOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bundleOrder.currentOrder!.bundle.title,
            style: AppTheme.titleMedium.copyWith(
              color: AppColorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColorScheme.neutral600,
              ),
              const SizedBox(width: 6),
              Text(
                bundleOrder.currentOrder!.selectedDate != null
                  ? '${bundleOrder.currentOrder!.selectedDate!.day}/${bundleOrder.currentOrder!.selectedDate!.month}/${bundleOrder.currentOrder!.selectedDate!.year}'
                  : 'Date not selected',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral700,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.people,
                size: 16,
                color: AppColorScheme.neutral600,
              ),
              const SizedBox(width: 6),
              Text(
                '${bundleOrder.currentOrder!.participantCount} participant${bundleOrder.currentOrder!.participantCount > 1 ? 's' : ''}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantSection(BundleOrderState bundleOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38), // 0.15 opacity
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participant Details',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide the full name for each participant',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Participant forms
          ..._controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controllers = entry.value;
            
            return Column(
              children: [
                _buildParticipantForm(index + 1, controllers),
                if (index < _controllers.length - 1)
                  const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParticipantForm(int participantNumber, Map<String, TextEditingController> controllers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participant $participantNumber',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controllers['givenName'],
                decoration: InputDecoration(
                  labelText: 'Given Name',
                  hintText: 'Enter given name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColorScheme.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Given name is required';
                  }
                  return null;
                },
                onChanged: (value) => _updateParticipant(participantNumber - 1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controllers['familyName'],
                decoration: InputDecoration(
                  labelText: 'Family Name',
                  hintText: 'Enter family name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColorScheme.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Family name is required';
                  }
                  return null;
                },
                onChanged: (value) => _updateParticipant(participantNumber - 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38), // 0.15 opacity
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll send your booking confirmation to this email',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColorScheme.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Contact Email',
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email, color: AppColorScheme.neutral600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColorScheme.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) => _updateContactEmail(),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BundleOrderState bundleOrder) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canProceed() ? () => _proceedToOrderSummary() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canProceed() 
            ? AppColorScheme.primary 
            : AppColorScheme.neutral300,
          foregroundColor: Colors.white,
          elevation: _canProceed() ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: bundleOrder.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Review Order',
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                ),
              ],
            ),
      ),
    );
  }

  bool _canProceed() {
    if (_controllers.isEmpty || _emailController.text.trim().isEmpty) {
      return false;
    }
    
    for (final controllers in _controllers) {
      if (controllers['givenName']!.text.trim().isEmpty ||
          controllers['familyName']!.text.trim().isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  void _updateParticipant(int index) {
    if (index < _controllers.length) {
      final controllers = _controllers[index];
      ref.read(bundleOrderProvider.notifier).updateParticipant(
        index,
        controllers['givenName']!.text.trim(),
        controllers['familyName']!.text.trim(),
      );
    }
  }

  void _updateContactEmail() {
    ref.read(bundleOrderProvider.notifier).updateContactEmail(_emailController.text.trim());
  }

  void _proceedToOrderSummary() {
    if (_formKey.currentState?.validate() ?? false) {
      // Update all participants one final time
      for (int i = 0; i < _controllers.length; i++) {
        _updateParticipant(i);
      }
      _updateContactEmail();
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BundleOrderSummaryScreen(),
        ),
      );
    }
  }
}
