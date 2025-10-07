import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/kaizeneka_user.dart';
import '../../../../core/services/supabase_service.dart';

abstract class MapRepository {
  Future<List<KaizenekaUser>> getNearbyUsers(LatLng userLocation);
}

class SupabaseMapRepository implements MapRepository {
  @override
  Future<List<KaizenekaUser>> getNearbyUsers(LatLng userLocation) async {
    try {
      // Obtener todos los usuarios con ubicación
      final response = await SupabaseService.client
          .from('users')
          .select('id, name, belt, points, lat, lng, updated_at, email, avatar_url')
          .not('lat', 'is', null)
          .not('lng', 'is', null);

      List<KaizenekaUser> allUsers = [];
      for (var userJson in response) {
        // Filtrar usuarios en línea (actualizados en las últimas 24 horas)
        final updatedAt = DateTime.parse(userJson['updated_at']);
        final now = DateTime.now();
        if (now.difference(updatedAt).inHours < 24) {
          allUsers.add(KaizenekaUser.fromJson(userJson));
        }
      }

      // Filtrar usuarios cercanos (dentro de 10 km)
      List<KaizenekaUser> nearbyUsers = [];
      for (var user in allUsers) {
        double distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          user.location.latitude,
          user.location.longitude,
        );
        if (distance <= 10000) { // 10 km
          nearbyUsers.add(user);
        }
      }

      return nearbyUsers;
    } catch (e) {
      // En caso de error, devolver lista vacía
      return [];
    }
  }
}