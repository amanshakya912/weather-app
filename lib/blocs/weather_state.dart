part of 'weather_bloc.dart';
abstract class WeatherState extends Equatable {
  const WeatherState();
  @override List<Object?> get props => [];
}
class WeatherInitial extends WeatherState {}
class WeatherLoadInProgress extends WeatherState {}
class WeatherLoadSuccess extends WeatherState {
  final List<WeatherDay> days;
  const WeatherLoadSuccess(this.days);
  @override List<Object?> get props => [days];
}
class WeatherLoadFailure extends WeatherState {
  final String message;
  const WeatherLoadFailure(this.message);
  @override List<Object?> get props => [message];
}
