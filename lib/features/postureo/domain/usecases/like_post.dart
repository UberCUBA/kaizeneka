import '../repositories/post_repository.dart';

class LikePost {
  final PostRepository repository;

  LikePost(this.repository);

  Future<void> call(int postId) async {
    return await repository.likePost(postId);
  }
}