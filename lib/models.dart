// Legacy exports for backward compatibility
// TODO: Update imports to use domain/entities directly

export 'domain/entities/mission.dart';
export 'domain/entities/user.dart';
export 'domain/entities/belt.dart';
export 'domain/entities/achievement.dart';
export 'domain/entities/post.dart';

// Import for typedefs
import 'domain/entities/mission.dart';
import 'domain/entities/user.dart';
import 'domain/entities/belt.dart';
import 'domain/entities/achievement.dart';
import 'domain/entities/post.dart';

// Type aliases for backward compatibility
typedef Mision = Mission;
typedef Usuario = User;
typedef Cinturon = Belt;
typedef Logro = Achievement;

// Hardcoded belts for now (TODO: move to Supabase)
final List<Cinturon> cinturones = [
  Cinturon(nombre: 'Blanco', diasRequeridos: 0),
  Cinturon(nombre: 'Amarillo', diasRequeridos: 7),
  Cinturon(nombre: 'Naranja', diasRequeridos: 14),
  Cinturon(nombre: 'Verde', diasRequeridos: 21),
  Cinturon(nombre: 'Marrón', diasRequeridos: 28),
  Cinturon(nombre: 'Negro', diasRequeridos: 35),
  Cinturon(nombre: 'Sobrado', diasRequeridos: 42),
];

// Hardcoded achievements for now (TODO: move to Supabase)
List<Logro> logros = [
  Logro(
    nombre: 'No palmarás en vano',
    descripcion: '7 días seguidos sin fallar',
    check: (usuario) => usuario.diasCompletados >= 7,
  ),
  Logro(
    nombre: 'Cazador de RDPs',
    descripcion: 'Sellar 10 rendijas',
    check: (usuario) => usuario.misionesCompletadas.length >= 10,
  ),
  Logro(
    nombre: 'Versión Sobradísima',
    descripcion: 'Completar los 30 días',
    check: (usuario) => usuario.diasCompletados >= 30,
  ),
];