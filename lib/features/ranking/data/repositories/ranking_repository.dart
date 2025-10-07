import '../../../map/domain/entities/kaizeneka_user.dart';
import '../../../../core/services/supabase_service.dart';

abstract class RankingRepository {
  Future<List<KaizenekaUser>> getTopUsers();
}

class SupabaseRankingRepository implements RankingRepository {
  @override
  Future<List<KaizenekaUser>> getTopUsers() async {
    try {
      // Obtener top 10 usuarios ordenados por puntos
      final response = await SupabaseService.client
          .from('users')
          .select('id, name, belt, points, lat, lng, updated_at, email, avatar_url')
          .order('points', ascending: false)
          .limit(10);

      return response.map((json) => KaizenekaUser.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}