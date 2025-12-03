import 'package:bloc/bloc.dart';
import 'package:calendar_app/models/weather_day.dart';
import 'package:calendar_app/services/weather_api.dart';
import 'package:equatable/equatable.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApi api;

  WeatherBloc(this.api) : super(WeatherInitial()) {
    on<WeatherRequested>(_onRequested);
  }

  Future<void> _onRequested(WeatherRequested event, Emitter<WeatherState> emit) async {
    emit(WeatherLoadInProgress());
    try {
      final days = await api.fetch7DayForecast();
      if (days.isEmpty) {
        emit(WeatherLoadFailure('Empty response'));
      } else {
        emit(WeatherLoadSuccess(days));
      }
    } catch (e) {
      emit(WeatherLoadFailure(e.toString()));
    }
  }
}
