// lib/src/services/weather_api.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:calendar_app/models/weather_day.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherApi {
  // Pass via dart-define in development rather than hardcoding:
  // flutter run --dart-define=OPENWEATHERMAP_API_KEY=your_key
  static const _apiKey = '2bba9941e8fbe1ffd852823b0cde8678';

  final double lat;
  final double lon;
  final Duration timeoutDuration; // Renamed to avoid confusion

  WeatherApi({
    this.lat = 27.7172,
    this.lon = 85.3240,
    Duration? timeout,
  }) : timeoutDuration = timeout ?? const Duration(seconds: 12);

  /// Fetches exactly 7 WeatherDay objects (today + next 6).
  Future<List<WeatherDay>> fetch7DayForecast() async {
    try {
      final daily = await _fetchDailyForecast(cnt: 7);
      if (daily.isNotEmpty) return _ensureSevenDays(daily);
    } catch (e, st) {
      print('Daily endpoint failed: $e\n$st');
    }

    // fallback
    try {
      final aggregated = await _fetchAndAggregate3HourForecast();
      if (aggregated.isNotEmpty) return _ensureSevenDays(aggregated);
      throw Exception('No data returned from fallback endpoint');
    } catch (e, st) {
      throw Exception('Failed to fetch forecast (daily + fallback): $e\n$st');
    }
  }

  // Preferred: daily forecast endpoint (/data/2.5/forecast/daily)
  // NOTE: This endpoint requires a paid subscription
  Future<List<WeatherDay>> _fetchDailyForecast({int cnt = 7}) async {
    final url = Uri.https('api.openweathermap.org', '/data/2.5/forecast/daily', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'cnt': cnt.toString(),
      'units': 'metric',
      'appid': _apiKey,
    });

    final res = await _httpGet(url);
    
    // If 401, the daily endpoint requires paid subscription - throw to trigger fallback
    if (res.statusCode == 401) {
      throw HttpException('Daily forecast requires paid API subscription');
    }
    
    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (jsonMap['list'] as List<dynamic>?) ?? [];
      return list.map((e) => _weatherDayFromDailyJson(e as Map<String, dynamic>)).toList();
    }

    final body = res.body.isNotEmpty ? res.body : 'status ${res.statusCode}';
    throw HttpException('Daily forecast API error: ${res.statusCode} — $body');
  }

  // Fallback: aggregate 3-hour forecast into daily buckets
  Future<List<WeatherDay>> _fetchAndAggregate3HourForecast() async {
    final url = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'units': 'metric',
      'appid': _apiKey,
    });

    final res = await _httpGet(url);
    if (res.statusCode != 200) {
      final body = res.body.isNotEmpty ? res.body : 'status ${res.statusCode}';
      throw HttpException('3-hour forecast API error: ${res.statusCode} — $body');
    }

    final Map<String, dynamic> jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final List<dynamic> list = (jsonMap['list'] as List<dynamic>?) ?? [];

    // Group by local date string (yyyy-MM-dd)
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final dtVal = (map['dt'] is int) ? map['dt'] as int : int.tryParse(map['dt']?.toString() ?? '0') ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(dtVal * 1000, isUtc: true).toLocal();
      final key = DateFormat('yyyy-MM-dd').format(date);
      groups.putIfAbsent(key, () => []).add(map);
    }

    final aggregated = <WeatherDay>[];
    final sortedKeys = groups.keys.toList()..sort();
    for (final key in sortedKeys) {
      final bucket = groups[key]!;
      aggregated.add(_aggregateBucketToWeatherDay(bucket));
    }

    return aggregated;
  }

  // Ensure exactly 7 entries with unique dates
  List<WeatherDay> _ensureSevenDays(List<WeatherDay> days) {
    // Debug logging
    print('Input days count: ${days.length}');
    for (var i = 0; i < days.length; i++) {
      print('Day $i: ${DateFormat('yyyy-MM-dd EEEE').format(days[i].date)}');
    }
    
    if (days.isEmpty) {
      return List.generate(7, (index) {
        return WeatherDay(
          date: DateTime.now().add(Duration(days: index)),
          tempDay: 0,
          tempMin: 0,
          tempMax: 0,
          condition: 'Unknown',
          icon: '',
        );
      });
    }

    final out = <WeatherDay>[];
    final seenDates = <String>{};
    
    // Add unique days only
    for (final day in days) {
      final dateKey = DateFormat('yyyy-MM-dd').format(day.date);
      if (!seenDates.contains(dateKey)) {
        seenDates.add(dateKey);
        out.add(day);
        print('Added unique day: $dateKey');
      } else {
        print('Skipped duplicate day: $dateKey');
      }
      if (out.length >= 7) break;
    }
    
    // If still not enough days, pad with future days
    while (out.length < 7) {
      final lastDay = out.last;
      final nextDate = lastDay.date.add(Duration(days: 1));
      print('Padding day: ${DateFormat('yyyy-MM-dd').format(nextDate)}');
      out.add(WeatherDay(
        date: nextDate,
        tempDay: lastDay.tempDay,
        tempMin: lastDay.tempMin,
        tempMax: lastDay.tempMax,
        condition: lastDay.condition,
        icon: lastDay.icon,
      ));
    }
    
    print('Output days count: ${out.length}');
    for (var i = 0; i < out.length; i++) {
      print('Result $i: ${DateFormat('yyyy-MM-dd EEEE').format(out[i].date)}');
    }
    
    return out.take(7).toList();
  }

  WeatherDay _weatherDayFromDailyJson(Map<String, dynamic> json) {
    final dtVal = (json['dt'] is int) ? json['dt'] as int : int.tryParse(json['dt']?.toString() ?? '0') ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(dtVal * 1000, isUtc: true).toLocal();

    final temp = json['temp'] as Map<String, dynamic>? ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final weather = weatherList.isNotEmpty ? (weatherList.first as Map<String, dynamic>) : <String, dynamic>{};

    double parseNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return WeatherDay(
      date: date,
      tempDay: parseNum(temp['day']),
      tempMin: parseNum(temp['min']),
      tempMax: parseNum(temp['max']),
      condition: (weather['main'] ?? weather['description'] ?? 'Unknown').toString(),
      icon: (weather['icon'] ?? '').toString(),
    );
  }

  WeatherDay _aggregateBucketToWeatherDay(List<Map<String, dynamic>> bucket) {
    double tempSum = 0;
    double tempMin = double.infinity;
    double tempMax = -double.infinity;
    final Map<String, int> conditionCount = {};
    final Map<String, int> iconCount = {};
    DateTime? representativeDate;

    for (final item in bucket) {
      final dtVal = (item['dt'] is int) ? item['dt'] as int : int.tryParse(item['dt']?.toString() ?? '0') ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(dtVal * 1000, isUtc: true).toLocal();
      representativeDate ??= date;

      final main = item['main'] as Map<String, dynamic>? ?? {};
      final tempVal = main['temp'];
      final t = (tempVal is num) ? tempVal.toDouble() : double.tryParse(tempVal?.toString() ?? '0') ?? 0.0;
      tempSum += t;
      tempMin = t < tempMin ? t : tempMin;
      tempMax = t > tempMax ? t : tempMax;

      final weatherList = (item['weather'] as List<dynamic>?) ?? [];
      if (weatherList.isNotEmpty) {
        final w = weatherList.first as Map<String, dynamic>;
        final cond = (w['main'] ?? w['description'] ?? 'Unknown').toString();
        final icon = (w['icon'] ?? '').toString();
        conditionCount[cond] = (conditionCount[cond] ?? 0) + 1;
        iconCount[icon] = (iconCount[icon] ?? 0) + 1;
      }
    }

    final avgTemp = bucket.isNotEmpty ? tempSum / bucket.length : 0.0;
    String mostFreq(Map<String, int> m) {
      if (m.isEmpty) return '';
      return m.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    return WeatherDay(
      date: representativeDate ?? DateTime.now(),
      tempDay: avgTemp,
      tempMin: tempMin == double.infinity ? avgTemp : tempMin,
      tempMax: tempMax == -double.infinity ? avgTemp : tempMax,
      condition: mostFreq(conditionCount).isNotEmpty ? mostFreq(conditionCount) : 'Unknown',
      icon: mostFreq(iconCount),
    );
  }

  /// HTTP GET wrapper with timeout guard and nicer SocketException messages.
  Future<http.Response> _httpGet(Uri url) async {
    try {
      // Use the instance variable timeoutDuration
      final res = await http.get(url).timeout(timeoutDuration);
      return res;
    } on SocketException catch (e) {
      throw HttpException('No Internet connection: $e');
    } on http.ClientException catch (e) {
      throw HttpException('HTTP client error: $e');
    } on TimeoutException catch (e) {
      throw HttpException('Request timed out: $e');
    } on Exception {
      rethrow;
    }
  }

  static String iconUrl(String iconCode) =>
      iconCode.isNotEmpty ? 'https://openweathermap.org/img/wn/$iconCode@2x.png' : '';
}