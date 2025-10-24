import '../../../map/domain/entities/kaizeneka_user.dart';
import '../../../../core/services/supabase_service.dart';

abstract class RankingRepository {
  Future<List<KaizenekaUser>> getTopUsers();
}

class SupabaseRankingRepository implements RankingRepository {
  @override
  Future<List<KaizenekaUser>> getTopUsers() async {
    try {
      // Obtener top 10 usuarios con puntos > 0 ordenados por puntos
      final response = await SupabaseService.client
          .from('users')
          .select('id, name, belt, points, lat, lng, updated_at, email, avatar_url')
          .gt('points', 0)
          .order('points', ascending: false)
          .limit(10);

      return response.map((json) => KaizenekaUser.fromJson(json)).toList();
    } catch (e) {
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        // Para ranking, devolver lista vacía silenciosamente en caso de error de conexión
        return [];
      } else {
        return [];
      }
    }
  }
}