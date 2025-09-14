/// G2Rail API response models for parsing API responses
class G2RailResponse {
  final String? async;
  final G2RailData? data;
  final String? status;
  final String? message;

  G2RailResponse({
    this.async,
    this.data,
    this.status,
    this.message,
  });

  factory G2RailResponse.fromJson(Map<String, dynamic> json) {
    return G2RailResponse(
      async: json['async'],
      data: json['data'] != null ? G2RailData.fromJson(json['data']) : null,
      status: json['status'],
      message: json['message'],
    );
  }
}

class G2RailData {
  final String? status;
  final List<G2RailSolution>? solutions;
  final G2RailError? error;

  G2RailData({
    this.status,
    this.solutions,
    this.error,
  });

  factory G2RailData.fromJson(Map<String, dynamic> json) {
    return G2RailData(
      status: json['status'],
      solutions: json['solutions'] != null
          ? (json['solutions'] as List)
              .map((item) => G2RailSolution.fromJson(item))
              .toList()
          : null,
      error: json['error'] != null ? G2RailError.fromJson(json['error']) : null,
    );
  }
}

class G2RailSolution {
  final String? id;
  final List<G2RailSegment>? segments;
  final List<G2RailFareOption>? fareOptions;
  final String? totalDuration;
  final double? totalPrice;

  G2RailSolution({
    this.id,
    this.segments,
    this.fareOptions,
    this.totalDuration,
    this.totalPrice,
  });

  factory G2RailSolution.fromJson(Map<String, dynamic> json) {
    return G2RailSolution(
      id: json['id'],
      segments: json['segments'] != null
          ? (json['segments'] as List)
              .map((item) => G2RailSegment.fromJson(item))
              .toList()
          : null,
      fareOptions: json['fare_options'] != null
          ? (json['fare_options'] as List)
              .map((item) => G2RailFareOption.fromJson(item))
              .toList()
          : null,
      totalDuration: json['total_duration'],
      totalPrice: (json['total_price'] as num?)?.toDouble(),
    );
  }
}

class G2RailSegment {
  final String? trainNumber;
  final String? trainType;
  final String? departureStation;
  final String? arrivalStation;
  final String? departureTime;
  final String? arrivalTime;
  final String? duration;
  final G2RailStation? from;
  final G2RailStation? to;

  G2RailSegment({
    this.trainNumber,
    this.trainType,
    this.departureStation,
    this.arrivalStation,
    this.departureTime,
    this.arrivalTime,
    this.duration,
    this.from,
    this.to,
  });

  factory G2RailSegment.fromJson(Map<String, dynamic> json) {
    return G2RailSegment(
      trainNumber: json['train_number'],
      trainType: json['train_type'],
      departureStation: json['departure_station'],
      arrivalStation: json['arrival_station'],
      departureTime: json['departure_time'],
      arrivalTime: json['arrival_time'],
      duration: json['duration'],
      from: json['from'] != null ? G2RailStation.fromJson(json['from']) : null,
      to: json['to'] != null ? G2RailStation.fromJson(json['to']) : null,
    );
  }
}

class G2RailStation {
  final String? id;
  final String? name;
  final String? code;
  final double? latitude;
  final double? longitude;

  G2RailStation({
    this.id,
    this.name,
    this.code,
    this.latitude,
    this.longitude,
  });

  factory G2RailStation.fromJson(Map<String, dynamic> json) {
    return G2RailStation(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class G2RailFareOption {
  final String? id;
  final String? classCode;
  final String? className;
  final double? price;
  final String? currency;
  final bool? refundable;
  final bool? exchangeable;

  G2RailFareOption({
    this.id,
    this.classCode,
    this.className,
    this.price,
    this.currency,
    this.refundable,
    this.exchangeable,
  });

  factory G2RailFareOption.fromJson(Map<String, dynamic> json) {
    return G2RailFareOption(
      id: json['id'],
      classCode: json['class'],
      className: json['class_name'],
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'],
      refundable: json['refundable'],
      exchangeable: json['exchangeable'],
    );
  }
}

class G2RailError {
  final String? code;
  final String? message;
  final Map<String, dynamic>? details;

  G2RailError({
    this.code,
    this.message,
    this.details,
  });

  factory G2RailError.fromJson(Map<String, dynamic> json) {
    return G2RailError(
      code: json['code'],
      message: json['message'],
      details: json['details'],
    );
  }
}

/// Extension methods for easier conversion to app models
extension G2RailResponseExtensions on G2RailResponse {
  bool get isAsyncRequest => async != null && async!.isNotEmpty;

  bool get isCompleted {
    return data?.status == 'completed';
  }

  bool get hasError {
    return data?.error != null || status == 'error';
  }

  String get errorMessage {
    if (data?.error?.message != null) {
      return data!.error!.message!;
    }
    return message ?? '未知錯誤';
  }
}