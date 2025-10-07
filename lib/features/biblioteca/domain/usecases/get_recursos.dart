import '../repositories/recurso_repository.dart';
import '../entities/recurso.dart';

class GetRecursos {
  final RecursoRepository repository;

  GetRecursos(this.repository);

  Future<List<Recurso>> call() async {
    return await repository.getRecursos();
  }
}