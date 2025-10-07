import 'package:flutter/material.dart';
import '../../domain/usecases/get_recursos.dart';
import '../../domain/entities/recurso.dart';

class BibliotecaProvider with ChangeNotifier {
  final GetRecursos getRecursos;
  List<Recurso> _recursos = [];
  bool _isLoading = false;
  String? _error;

  BibliotecaProvider(this.getRecursos);

  List<Recurso> get recursos => _recursos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecursos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recursos = await getRecursos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}