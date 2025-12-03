import 'package:equatable/equatable.dart';

class WeatherDay extends Equatable {
  final DateTime date;
  final double tempDay; // Celsius
  final double tempMin;
  final double tempMax;
  final String condition;
  final String icon; // icon code from API

  const WeatherDay({
    required this.date,
    required this.tempDay,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.icon,
  });

  @override
  List<Object?> get props => [date, tempDay, tempMin, tempMax, condition, icon];

  factory WeatherDay.fromOpenWeatherMapJson(Map<String, dynamic> json) {
    final dt = DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000, isUtc: true).toLocal();
    final temp = json['temp'];
    final weather = (json['weather'] as List).first;
    double parseTemp(dynamic t) => (t is int) ? t.toDouble() : (t ?? 0.0);
    return WeatherDay(
      date: dt,
      tempDay: parseTemp(temp['day'] ?? temp['day'] ?? 0.0),
      tempMin: parseTemp(temp['min'] ?? 0.0),
      tempMax: parseTemp(temp['max'] ?? 0.0),
      condition: weather['main'] ?? weather['description'] ?? 'Unknown',
      icon: weather['icon'] ?? '',
    );
  }
}
