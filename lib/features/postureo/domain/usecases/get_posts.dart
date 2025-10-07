import '../repositories/post_repository.dart';
import '../../../../models.dart';

class GetPosts {
  final PostRepository repository;

  GetPosts(this.repository);

  Future<List<Post>> call({int limit = 10, int offset = 0}) async {
    return await repository.getPosts(limit: limit, offset: offset);
  }
}