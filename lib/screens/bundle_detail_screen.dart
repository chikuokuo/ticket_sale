import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/bundle.dart';
import '../providers/bundle_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import 'bundle_participant_screen.dart';

class BundleDetailScreen extends ConsumerStatefulWidget {
  final Bundle bundle;

  const BundleDetailScreen({
    super.key,
    required this.bundle,
  });

  @override
  ConsumerState<BundleDetailScreen> createState() => _BundleDetailScreenState();
}

class _BundleDetailScreenState extends ConsumerState<BundleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final bundleOrder = ref.watch(bundleOrderProvider);

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating section
                  _buildTitleSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Booking section
                  _buildBookingSection(bundleOrder),
                  
                  const SizedBox(height: 32),
                  
                  // Description section
                  _buildDescriptionSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Highlights section
                  _buildHighlightsSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Activities section
                  _buildActivitiesSection(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.bundle.imageUrl),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {
                // Handle image loading error silently
              },
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(77), // 0.3 opacity
                  Colors.black.withAlpha(153), // 0.6 opacity
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Implement share functionality
          },
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.bundle.category,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.schedule,
              color: AppColorScheme.neutral600,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              widget.bundle.duration,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColorScheme.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Text(
          widget.bundle.title,
          style: AppTheme.displaySmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          widget.bundle.subtitle,
          style: AppTheme.titleLarge.copyWith(
            color: AppColorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Rating and reviews
        Row(
          children: [
            Icon(
              Icons.star,
              color: AppColorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              widget.bundle.rating.toString(),
              style: AppTheme.titleMedium.copyWith(
                color: AppColorScheme.neutral900,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${widget.bundle.reviewCount} reviews)',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColorScheme.neutral600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingSection(BundleOrderState bundleOrder) {
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
            'Book Your Experience',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Price display
          Row(
            children: [
              Text(
                '€${widget.bundle.price.toStringAsFixed(0)}',
                style: AppTheme.displaySmall.copyWith(
                  color: AppColorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' per person',
                style: AppTheme.titleMedium.copyWith(
                  color: AppColorScheme.neutral600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Date selection
          _buildDateSelection(bundleOrder),
          
          const SizedBox(height: 20),
          
          // Participant count selection
          _buildParticipantCountSelection(bundleOrder),
          
          const SizedBox(height: 24),
          
          // Total amount
          if (bundleOrder.attendees.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.primary50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorScheme.primary200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColorScheme.primary700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '€${(bundleOrder.attendees.length * widget.bundle.price).toStringAsFixed(2)}',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppColorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canProceed(bundleOrder) ? () => _proceedToSummary(context, ref) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed(bundleOrder) 
                  ? AppColorScheme.primary 
                  : AppColorScheme.neutral300,
                foregroundColor: Colors.white,
                elevation: _canProceed(bundleOrder) ? 4 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue Booking',
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
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection(BundleOrderState bundleOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: bundleOrder.selectedDate != null 
                  ? AppColorScheme.primary 
                  : AppColorScheme.neutral300,
                width: bundleOrder.selectedDate != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: bundleOrder.selectedDate != null 
                ? AppColorScheme.primary50 
                : AppColorScheme.neutral50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: bundleOrder.selectedDate != null 
                    ? AppColorScheme.primary 
                    : AppColorScheme.neutral500,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bundleOrder.selectedDate == null
                      ? 'Choose your preferred date'
                      : DateFormat('EEEE, MMMM dd, yyyy').format(bundleOrder.selectedDate!),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: bundleOrder.selectedDate != null 
                        ? AppColorScheme.primary 
                        : AppColorScheme.neutral600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColorScheme.neutral400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCountSelection(BundleOrderState bundleOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Participants',
          style: AppTheme.titleMedium.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Decrement button
            InkWell(
              onTap: bundleOrder.attendees.length > 1
                ? () => _updateParticipantCount(bundleOrder.attendees.length - 1)
                : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bundleOrder.attendees.length > 1
                    ? AppColorScheme.neutral200
                    : AppColorScheme.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  color: bundleOrder.attendees.length > 1
                    ? AppColorScheme.neutral700
                    : AppColorScheme.neutral400,
                  size: 18,
                ),
              ),
            ),
            
            // Count display
            Container(
              width: 60,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                bundleOrder.attendees.length.toString(),
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.neutral900,
                ),
              ),
            ),
            
            // Increment button
            InkWell(
              onTap: () => _updateParticipantCount(
                bundleOrder.attendees.length + 1,
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            
            const Spacer(),
            
            // Price per person
            Text(
              '€${widget.bundle.price.toStringAsFixed(0)} each',
              style: AppTheme.titleMedium.copyWith(
                color: AppColorScheme.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Experience',
          style: AppTheme.headlineSmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.bundle.detailedDescription,
          style: AppTheme.bodyLarge.copyWith(
            color: AppColorScheme.neutral700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's Included",
          style: AppTheme.headlineSmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.bundle.highlights.map((highlight) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColorScheme.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  highlight,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColorScheme.neutral700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itinerary',
          style: AppTheme.headlineSmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.bundle.activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final isLast = index == widget.bundle.activities.length - 1;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: AppColorScheme.primary200,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Text(
                    activity,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColorScheme.neutral700,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  bool _canProceed(BundleOrderState bundleOrder) {
    return bundleOrder.selectedDate != null &&
           bundleOrder.attendees.isNotEmpty;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      ref.read(bundleOrderProvider.notifier).selectDate(picked);
    }
  }

  void _updateParticipantCount(int count) {
    final notifier = ref.read(bundleOrderProvider.notifier);
    final currentCount = ref.read(bundleOrderProvider).attendees.length;

    if (count > currentCount) {
      for (int i = 0; i < count - currentCount; i++) {
        notifier.addAttendee();
      }
    } else if (count < currentCount) {
      for (int i = 0; i < currentCount - count; i++) {
        // Find last index to remove
        final lastIndex = ref.read(bundleOrderProvider).attendees.length - 1;
        if (lastIndex >= 0) {
          notifier.removeAttendee(lastIndex);
        }
      }
    }
  }

  void _proceedToSummary(BuildContext context, WidgetRef ref) {
    // Before navigating, ensure the latest bundle details are in the provider
    final notifier = ref.read(bundleOrderProvider.notifier);
    notifier.selectBundle(widget.bundle);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BundleParticipantScreen(
          bundle: widget.bundle,
        ),
      ),
    );
  }
}
