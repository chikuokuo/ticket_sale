import 'dart:io';
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
  late final G2RailApiClient _apiClient;

  TrainApiService._() {
    _apiClient = G2RailApiClient(
      httpClient: _createHttpClient(),
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
    String? departureTime,
    required int adultCount,
    required int childCount,
  }) async {
    try {
      final searchTime = departureTime ?? "08:00"; // Use provided time or default to 08:00

      print('🚂 開始搜索火車班次...');
      print('📍 路線: ST_L6NN3P6K → ST_DKRRM9Q4');
      print('📅 日期: ${DateFormat("yyyy-MM-dd").format(departureDate)}');
      print('🕐 時間: $searchTime');
      print('👥 乘客: $adultCount 成人, $childCount 兒童');

      // Create a timeout for the entire search operation (30 seconds)
      return await Future.any([
        _performSearch(fromStation, toStation, departureDate, searchTime, adultCount, childCount),
        Future.delayed(const Duration(seconds: 30), () {
          throw Exception('搜索超時：操作已超過 30 秒，已自動取消');
        }),
      ]);

    } catch (e) {
      print('❌ 搜索失敗: $e');
      throw Exception('搜索火車班次失敗: $e');
    }
  }

  Future<TrainSearchResult> _performSearch(
    TrainStation fromStation,
    TrainStation toStation,
    DateTime departureDate,
    String searchTime,
    int adultCount,
    int childCount,
  ) async {
    // For now, use the specified station codes
    // Later this can be made configurable or mapped from station data
    final response = await _apiClient.getSolutions(
      "ST_L6NN3P6K", // from station code
      "ST_DKRRM9Q4", // to station code
      DateFormat("yyyy-MM-dd").format(departureDate),
      searchTime, // Use the departure time
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
  }

  Future<Map<String, dynamic>> _pollAsyncResult(String asyncKey) async {
    const maxAttempts = 12; // Reduced to fit within 30s total timeout (12 * 2s = 24s)
    const pollInterval = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print('🔄 輪詢嘗試 $attempt/$maxAttempts...');

        // Add timeout for individual polling requests (5 seconds each)
        final result = await Future.any([
          _apiClient.getAsyncResult(asyncKey),
          Future.delayed(const Duration(seconds: 5), () {
            throw Exception('單次輪詢請求超時');
          }),
        ]);

        print('📥 輪詢回應: $result');

        // Check if result is complete
        final data = result['data'];
        if (data != null && data is List) {
          // Check if all railway companies have finished loading
          bool allLoaded = true;
          bool hasSolutions = false;

          for (var railwayData in data) {
            if (railwayData is Map<String, dynamic>) {
              final loading = railwayData['loading'] ?? false;
              final solutions = railwayData['solutions'] as List?;

              if (loading == true) {
                allLoaded = false;
              }

              if (solutions != null && solutions.isNotEmpty) {
                hasSolutions = true;
              }
            }
          }

          print('⏳ 加載狀態 - 全部完成: $allLoaded, 有結果: $hasSolutions');

          // Return if all are loaded OR if we have some solutions and reasonable time has passed
          // Also return if we've waited long enough even without solutions (to show "no results found")
          if (allLoaded || (hasSolutions && attempt > 3) || attempt >= 8) {
            print('✅ 輪詢完成！${allLoaded ? ' (全部加載完成)' : hasSolutions ? ' (找到部分結果)' : ' (已等待足夠時間)'}');
            return result;
          }
        } else if (data != null && data['status'] == 'completed') {
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

    throw Exception('輪詢超時，API 響應時間過長');
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

      if (data is! List) {
        print('⚠️ data 字段不是 List 類型: ${data.runtimeType}');
        return [];
      }

      print('📊 Data 是包含 ${data.length} 個鐵路公司的列表');

      // Collect all solutions from all railway companies
      final allSolutions = <Map<String, dynamic>>[];

      for (var railwayData in data) {
        if (railwayData is! Map<String, dynamic>) {
          print('⚠️ 鐵路公司數據格式無效');
          continue;
        }

        final railway = railwayData as Map<String, dynamic>;
        final railwayInfo = railway['railway'];
        final loading = railway['loading'] ?? false;
        final solutions = railway['solutions'];

        if (railwayInfo is Map<String, dynamic>) {
          final railwayName = railwayInfo['name'] ?? 'Unknown';
          print('🚊 處理鐵路公司: $railwayName (loading: $loading)');
        }

        if (solutions is List && solutions.isNotEmpty) {
          // Add solutions from this railway company
          for (var solution in solutions) {
            if (solution is Map<String, dynamic>) {
              allSolutions.add(solution);
            }
          }
        }
      }

      print('🎫 總共找到 ${allSolutions.length} 個解決方案');

      if (allSolutions.isEmpty) {
        print('⚠️ 所有鐵路公司都沒有可用方案');
        print('📋 搜索摘要:');
        for (var railwayData in data) {
          if (railwayData is Map<String, dynamic>) {
            final railway = railwayData['railway'];
            final loading = railwayData['loading'];
            final solutions = railwayData['solutions'] as List?;
            if (railway is Map<String, dynamic>) {
              final name = railway['name'] ?? 'Unknown';
              final code = railway['code'] ?? 'N/A';
              print('   🚊 $name ($code): ${loading ? '仍在加載' : '加載完成'}, ${solutions?.length ?? 0} 個方案');
            }
          }
        }
        // Return empty list but don't throw error - let UI handle empty results
        return [];
      }

      final trips = <TrainTrip>[];

      for (var i = 0; i < allSolutions.length; i++) {
        try {
          final solution = allSolutions[i];
          print('🔄 處理解決方案 ${i + 1}/${allSolutions.length}');

          final segmentsData = solution['segments'];
          if (segmentsData == null || segmentsData is! List) {
            print('⚠️ 解決方案 ${i + 1} 沒有有效的路段');
            continue;
          }

          final segments = segmentsData as List;
          if (segments.isEmpty) {
            print('⚠️ 解決方案 ${i + 1} 路段列表為空');
            continue;
          }

          final firstSegment = segments.first as Map<String, dynamic>?;
          final lastSegment = segments.last as Map<String, dynamic>?;

          if (firstSegment == null || lastSegment == null) {
            print('⚠️ 解決方案 ${i + 1} 路段數據無效');
            continue;
          }

          // Parse departure and arrival times
          final departureTimeStr = firstSegment['departure_time'];
          final arrivalTimeStr = lastSegment['arrival_time'];

          if (departureTimeStr == null || arrivalTimeStr == null) {
            print('⚠️ 解決方案 ${i + 1} 缺少時間信息');
            continue;
          }

          final departureTime = DateTime.parse(departureTimeStr.toString());
          final arrivalTime = DateTime.parse(arrivalTimeStr.toString());
          final duration = arrivalTime.difference(departureTime);

          // Parse prices
          final prices = <TicketClass, double>{};
          final fareOptionsData = solution['fare_options'];
          if (fareOptionsData != null && fareOptionsData is List) {
            final fareOptions = fareOptionsData as List;
            for (var fareOptionData in fareOptions) {
              if (fareOptionData is Map<String, dynamic>) {
                final fareOption = fareOptionData as Map<String, dynamic>;
                final classCode = fareOption['class']?.toString();
                final price = (fareOption['price'] as num?)?.toDouble() ?? 0.0;

                if (classCode == '2') {
                  prices[TicketClass.second] = price;
                } else if (classCode == '1') {
                  prices[TicketClass.first] = price;
                }
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
            trainType: _parseTrainType(firstSegment['train_type']?.toString()),
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
        } catch (e) {
          print('❌ 處理解決方案 ${i + 1} 時出錯: $e');
          continue;
        }
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