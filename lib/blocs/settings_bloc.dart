import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class SettingEvent extends Equatable {}

class TemperatureUnitsToggled extends SettingEvent {}

enum TemperatureUnits { fahrenheit, celsius }

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  SettingsState({@required this.temperatureUnits})
      : assert(temperatureUnits != null),
        super([temperatureUnits]);
}

class SettingsBloc extends Bloc<SettingEvent, SettingsState> {
  @override
  SettingsState get initialState {
    return SettingsState(temperatureUnits: TemperatureUnits.celsius);
  }

  @override
  Stream<SettingsState> mapEventToState(SettingEvent event) async* {
    if (event is TemperatureUnitsToggled) {
      yield SettingsState(
        temperatureUnits:
            currentState.temperatureUnits == TemperatureUnits.celsius
                ? TemperatureUnits.fahrenheit
                : TemperatureUnits.celsius,
      );
    }
  }
}
