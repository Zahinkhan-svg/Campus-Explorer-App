import 'dart:async';
import 'dart:math';
import 'dart:io';


Future<Map<String, dynamic>> fetchWeatherData(String city) async {
  await Future.delayed(const Duration(seconds: 2));
 
  final random = Random();
  final temperature = 15 + random.nextInt(21); // 15-35°C
  final conditions = ['Sunny', 'Rainy', 'Cloudy', 'Windy', 'Foggy'];
  final condition = conditions[random.nextInt(conditions.length)];
 
  return {
    'city': city,
    'temperature': temperature,
    'condition': condition,
    'timestamp': DateTime.now().toIso8601String(),
  };
}


Future<List<Map<String, dynamic>>> fetchMultipleCities(List<String> cities) async {
  try {
    final futures = cities.map((city) => fetchWeatherData(city)).toList();
    final results = await Future.wait(futures);
    return results;
  } catch (e) {
    print('Error fetching multiple cities: $e');
    return [];
  }
}


Stream<String> weatherUpdates(String city) {
  final random = Random();
  return Stream.periodic(const Duration(seconds: 2), (count) {
    if (count >= 5) {
      throw Exception('Stream completed');
    }
    final temp = 15 + random.nextInt(21);
    return 'City: $city, Temp: $temp°C, Time: ${DateTime.now()}';
  }).take(5).asBroadcastStream();
}


Future<void> main() async {
  print('🌤️ Weather App Demo Starting...');
  print('');


  try {
    // Fetch weather for multiple cities concurrently
    final cities = ['London', 'New York', 'Tokyo', 'Sydney'];
    print('Fetching weather for cities: $cities');
    print('⏳ Simulating API calls (2s delay each)...');
   
    final results = await fetchMultipleCities(cities);
   
    print('\n✅ Weather data received concurrently:');
    for (final data in results) {
      print('  ${data['city']}: ${data['temperature']}°C, ${data['condition']}');
    }
    print('');


    // Listen to weather stream for London
    print('📡 Listening to London weather updates (every 2s, 5 updates):');
    final londonStream = weatherUpdates('London');
    await for (final update in londonStream) {
      print('  $update');
    }
    print('\n✨ Stream completed successfully!');
   
  } catch (e) {
    print('❌ Error in demo: $e');
  }
}
