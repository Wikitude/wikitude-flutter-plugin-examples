import 'dart:math';

import 'package:location/location.dart';

import 'poi.dart';

class ApplicationModelPois {

  final _random = new Random();
  int min = 1;
  int max = 10;

  List<Poi> pois;
  int placesAmount = 10;

  ApplicationModelPois() {
    pois = new List();
  }

  Future<List<Poi>> prepareApplicationDataModel() async {
    Location location = new Location();
    try {
      LocationData userLocation = await location.getLocation();
      for (int i = 0; i < placesAmount; i++) {
        pois.add(new Poi(i+1, userLocation.longitude + 0.001 * (5 - min + _random.nextInt(max - min)), userLocation.latitude + 0.001 * (5 - min + _random.nextInt(max - min)), 'This is the description of POI#' + (i+1).toString(), userLocation.altitude, 'POI#' + (i+1).toString()));
      }
    } catch(e) {
      print("Location Error: " + e.toString());
    }
    return pois;
  }
}