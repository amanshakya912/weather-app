import 'package:calendar_app/blocs/weather_bloc.dart';
import 'package:calendar_app/services/weather_api.dart';
import 'package:calendar_app/src/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherApi = WeatherApi();
    return BlocProvider(
      create: (_) => WeatherBloc(weatherApi)..add(WeatherRequested()),
      child: MaterialApp(
        title: '7-Day Weather',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomePage(),
      ),
    );
  }
}
