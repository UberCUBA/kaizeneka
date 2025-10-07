import '../../../../core/services/supabase_service.dart';
import '../../domain/repositories/post_repository.dart';
import '../../../../models.dart';

class PostRepositoryImpl implements PostRepository {
  @override
  Future<List<Post>> getPosts({int limit = 10, int offset = 0}) async {
    try {
      final response = await SupabaseService.client
          .from('posts')
          .select('*')
          .order('timestamp', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar posts: $e');
    }
  }

  @override
  Future<void> likePost(int postId) async {
    try {
      // Incrementar likes en la base de datos usando rpc o update directo
      await SupabaseService.client.rpc('increment_likes', params: {'post_id': postId});
    } catch (e) {
      throw Exception('Error al dar like al post: $e');
    }
  }

  @override
  Future<void> createPost(Post post) async {
    try {
      final user = SupabaseService.getCurrentUser();
      if (user == null) throw Exception('Usuario no autenticado');

      final postData = post.toJson();
      postData['user_id'] = user.id;

      await SupabaseService.client
          .from('posts')
          .insert(postData);
    } catch (e) {
      throw Exception('Error al crear post: $e');
    }
  }
}