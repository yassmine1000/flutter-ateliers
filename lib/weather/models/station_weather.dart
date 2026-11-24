class StationWeather {
  const StationWeather({
    required this.name,
    required this.temperature,
    required this.windSpeed,
    required this.time,
  });

  final String name;
  final double temperature; // °C
  final double windSpeed; // km/h
  final String time; // horodatage de la mesure, fourni par l'API

  Map<String, dynamic> toJson() => {
        'name': name,
        'temperature': temperature,
        'windSpeed': windSpeed,
        'time': time,
      };

  factory StationWeather.fromJson(Map<String, dynamic> json) => StationWeather(
        name: json['name'] as String,
        temperature: (json['temperature'] as num).toDouble(),
        windSpeed: (json['windSpeed'] as num).toDouble(),
        time: json['time'] as String,
      );
}
