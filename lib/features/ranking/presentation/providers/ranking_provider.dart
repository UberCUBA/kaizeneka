import 'package:flutter/material.dart';
import '../../domain/usecases/get_top_users.dart';
import '../../../map/domain/entities/kaizeneka_user.dart';

class RankingProvider extends ChangeNotifier {
  List<KaizenekaUser> _topUsers = [];
  bool _isLoading = false;

  List<KaizenekaUser> get topUsers => _topUsers;
  bool get isLoading => _isLoading;

  final GetTopUsers _getTopUsers;

  RankingProvider(this._getTopUsers);

  Future<void> loadTopUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _topUsers = await _getTopUsers();
    } catch (e) {
      _topUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}