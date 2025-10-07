import '../../domain/entities/recurso.dart';

class RecursoModel extends Recurso {
  RecursoModel({
    required super.id,
    required super.titulo,
    required super.tipo,
    required super.url,
  });

  factory RecursoModel.fromJson(Map<String, dynamic> json) {
    return RecursoModel(
      id: json['id'],
      titulo: json['titulo'],
      tipo: json['tipo'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo,
      'url': url,
    };
  }
}