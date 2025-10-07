import 'package:latlong2/latlong.dart';

class KaizenekaUser {
  final String id;
  final String name;
  final String belt; // cinturón
  final int points;
  final LatLng location;
  final String? email;
  final String? avatarUrl;

  KaizenekaUser({
    required this.id,
    required this.name,
    required this.belt,
    required this.points,
    required this.location,
    this.email,
    this.avatarUrl,
  });

  factory KaizenekaUser.fromJson(Map<String, dynamic> json) {
    return KaizenekaUser(
      id: json['id'],
      name: json['name'],
      belt: json['belt'],
      points: json['points'],
      location: LatLng(json['lat'], json['lng']),
      email: json['email'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'belt': belt,
      'points': points,
      'lat': location.latitude,
      'lng': location.longitude,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }
}