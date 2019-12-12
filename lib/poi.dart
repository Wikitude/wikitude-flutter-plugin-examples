import 'package:json_annotation/json_annotation.dart';

part 'poi.g.dart';

@JsonSerializable()
class Poi {

  int id;
  double longitude;
  double latitude;
  String description;
  double altitude;
  String name;

  Poi(this.id, this.longitude, this.latitude, this.description, this.altitude, this.name);

  factory Poi.fromJson(Map<String, dynamic> json) => _$PoiFromJson(json);

  Map<String, dynamic> toJson() => _$PoiToJson(this);
}