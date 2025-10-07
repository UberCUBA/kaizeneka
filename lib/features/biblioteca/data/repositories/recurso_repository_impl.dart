import '../../../../core/services/supabase_service.dart';
import '../../domain/repositories/recurso_repository.dart';
import '../models/recurso_model.dart';
import '../../domain/entities/recurso.dart';

class RecursoRepositoryImpl implements RecursoRepository {
  @override
  Future<List<Recurso>> getRecursos() async {
    try {
      final response = await SupabaseService.client
          .from('recursos')
          .select('*');

      return response.map((json) => RecursoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar recursos: $e');
    }
  }
}