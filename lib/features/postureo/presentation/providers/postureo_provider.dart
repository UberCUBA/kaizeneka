import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/like_post.dart';
import '../../domain/usecases/create_post.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../models.dart';

class PostureoProvider with ChangeNotifier {
  final GetPosts getPosts;
  final LikePost likePost;
  final CreatePost createPost;
  final AuthProvider authProvider;

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  PostureoProvider(this.getPosts, this.likePost, this.createPost, this.authProvider) {
    authProvider.addListener(_onAuthChanged);
  }

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    _hasMore = true;
    notifyListeners();

    try {
      _posts = await getPosts(limit: 10, offset: 0);
      _hasMore = _posts.length == 10;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMorePosts() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newPosts = await getPosts(limit: 10, offset: _posts.length);
      _posts.addAll(newPosts);
      _hasMore = newPosts.length == 10;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, BuildContext context) async {
    try {
      await likePost(postId);
      final post = _posts.firstWhere((p) => p.id == postId);
      post.likes += 1;
      post.likedByUser = true;

      // Suma 1 punto por like usando MissionProvider
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      missionProvider.addPoints(context, 1);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addPost(Post post) async {
    try {
      await createPost(post);
      _posts.insert(0, post);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _onAuthChanged() {
    if (authProvider.isAuthenticated) {
      // Refetch posts when user changes
      fetchPosts();
    } else {
      // Clear posts when logged out
      _posts = [];
      _hasMore = true;
      _error = null;
      notifyListeners();
    }
  }
}