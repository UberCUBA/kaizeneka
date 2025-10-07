import '../entities/recurso.dart';

abstract class RecursoRepository {
  Future<List<Recurso>> getRecursos();
}