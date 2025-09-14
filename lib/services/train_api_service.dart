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

      print('🚂 Searching for train trips...');
      print('📍 Route: ST_L6NN3P6K → ST_DKRRM9Q4');
      print('📅 Date: ${DateFormat("yyyy-MM-dd").format(departureDate)}');
      print('🕐 Time: $searchTime');
      print('👥 Passengers: $adultCount Adult(s), $childCount Child(ren)');

      // Create a timeout for the entire search operation (50 seconds)
      return await Future.any([
        _performSearch(fromStation, toStation, departureDate, searchTime, adultCount, childCount),
        Future.delayed(const Duration(seconds: 50), () {
          throw Exception('Search timed out: Operation took longer than 50 seconds and was canceled');
        }),
      ]);

    } catch (e) {
      print('❌ Search failed: $e');
      throw Exception('Failed to search for train trips: $e');
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

    print('📤 API Response: $response');

    final asyncKey = response['async'];
    if (asyncKey == null) {
      throw Exception('Async key not received in response: $response');
    }

    print('🔑 Async Key: $asyncKey');
    print('⏳ Starting to poll for results...');

    // Poll for results
    final result = await _pollAsyncResult(asyncKey);

    print('✅ Final result obtained');

    // Convert API response to TrainTrip list
    final trips = _parseApiResponse(result, fromStation, toStation);

    print('🎫 Parsed ${trips.length} trips');

    // Return both trips and raw API response
    return TrainSearchResult(
      trips: trips,
      rawApiResponse: result,
    );
  }

  Future<Map<String, dynamic>> _pollAsyncResult(String asyncKey) async {
    const maxAttempts = 15; // Increased to fit within 50s total timeout (15 * 3s = 45s)
    const pollInterval = Duration(seconds: 3);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print('🔄 Polling attempt $attempt/$maxAttempts...');

        // Add timeout for individual polling requests (5 seconds each)
        final result = await Future.any([
          _apiClient.getAsyncResult(asyncKey),
          Future.delayed(const Duration(seconds: 5), () {
            throw Exception('Single poll request timed out');
          }),
        ]);

        print('📥 Poll response: $result');

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

          print('⏳ Loading status - All loaded: $allLoaded, Has solutions: $hasSolutions');

          // Return if all are loaded OR if we have some solutions and reasonable time has passed
          // Also return if we've waited long enough even without solutions (to show "no results found")
          if (allLoaded || (hasSolutions && attempt > 3) || attempt >= 8) {
            print('✅ Polling complete! ${allLoaded ? ' (All loaded)' : hasSolutions ? ' (Partial results found)' : ' (Waited long enough)'}');
            return result;
          }
        } else if (data != null && data['status'] == 'completed') {
          print('✅ Polling complete!');
          return result;
        } else if (data != null) {
          print('⏳ Status: ${data['status'] ?? 'unknown'}');
        }

        // If not the last attempt, wait before next poll
        if (attempt < maxAttempts) {
          print('⏰ Waiting ${pollInterval.inSeconds} seconds before retry...');
          await Future.delayed(pollInterval);
        }
      } catch (e) {
        print('❌ Polling attempt $attempt failed: $e');
        // If this is the last attempt, throw the error
        if (attempt == maxAttempts) {
          throw Exception('Failed to get results: $e');
        }
        // Otherwise, continue polling
        await Future.delayed(pollInterval);
      }
    }

    throw Exception('Polling timed out, API response took too long');
  }

  List<TrainTrip> _parseApiResponse(
    Map<String, dynamic> apiResponse,
    TrainStation fromStation,
    TrainStation toStation,
  ) {
    try {
      print('🔍 Starting to parse API response...');
      print('📄 Response structure: ${apiResponse.keys}');

      final data = apiResponse['data'];
      if (data == null) {
        print('⚠️ No data field found');
        return [];
      }

      if (data is! List) {
        print('⚠️ Data field is not a List: ${data.runtimeType}');
        return [];
      }

      print('📊 Data is a list with ${data.length} railway companies');

      // Collect all solutions from all railway companies
      final allSolutions = <Map<String, dynamic>>[];

      for (var railwayData in data) {
        if (railwayData is! Map<String, dynamic>) {
          print('⚠️ Invalid railway company data format');
          continue;
        }

        final railway = railwayData as Map<String, dynamic>;
        final railwayInfo = railway['railway'];
        final loading = railway['loading'] ?? false;
        final solutions = railway['solutions'];

        if (railwayInfo is Map<String, dynamic>) {
          final railwayName = railwayInfo['name'] ?? 'Unknown';
          print('🚊 Processing railway company: $railwayName (loading: $loading)');
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

      print('🎫 Found ${allSolutions.length} solutions in total');

      if (allSolutions.isEmpty) {
        print('⚠️ No available solutions from any railway company');
        print('📋 Search summary:');
        for (var railwayData in data) {
          if (railwayData is Map<String, dynamic>) {
            final railway = railwayData['railway'];
            final loading = railwayData['loading'];
            final solutions = railwayData['solutions'] as List?;
            if (railway is Map<String, dynamic>) {
              final name = railway['name'] ?? 'Unknown';
              final code = railway['code'] ?? 'N/A';
              print('   🚊 $name ($code): ${loading ? 'Still loading' : 'Load complete'}, ${solutions?.length ?? 0} solutions');
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
          print('🔄 Processing solution ${i + 1}/${allSolutions.length}');

          final segmentsData = solution['segments'];
          if (segmentsData == null || segmentsData is! List) {
            print('⚠️ Solution ${i + 1} has no valid segments');
            continue;
          }

          final segments = segmentsData as List;
          if (segments.isEmpty) {
            print('⚠️ Solution ${i + 1} has an empty segments list');
            continue;
          }

          final firstSegment = segments.first as Map<String, dynamic>?;
          final lastSegment = segments.last as Map<String, dynamic>?;

          if (firstSegment == null || lastSegment == null) {
            print('⚠️ Solution ${i + 1} has invalid segment data');
            continue;
          }

          // Parse departure and arrival times
          final departureTimeStr = firstSegment['departure_time'];
          final arrivalTimeStr = lastSegment['arrival_time'];

          if (departureTimeStr == null || arrivalTimeStr == null) {
            print('⚠️ Solution ${i + 1} is missing time information');
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
          print('✅ Successfully created trip: ${trip.trainNumber}');
        } catch (e) {
          print('❌ Error processing solution ${i + 1}: $e');
          continue;
        }
      }

      print('🎉 Parsing complete, found ${trips.length} trips');
      return trips;
    } catch (e) {
      print('❌ Failed to parse API response: $e');
      throw Exception('Failed to parse API response: $e');
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