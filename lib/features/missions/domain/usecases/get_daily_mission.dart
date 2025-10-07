import '../entities/mission.dart';
import '../../data/repositories/mission_repository.dart';

class GetDailyMission {
  final MissionRepository repository;

  GetDailyMission(this.repository);

  Mission call(int day) {
    return repository.getDailyMission(day);
  }
}

class CompleteMission {
  final MissionRepository repository;

  CompleteMission(this.repository);

  Future<void> call(User user) async {
    user.diasCompletados++;
    user.puntos += 1;
    user.misionesCompletadas.add(user.diasCompletados); // Ajustar
    // Actualizar cinturón
    final cinturones = [
      Cinturon(nombre: 'Blanco', diasRequeridos: 0),
      Cinturon(nombre: 'Amarillo', diasRequeridos: 7),
      Cinturon(nombre: 'Naranja', diasRequeridos: 14),
      Cinturon(nombre: 'Verde', diasRequeridos: 21),
      Cinturon(nombre: 'Marrón', diasRequeridos: 28),
      Cinturon(nombre: 'Negro', diasRequeridos: 35),
      Cinturon(nombre: 'Sobrado', diasRequeridos: 42),
    ];
    for (var cinturon in cinturones.reversed) {
      if (user.diasCompletados >= cinturon.diasRequeridos) {
        user.cinturonActual = cinturon.nombre;
        break;
      }
    }
    await repository.saveUser(user);
  }
}

class GetUser {
  final MissionRepository repository;

  GetUser(this.repository);

  Future<User> call() {
    return repository.getUser();
  }
}

class SaveUser {
  final MissionRepository repository;

  SaveUser(this.repository);

  Future<void> call(User user) {
    return repository.saveUser(user);
  }
}

class GetAllMissions {
  final MissionRepository repository;

  GetAllMissions(this.repository);

  List<Mission> call() {
    return repository.getAllMissions();
  }
}