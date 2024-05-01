import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_application/api/weather_model_api.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final weatherModel = WeatherModel('710809494590862ac83c4f6576feadfd');
  final cityController = TextEditingController();
  dynamic weatherData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherDataForCurrentLocation();
  }

  void _fetchWeatherDataForCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      weatherModel
          .getWeatherDataByCoordinates(
              position.latitude.toString(), position.longitude.toString())
          .then((data) {
        setState(() {
          weatherData = data;
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          weatherData = null;
          isLoading = false;
        });
        _showErrorDialog('Failed to load weather data. Please try again.');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to get current location. Please try again.');
    }
  }

  void _fetchWeatherData(String city) {
    setState(() {
      isLoading = true;
    });

    weatherModel.getWeatherData(city).then((data) {
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        weatherData = null;
        isLoading = false;
      });
      _showErrorDialog('Failed to load weather data. Please try again.');
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        elevation: 8,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        // Wrap your Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: TextField(
                      controller: cityController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Enter city name',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          color: Colors.grey,
                          onPressed: () =>
                              _fetchWeatherData(cityController.text),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
              if (isLoading)
                CircularProgressIndicator()
              else if (weatherData != null)
                _buildWeatherInfo(weatherData)
              else
                Text(
                    'Enter a city name or fetch weather for your current location.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(dynamic weather) {
    if (weather != null) {
      final cityName = weather['name'];
      final temperature = weather['main']['temp'];
      final description = weather['weather'][0]['description'];

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent, // Set light blue background color
          borderRadius: BorderRadius.circular(10), // Apply border radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                cityName,
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                'Today',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 30),
              Icon(Icons.wb_sunny, size: 80, color: Colors.yellow),
              SizedBox(height: 20),
              Text(
                '$temperature°C',
                style: TextStyle(fontSize: 70, color: Color(0xFF3744AA)),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                DateFormat("h:mm a").format(DateTime.now()),
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                DateFormat("EEEE").format(DateTime.now()),
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 30),
              _buildWeatherForecast(weather),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildWeatherForecast(dynamic weather) {
    final staticData = [
      {
        'dateTime': DateTime.now().add(Duration(days: 1)),
        'temp': 25,
        'weatherDescription': 'Sunny',
      },
      {
        'dateTime': DateTime.now().add(Duration(days: 2)),
        'temp': 22,
        'weatherDescription': 'Cloudy',
      },
      {
        'dateTime': DateTime.now().add(Duration(days: 3)),
        'temp': 20,
        'weatherDescription': 'Rainy',
      },
    ];

    return Container(
      height: 150,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: staticData.map((item) {
            final dateTime = item['dateTime'];
            final temp = item['temp'];
            final weatherDescription = item['weatherDescription'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                color: Color(0xFF3744AA),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: 120, // Set a fixed width for each item
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${DateFormat("EEEE").format(DateTime.now())}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Icon(Icons.wb_sunny, size: 40, color: Colors.yellow),
                        SizedBox(height: 5),
                        Text(
                          '$temp°C',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
