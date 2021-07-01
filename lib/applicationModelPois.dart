import 'dart:math';

import 'package:location/location.dart';

import 'poi.dart';

class ApplicationModelPois {
  static Future<List<Poi>> prepareApplicationDataModel() async {
    final Random random = new Random();
    final int min = 1;
    final int max = 10;
    final int placesAmount = 10;
    final Location location = new Location();

    List<Poi> pois = <Poi>[];
    try {
      LocationData userLocation = await location.getLocation();
      for (int i = 0; i < placesAmount; i++) {
        pois.add(new Poi(i+1, userLocation.longitude! + 0.001 * (5 - min + random.nextInt(max - min)), userLocation.latitude! + 0.001 * (5 - min + random.nextInt(max - min)), 'This is the description of POI#' + (i+1).toString(), userLocation.altitude!, 'POI#' + (i+1).toString()));
      }
    } catch(e) {
      print("Location Error: " + e.toString());
    }
    return pois;
  }
}