import 'package:latlong2/latlong.dart';
import '../entities/kaizeneka_user.dart';
import '../../data/repositories/map_repository.dart';

class GetNearbyUsers {
  final MapRepository repository;

  GetNearbyUsers(this.repository);

  Future<List<KaizenekaUser>> call(LatLng userLocation) {
    return repository.getNearbyUsers(userLocation);
  }
}