import '../repositories/post_repository.dart';
import '../../../../models.dart';

class CreatePost {
  final PostRepository repository;

  CreatePost(this.repository);

  Future<void> call(Post post) async {
    return await repository.createPost(post);
  }
}