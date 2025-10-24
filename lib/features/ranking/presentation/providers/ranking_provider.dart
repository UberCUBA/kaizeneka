import 'package:flutter/material.dart';
import '../../domain/usecases/get_top_users.dart';
import '../../../map/domain/entities/kaizeneka_user.dart';

class RankingProvider extends ChangeNotifier {
  List<KaizenekaUser> _topUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<KaizenekaUser> get topUsers => _topUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final GetTopUsers _getTopUsers;

  RankingProvider(this._getTopUsers);

  Future<void> loadTopUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _topUsers = await _getTopUsers();
    } catch (e) {
      _topUsers = [];
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        _errorMessage = '¡Upsss!! Algo va Mal!! Revise su conexión a Internet!!';
      } else {
        _errorMessage = 'Error al cargar el ranking: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}