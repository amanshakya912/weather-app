import 'package:calendar_app/models/weather_day.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherDetailSheet extends StatelessWidget {
  final WeatherDay day;
  const WeatherDetailSheet({super.key, required this.day});

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
    final date = DateFormat('EEEE, MMMM dd, yyyy').format(day.date);
    final weatherColor = _getWeatherColor(day.condition);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main weather display
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          weatherColor.withOpacity(0.2),
                          weatherColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: weatherColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Weather icon
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: weatherColor.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getWeatherIcon(day.condition),
                                  size: 80,
                                  color: weatherColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                day.condition,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Temperature
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${day.tempDay.round()}°',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Celsius',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Temperature range cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context: context,
                          icon: Icons.thermostat_rounded,
                          iconColor: Colors.red,
                          label: 'High',
                          value: '${day.tempMax.round()}°',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          context: context,
                          icon: Icons.ac_unit_rounded,
                          iconColor: Colors.blue,
                          label: 'Low',
                          value: '${day.tempMin.round()}°',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Additional info section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Weather Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value: DateFormat('MMM dd, yyyy').format(day.date),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          icon: Icons.wb_twilight_rounded,
                          label: 'Average Temperature',
                          value: '${day.tempDay.round()}°C',
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          icon: Icons.cloud_rounded,
                          label: 'Condition',
                          value: day.condition,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}