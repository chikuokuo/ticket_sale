import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class SearchCriteria {
  final String from;
  final String to;
  final String date;
  final String time;
  final int adult;
  final int child;
  final int junior;
  final int senior;
  final int infant;

  SearchCriteria(
      this.from,
      this.to,
      this.date,
      this.time,
      this.adult,
      this.child,
      this.junior,
      this.senior,
      this.infant,
      );

  String toQuery() {
    return "from=$from&to=$to&date=$date&time=$time&adult=$adult&child=$child&junior=$junior&senior=$senior&infant=$infant";
  }

  Map<String, dynamic> toMap() {
    return {
      "from": from,
      "to": to,
      "date": date,
      "time": time,
      "adult": adult,
      "child": child,
      "junior": junior,
      "senior": senior,
      "infant": infant,
    };
  }
}

class G2RailApiClient {
  late final String apiKey;
  late final String userId;
  late final String baseUrl;
  late final String secret;
  final http.Client httpClient;

  G2RailApiClient({
    required this.httpClient,
  }) {
    apiKey = dotenv.env['G2RAIL_API_KEY'] ?? '';
    userId = dotenv.env['G2RAIL_USER_ID'] ?? '';
    baseUrl = dotenv.env['G2RAIL_BASE_URL'] ?? '';
    secret = dotenv.env['G2RAIL_SECRET'] ?? '';

    if (apiKey.isEmpty || userId.isEmpty || baseUrl.isEmpty || secret.isEmpty) {
      throw Exception('Missing required G2Rail API configuration in .env file');
    }
  }

  Map<String, String> getAuthorizationHeaders(Map<String, dynamic> params) {
    var timestamp = DateTime.now();
    params['t'] = (timestamp.millisecondsSinceEpoch ~/ 1000).toString();
    params['api_key'] = apiKey;

    var sortedKeys = params.keys.toList()..sort((a, b) => a.compareTo(b));
    StringBuffer buffer = StringBuffer("");
    for (var key in sortedKeys) {
      if (params[key] is List || params[key] is Map) continue;
      buffer.write('$key=${params[key].toString()}');
    }
    buffer.write(secret);

    String hashString = buffer.toString();
    String authorization = md5.convert(utf8.encode(hashString)).toString();

    return {
      "From": apiKey,
      "Content-Type": 'application/json',
      "Authorization": authorization,
      "Date": HttpDate.format(timestamp),
      "Api-Locale": "zh-TW",
    };
  }

  Future<dynamic> getSolutions(
      String from,
      String to,
      String date,
      String time,
      int adult,
      int child,
      int junior,
      int senior,
      int infant,
      ) async {
    final criteria = SearchCriteria(
      from,
      to,
      date,
      time,
      adult,
      child,
      junior,
      senior,
      infant,
    );
    final solutionUrl =
        '$baseUrl/api/v2/online_solutions/?${criteria.toQuery()}';

    // Add timeout to the HTTP request (10 seconds)
    final solutionResponse = await httpClient.get(
      Uri.parse(solutionUrl),
      headers: getAuthorizationHeaders(criteria.toMap()),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('HTTP 請求超時：無法連接到 G2Rail API');
      },
    );

    if (solutionResponse.statusCode != 200) {
      throw Exception('error getting solutions');
    }

    final solutionsJson = jsonDecode(solutionResponse.body);
    return solutionsJson;
  }

  Future<dynamic> getAsyncResult(String asyncKey) async {
    final asyncResultURl = '$baseUrl/api/v2/async_results/$asyncKey';

    // Add timeout to the async result request (5 seconds)
    final asyncResult = await httpClient.get(
      Uri.parse(asyncResultURl),
      headers: getAuthorizationHeaders({"async_key": asyncKey}),
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('異步結果請求超時');
      },
    );

    if (asyncResult.statusCode != 200) {
      throw Exception('異步結果請求失敗，狀態碼: ${asyncResult.statusCode}');
    }

    try {
      final decodedData = jsonDecode(utf8.decode(asyncResult.bodyBytes));
      return {"data": decodedData};
    } catch (e) {
      throw Exception('解析異步結果失敗: $e');
    }
  }
}

// Global instances for easy access
final G2RailApiClient g2railApiClient = G2RailApiClient(httpClient: http.Client());
final http.Client httpClient = http.Client();
final Utf8Encoder utf8Encoder = const Utf8Encoder();
