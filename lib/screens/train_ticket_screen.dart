import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../services/g2rail_api_client.dart';

class TrainTicketScreen extends StatefulWidget {
  const TrainTicketScreen({super.key});

  @override
  State<TrainTicketScreen> createState() => _TrainTicketScreenState();
}

class _TrainTicketScreenState extends State<TrainTicketScreen> {
  String? _apiResponse;
  bool _isLoading = false;
  String? _errorMessage;

  Client baseClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    Client c = IOClient(httpClient);
    return c;
  }

  void _copyToClipboard() {
    if (_apiResponse != null) {
      Clipboard.setData(ClipboardData(text: _apiResponse!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API response copied to clipboard!'),
          backgroundColor: AppColorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _pollForAsyncResult(
    GrailApiClient gac,
    String asyncKey, {
    Duration pollInterval = const Duration(milliseconds: 500),
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final result = await gac.getAsyncResult(asyncKey);

        if (result != null && result is Map<String, dynamic>) {
          // 檢查是否有 data 字段且包含 code
          if (result.containsKey('data') && result['data'] is Map<String, dynamic>) {
            final data = result['data'] as Map<String, dynamic>;
            final code = data['code'];

            if (code == 'async_not_ready') {
              // 結果還沒準備好，繼續輪詢
              print('異步結果還未準備好，繼續輪詢...');
            } else {
              // 其他情況認為是有效結果
              return result;
            }
          } else {
            // 沒有 data.code 結構，可能是成功的結果
            return result;
          }
        }
      } catch (e) {
        // 如果是網路錯誤或其他錯誤，可能需要重試
        print('輪詢錯誤: $e');
      }

      // 等待一段時間後再次輪詢
      await Future.delayed(pollInterval);
    }

    throw Exception('獲取異步結果超時 (${timeout.inSeconds}秒)');
  }

  void _callG2RailAPI() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _apiResponse = null;
    });

    try {
      final baseUrl = dotenv.env['G2RAIL_BASE_URL'] ?? '';
      final apiKey = dotenv.env['G2RAIL_API_KEY'] ?? '';
      final secret = dotenv.env['G2RAIL_SECRET'] ?? '';

      if (baseUrl.isEmpty || apiKey.isEmpty || secret.isEmpty) {
        throw Exception('G2Rail API credentials not found in environment variables');
      }

      var gac = GrailApiClient(
        httpClient: baseClient(),
        baseUrl: baseUrl,
        apiKey: apiKey,
        secret: secret,
      );

      var response = await gac.getSolutions(
        "ST_EMYRPQ9N",
        "ST_E7G93QNJ",
        DateFormat("yyyy-MM-dd")
            .format(DateTime.now().add(const Duration(days: 7))),
        "08:00",
        1,
        0,
        0,
        0,
        0,
      );

      var asyncKey = response['async'];
      var result = await _pollForAsyncResult(gac, asyncKey);

      setState(() {
        _isLoading = false;
        _apiResponse = const JsonEncoder.withIndent('  ').convert(result);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'API 調用失敗: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Train Ticket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorScheme.neutral900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: AppTheme.headlineSmall.copyWith(
          color: AppColorScheme.neutral900,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColorScheme.primary, AppColorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColorScheme.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.train,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Train to Neuschwanstein',
                    style: AppTheme.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book your train journey to the castle',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Route Information
            _buildSectionCard(
              title: 'Popular Train Routes',
              children: [
                _buildRouteItem(
                  from: 'Munich Hauptbahnhof',
                  to: 'Füssen',
                  duration: '2h 15min',
                  price: '€23.90',
                  type: 'Regional Express',
                ),
                const Divider(height: 32),
                _buildRouteItem(
                  from: 'Füssen',
                  to: 'Neuschwanstein Castle',
                  duration: '15min',
                  price: '€2.50',
                  type: 'Bus 73/78',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Journey Information
            _buildSectionCard(
              title: 'Journey Information',
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  title: 'Journey Time',
                  description: 'Approximately 2.5 hours from Munich to the castle',
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  icon: Icons.confirmation_number,
                  title: 'Ticket Types',
                  description: 'Bayern-Ticket, Single tickets, or DB Day Pass available',
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  icon: Icons.schedule,
                  title: 'Operating Hours',
                  description: 'Trains run every 1-2 hours, 6:00 AM - 10:00 PM',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Real-time Train Search Section
            _buildSectionCard(
              title: 'Real-time Train Search',
              children: [
                Text(
                  'Search for available train connections using G2Rail API',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColorScheme.neutral700,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _callG2RailAPI,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isLoading ? 'Searching...' : 'Search Frankfurt → Berlin',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.tertiary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _callG2RailAPI,
                          child: Text('重試'),
                        ),
                      ],
                    ),
                  ),
                ] else if (_apiResponse != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColorScheme.primary100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'API 響應結果：',
                              style: AppTheme.titleMedium.copyWith(
                                color: AppColorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _copyToClipboard,
                                  icon: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: AppColorScheme.primary,
                                  ),
                                  label: Text(
                                    '複製',
                                    style: TextStyle(color: AppColorScheme.primary),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _apiResponse = null;
                                    });
                                  },
                                  child: Text(
                                    '清除',
                                    style: TextStyle(color: AppColorScheme.primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _apiResponse!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Book Ticket Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement train ticket booking
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Train ticket booking coming soon!'),
                      backgroundColor: AppColorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.train, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Book Train Ticket',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.titleLarge.copyWith(
              color: AppColorScheme.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRouteItem({
    required String from,
    required String to,
    required String duration,
    required String price,
    required String type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    from,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColorScheme.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: AppColorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          to,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColorScheme.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  duration,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColorScheme.neutral600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorScheme.primary100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            type,
            style: AppTheme.bodySmall.copyWith(
              color: AppColorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorScheme.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.titleSmall.copyWith(
                  color: AppColorScheme.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColorScheme.neutral700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
