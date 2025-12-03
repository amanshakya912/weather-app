import 'package:calendar_app/models/weather_day.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayCard extends StatelessWidget {
  final WeatherDay day;
  final bool isToday;

  const DayCard({
    super.key,
    required this.day,
    this.isToday = false,
  });

  IconData _getWeatherIcon(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('clear') || cond.contains('sunny')) {
      return Icons.wb_sunny_rounded;
    } else if (cond.contains('cloud')) {
      return Icons.cloud_rounded;
    } else if (cond.contains('rain') || cond.contains('drizzle')) {
      return Icons.water_drop_rounded;
    } else if (cond.contains('storm') || cond.contains('thunder')) {
      return Icons.thunderstorm_rounded;
    } else if (cond.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (cond.contains('mist') || cond.contains('fog')) {
      return Icons.foggy;
    }
    return Icons.wb_cloudy_rounded;
  }

  Color _getWeatherColor(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('clear') || cond.contains('sunny')) {
      return Colors.orange;
    } else if (cond.contains('rain') || cond.contains('drizzle')) {
      return Colors.blue;
    } else if (cond.contains('storm') || cond.contains('thunder')) {
      return Colors.deepPurple;
    } else if (cond.contains('snow')) {
      return Colors.lightBlue;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE').format(day.date);
    final dateStr = DateFormat('MMM dd').format(day.date);
    final weatherColor = _getWeatherColor(day.condition);

    return Container(
      decoration: BoxDecoration(
        gradient: isToday
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[400]!,
                ],
              )
            : null,
        color: isToday ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isToday 
                ? Colors.blue.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: isToday ? 16 : 12,
            offset: Offset(0, isToday ? 6 : 4),
          ),
        ],
        border: Border.all(
          color: isToday ? Colors.transparent : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Left side - Date
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  if (isToday) const SizedBox(height: 8),
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: isToday 
                          ? Colors.white.withOpacity(0.85)
                          : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Center - Weather icon and condition
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.white.withOpacity(0.2)
                          : weatherColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getWeatherIcon(day.condition),
                      size: 48,
                      color: isToday ? Colors.white : weatherColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day.condition,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right side - Temperature
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.tempDay.round()}°',
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.grey[800],
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: 12,
                        color: isToday
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[500],
                      ),
                      Text(
                        '${day.tempMin.round()}°',
                        style: TextStyle(
                          color: isToday
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 12,
                        color: isToday
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[500],
                      ),
                      Text(
                        '${day.tempMax.round()}°',
                        style: TextStyle(
                          color: isToday
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}