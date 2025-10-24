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
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        throw Exception('¡Upsss!! Algo va Mal!! Revise su conexión a Internet!!');
      } else {
        throw Exception('Error al cargar recursos: $e');
      }
    }
  }
}