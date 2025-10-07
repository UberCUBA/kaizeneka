import '../../../../models.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts({int limit = 10, int offset = 0});
  Future<void> likePost(int postId);
  Future<void> createPost(Post post);
}