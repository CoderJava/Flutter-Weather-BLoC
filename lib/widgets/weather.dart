import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_weather/blocs/blocs.dart';

import 'city_selection.dart';
import 'combined_weather_temperature.dart';
import 'gradient_container.dart';
import 'last_updated.dart';
import 'location.dart';
import 'settings.dart';

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Weather'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Settings();
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CitySelection();
                  },
                ),
              );
              if (city != null) {
                weatherBloc.dispatch(FetchWeather(city: city));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: BlocListener(
          bloc: weatherBloc,
          listener: (BuildContext context, WeatherState state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<ThemeBloc>(context).dispatch(
                WeatherChanged(condition: state.weather.condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          child: BlocBuilder(
            bloc: weatherBloc,
            builder: (_, WeatherState state) {
              if (state is WeatherEmpty) {
                return Center(child: Text('Please select a location'));
              }
              if (state is WeatherLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is WeatherLoaded) {
                final weather = state.weather;

                return BlocBuilder(
                  bloc: BlocProvider.of<ThemeBloc>(context),
                  builder: (_, ThemeState themeState) {
                    return GradientContainer(
                      color: themeState.color,
                      child: RefreshIndicator(
                        onRefresh: () {
                          weatherBloc.dispatch(
                            RefreshWeather(city: weather.location),
                          );
                          return _refreshCompleter.future;
                        },
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: Location(location: weather.location),
                              ),
                            ),
                            Center(
                              child: LastUpdated(dateTime: weather.lastUpdated),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: Center(
                                child: CombinedWeatherTemperature(
                                    weather: weather),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              if (state is WeatherError) {
                return Text(
                  'Something went wrong!',
                  style: TextStyle(color: Colors.red),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
