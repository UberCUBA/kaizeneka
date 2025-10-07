import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mission_model.dart';
import '../../domain/entities/mission.dart';

abstract class MissionRepository {
  Future<User> getUser();
  Future<void> saveUser(User user);
  List<Mission> getAllMissions();
  Mission getDailyMission(int day);
}

class MissionRepositoryImpl implements MissionRepository {
  final SharedPreferences prefs;

  MissionRepositoryImpl(this.prefs);

  @override
  Future<User> getUser() async {
    final userJson = prefs.getString('usuario');
    if (userJson != null) {
      final userModel = UserModel.fromJson(json.decode(userJson));
      return userModel.toEntity();
    }
    return User();
  }

  @override
  Future<void> saveUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await prefs.setString('usuario', json.encode(userModel.toJson()));
  }

  @override
  List<Mission> getAllMissions() {
    return _missions;
  }

  @override
  Mission getDailyMission(int day) {
    return _missions[(day - 1) % _missions.length];
  }

  final List<Mission> _missions = [
    Mission(id: 1, descripcion: 'Haz 14h de ayuno intermitente', categoria: 'Salud-Fitness', beneficio: 'Optimiza energía, autofagia y disciplina'),
    Mission(id: 2, descripcion: '20 min de vaina protectora (musculación básica)', categoria: 'Salud-Fitness', beneficio: 'Más fuerza, testosterona y atractivo'),
    Mission(id: 3, descripcion: 'Paseo circadianizador 15 min al sol', categoria: 'Salud-Fitness', beneficio: 'Regula biorritmos, vitamina D, ánimo'),
    Mission(id: 4, descripcion: 'Cena sin ultraprocesados', categoria: 'Salud-Fitness', beneficio: 'Mejor digestión, menos inflamación'),
    Mission(id: 5, descripcion: 'Acuéstate 30 min antes', categoria: 'Salud-Fitness', beneficio: 'Lucras sueño → más salud y ganasolina'),
    Mission(id: 6, descripcion: 'Haz 10 burpees al despertarte', categoria: 'Salud-Fitness', beneficio: 'Activas cuerpo y foco inmediato'),
    Mission(id: 7, descripcion: 'Ducha fría 1 min', categoria: 'Salud-Fitness', beneficio: 'Hormesis, dopamina, resiliencia'),
    Mission(id: 8, descripcion: 'Haz 10.000 pasos sin móvil', categoria: 'Salud-Fitness', beneficio: 'Salud cardiovascular + foco mental'),
    Mission(id: 9, descripcion: 'Cambia un snack basura por fruta o frutos secos', categoria: 'Salud-Fitness', beneficio: 'Nutrición densa, energía estable'),
    Mission(id: 10, descripcion: 'Levántate cada hora para estirarte', categoria: 'Salud-Fitness', beneficio: 'Evita rigidez, activa circulación'),
    Mission(id: 11, descripcion: 'Sonríe a 3 desconocidos', categoria: 'Amor-Relaciones', beneficio: 'Socialización + confianza'),
    Mission(id: 12, descripcion: 'Contacto visual 3 seg + sonrisa', categoria: 'Amor-Relaciones', beneficio: 'Aumenta tu VMS (valor de mercado sexual)'),
    Mission(id: 13, descripcion: 'Envía un mensaje de gratitud', categoria: 'Amor-Relaciones', beneficio: 'Refuerzas vínculos y ánimo'),
    Mission(id: 14, descripcion: 'Haz una llamada en vez de WhatsApp', categoria: 'Amor-Relaciones', beneficio: 'Conexión más real y profunda'),
    Mission(id: 15, descripcion: 'Escucha 5 min sin interrumpir', categoria: 'Amor-Relaciones', beneficio: 'Empatía + atracción social'),
    Mission(id: 16, descripcion: 'Da un cumplido sincero', categoria: 'Amor-Relaciones', beneficio: 'Generas buen rollo instantáneo'),
    Mission(id: 17, descripcion: 'Micro-flirteo con humor', categoria: 'Amor-Relaciones', beneficio: 'Practicas juego social sin presión'),
    Mission(id: 18, descripcion: 'Reencuadra un problema en clave de juego', categoria: 'Amor-Relaciones', beneficio: 'Ganasolina emocional, reduces drama'),
    Mission(id: 19, descripcion: 'Saluda a alguien nuevo', categoria: 'Amor-Relaciones', beneficio: 'Expansión de red social'),
    Mission(id: 20, descripcion: 'Pide feedback honesto', categoria: 'Amor-Relaciones', beneficio: 'Aumenta aprendizaje y humildad atractiva'),
    Mission(id: 21, descripcion: '30 min de absortismo (podcast/libro mientras entrenas/cocinas)', categoria: 'Trabajo-Finanzas', beneficio: 'Aprendes y entrenas a la vez'),
    Mission(id: 22, descripcion: 'Escribe tus 3 OVCs de la semana', categoria: 'Trabajo-Finanzas', beneficio: 'Claridad, foco y priorización'),
    Mission(id: 23, descripcion: 'Elimina una RDP (rendija de palme)', categoria: 'Trabajo-Finanzas', beneficio: 'Cierras fugas de tiempo/dinero'),
    Mission(id: 24, descripcion: '25 min de trabajo profundo (pomodoro)', categoria: 'Trabajo-Finanzas', beneficio: 'Avance real en proyectos clave'),
    Mission(id: 25, descripcion: 'Escribe 5 ideas para generar ingresos extra (CDLs)', categoria: 'Trabajo-Finanzas', beneficio: 'Activas mentalidad de abundancia'),
    Mission(id: 26, descripcion: 'Lee 10 min sobre tu sector', categoria: 'Trabajo-Finanzas', beneficio: 'Acumulas claves de poder'),
    Mission(id: 27, descripcion: 'Desinstala o limita una app palmante', categoria: 'Trabajo-Finanzas', beneficio: 'Recuperas tiempo y foco'),
    Mission(id: 28, descripcion: 'Haz 2h de apagón digital', categoria: 'Trabajo-Finanzas', beneficio: 'Deep work + detox mental'),
    Mission(id: 29, descripcion: 'Haz networking (contacto nuevo LinkedIn/persona)', categoria: 'Trabajo-Finanzas', beneficio: 'Amplías oportunidades y CDLs'),
    Mission(id: 30, descripcion: 'Lista tus 5 RDPs más gordas + plan para sellarlas', categoria: 'Trabajo-Finanzas', beneficio: 'Estrategia defensiva de sobrado'),
  ];
}