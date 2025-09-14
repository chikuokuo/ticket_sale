import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import '../services/g2rail_api_client.dart';
import '../models/train_trip.dart';
import '../models/train_station.dart';

class TrainSearchResult {
  final List<TrainTrip> trips;
  final Map<String, dynamic> rawApiResponse;

  TrainSearchResult({
    required this.trips,
    required this.rawApiResponse,
  });
}

class TrainApiService {
  static TrainApiService? _instance;
  late final GrailApiClient _apiClient;

  TrainApiService._() {
    _apiClient = GrailApiClient(
      httpClient: _createHttpClient(),
      baseUrl: dotenv.env['G2RAIL_BASE_URL']!,
      apiKey: dotenv.env['G2RAIL_API_KEY']!,
      secret: dotenv.env['G2RAIL_SECRET']!,
    );
  }

  static TrainApiService get instance {
    _instance ??= TrainApiService._();
    return _instance!;
  }

  Client _createHttpClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
    return IOClient(httpClient);
  }

  Future<TrainSearchResult> searchTrains({
    required TrainStation fromStation,
    required TrainStation toStation,
    required DateTime departureDate,
    required int adultCount,
    required int childCount,
  }) async {
    try {
      print('🚂 開始搜索火車班次...');
      print('📍 路線: ST_L6NN3P6K → ST_DKRRM9Q4');
      print('📅 日期: ${DateFormat("yyyy-MM-dd").format(departureDate)}');
      print('👥 乘客: $adultCount 成人, $childCount 兒童');

      // For now, use the specified station codes
      // Later this can be made configurable or mapped from station data
      final response = await _apiClient.getSolutions(
        "ST_L6NN3P6K", // from station code
        "ST_DKRRM9Q4", // to station code
        DateFormat("yyyy-MM-dd").format(departureDate),
        "08:00", // Default departure time
        adultCount,
        childCount,
        0, // junior
        0, // senior
        0, // infant
      );

      print('📤 API 回應: $response');

      final asyncKey = response['async'];
      if (asyncKey == null) {
        throw Exception('沒有收到異步鍵值，回應: $response');
      }

      print('🔑 異步鍵值: $asyncKey');
      print('⏳ 開始輪詢結果...');

      // Poll for results
      final result = await _pollAsyncResult(asyncKey);

      print('✅ 獲得最終結果');

      // Convert API response to TrainTrip list
      final trips = _parseApiResponse(result, fromStation, toStation);

      print('🎫 解析出 ${trips.length} 個班次');

      // Return both trips and raw API response
      return TrainSearchResult(
        trips: trips,
        rawApiResponse: result,
      );

    } catch (e) {
      print('❌ 搜索失敗: $e');
      throw Exception('搜索火車班次失敗: $e');
    }
  }

  Future<Map<String, dynamic>> _pollAsyncResult(String asyncKey) async {
    const maxAttempts = 30; // Maximum 30 attempts
    const pollInterval = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print('🔄 輪詢嘗試 $attempt/$maxAttempts...');
        final result = await _apiClient.getAsyncResult(asyncKey);

        print('📥 輪詢回應: $result');

        // Check if result is complete
        final data = result['data'];
        if (data != null && data['status'] == 'completed') {
          print('✅ 輪詢完成！');
          return result;
        } else if (data != null) {
          print('⏳ 狀態: ${data['status'] ?? 'unknown'}');
        }

        // If not the last attempt, wait before next poll
        if (attempt < maxAttempts) {
          print('⏰ 等待 ${pollInterval.inSeconds} 秒後重試...');
          await Future.delayed(pollInterval);
        }
      } catch (e) {
        print('❌ 輪詢嘗試 $attempt 失敗: $e');
        // If this is the last attempt, throw the error
        if (attempt == maxAttempts) {
          throw Exception('獲取結果失敗: $e');
        }
        // Otherwise, continue polling
        await Future.delayed(pollInterval);
      }
    }

    throw Exception('API 響應超時，請稍後重試');
  }

  List<TrainTrip> _parseApiResponse(
    Map<String, dynamic> apiResponse,
    TrainStation fromStation,
    TrainStation toStation,
  ) {
    try {
      print('🔍 開始解析 API 響應...');
      print('📄 響應結構: ${apiResponse.keys}');

      final data = apiResponse['data'];
      if (data == null) {
        print('⚠️ 沒有 data 字段');
        return [];
      }

      print('📊 Data 字段: ${data.keys}');

      if (data['solutions'] == null) {
        print('⚠️ 沒有 solutions 字段');
        return [];
      }

      final solutions = data['solutions'] as List;
      print('🎫 找到 ${solutions.length} 個解決方案');

      if (solutions.isEmpty) {
        print('⚠️ 解決方案列表為空');
        return [];
      }

      final trips = <TrainTrip>[];

      for (var i = 0; i < solutions.length; i++) {
        final solution = solutions[i];
        print('🔄 處理解決方案 ${i + 1}/${solutions.length}');

        final segments = solution['segments'] as List?;
        if (segments == null || segments.isEmpty) {
          print('⚠️ 解決方案 ${i + 1} 沒有有效的路段');
          continue;
        }

        final firstSegment = segments.first;
        final lastSegment = segments.last;

        // Parse departure and arrival times
        final departureTimeStr = firstSegment['departure_time'];
        final arrivalTimeStr = lastSegment['arrival_time'];

        if (departureTimeStr == null || arrivalTimeStr == null) {
          print('⚠️ 解決方案 ${i + 1} 缺少時間信息');
          continue;
        }

        final departureTime = DateTime.parse(departureTimeStr);
        final arrivalTime = DateTime.parse(arrivalTimeStr);
        final duration = arrivalTime.difference(departureTime);

        // Parse prices
        final prices = <TicketClass, double>{};
        final fareOptions = solution['fare_options'] as List?;
        if (fareOptions != null && fareOptions.isNotEmpty) {
          for (var fareOption in fareOptions) {
            final classCode = fareOption['class'];
            final price = (fareOption['price'] as num?)?.toDouble() ?? 0.0;

            if (classCode == '2') {
              prices[TicketClass.second] = price;
            } else if (classCode == '1') {
              prices[TicketClass.first] = price;
            }
          }
        }

        // Default price if none found
        if (prices.isEmpty) {
          prices[TicketClass.second] = 50.0; // Default price
        }

        // Create TrainTrip
        final trip = TrainTrip(
          id: solution['id']?.toString() ?? 'api_${DateTime.now().millisecondsSinceEpoch}',
          trainNumber: firstSegment['train_number']?.toString() ?? 'N/A',
          trainType: _parseTrainType(firstSegment['train_type']),
          fromStation: fromStation,
          toStation: toStation,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
          duration: duration,
          prices: prices,
          hasWifi: true, // Assume modern trains have wifi
          availableSeats: 100, // Default available seats
        );

        trips.add(trip);
        print('✅ 成功創建班次: ${trip.trainNumber}');
      }

      print('🎉 解析完成，共 ${trips.length} 個班次');
      return trips;
    } catch (e) {
      print('❌ 解析 API 響應失敗: $e');
      throw Exception('解析 API 響應失敗: $e');
    }
  }

  TrainType _parseTrainType(String? trainType) {
    if (trainType == null) return TrainType.ic;

    final typeUpper = trainType.toUpperCase();
    if (typeUpper.contains('ICE')) return TrainType.ice;
    if (typeUpper.contains('IC')) return TrainType.ic;
    if (typeUpper.contains('EC')) return TrainType.ec;
    if (typeUpper.contains('RE')) return TrainType.re;
    if (typeUpper.contains('RB')) return TrainType.rb;

    return TrainType.ic; // Default
  }
}