# Sistema de Progreso Kaizeneka 🎮

## Descripción General

El **Sistema de Progreso** transforma la experiencia Kaizeneka en una aventura gamificada completa, donde cada acción del usuario contribuye a su crecimiento personal a través de un sistema de recompensas, narrativa inmersiva y progreso visual.

## 🎯 Características Principales

### 1. **Sistema de XP y Niveles**
- **Fórmula de progresión**: `XP_requerido = Nivel * 50 + (Nivel²) * 10`
- **Subida automática de nivel** cuando se alcanza el XP requerido
- **Desbloqueos inteligentes** por nivel alcanzado

### 2. **Monedas y Economía del Juego**
- **Moneda premium** para compras en tienda
- **Recompensas diferenciadas** por dificultad:
  - Fácil: +1 moneda
  - Media: +2 monedas
  - Difícil: +4 monedas

### 3. **Sistema de Rachas Diarias**
- **Multiplicadores de recompensa** por consistencia
- **Recordatorios automáticos** cuando la racha está en riesgo
- **Bonificaciones especiales** por hitos (7, 14, 30 días)

### 4. **Misiones Narrativas (70 misiones)**
- **12 Arcos narrativos** desde "El Despertar" hasta "Trascendencia"
- **Sistema de prerrequisitos** y desbloqueos progresivos
- **Recompensas contextuales** por fase y dificultad

### 5. **Sistema JVC (Juegos Vitales Clave)**
- **3 mundos principales**:
  - 🧘 Salud Extrema
  - 🤝 Dinámicas Sociales
  - 🚀 Psicología del Éxito
- **Equilibrio requerido** para avanzar de "cinturón vital"
- **Sinergias calculadas** entre áreas

### 6. **Sistema de Logros**
- **Logros automáticos** por hitos alcanzados
- **Recompensas permanentes** por desafíos únicos
- **Sistema de seguimiento** de progreso

### 7. **Sistema de Energía**
- **Gestión diaria** (máximo 100 puntos)
- **Consumo por acciones** difíciles
- **Restauración** por descanso y actividades positivas

## 🏗️ Arquitectura Técnica

### Modelos de Datos
```dart
// Usuario con sistema de progreso
class UserModel {
  int xp;           // Experiencia actual
  int coins;        // Moneda del juego
  int level;        // Nivel actual
  int streak;       // Racha diaria
  int energy;       // Energía disponible
  Map<String, int> jvcProgress;  // Progreso JVC
  String currentWorld;           // Mundo actual
  int currentArc;                // Arco narrativo actual
  List<String> unlockedMissions; // Misiones desbloqueadas
  List<String> unlockedAchievements; // Logros desbloqueados
  Map<String, dynamic> stats;    // Estadísticas personales
}
```

### Servicios Principales
- **ProgressService**: Gestión centralizada de XP, niveles y progreso
- **NarrativeService**: Sistema de misiones narrativas
- **AchievementService**: Logros y desbloqueos
- **JvcService**: Equilibrio entre mundos JVC
- **NotificationService**: Notificaciones gamificadas

### Base de Datos (Supabase)
```sql
-- Campos agregados a tabla users
ALTER TABLE users ADD COLUMN xp INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN coins INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN level INTEGER DEFAULT 1;
ALTER TABLE users ADD COLUMN streak INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN energy INTEGER DEFAULT 100;
ALTER TABLE users ADD COLUMN jvc_progress JSONB DEFAULT '{"Salud": 0, "Dinámicas Sociales": 0, "Psicología del Éxito": 0}';
ALTER TABLE users ADD COLUMN current_world TEXT DEFAULT 'Salud Extrema';
ALTER TABLE users ADD COLUMN current_arc INTEGER DEFAULT 1;
ALTER TABLE users ADD COLUMN unlocked_missions JSONB DEFAULT '[]';
ALTER TABLE users ADD COLUMN unlocked_achievements JSONB DEFAULT '[]';
ALTER TABLE users ADD COLUMN stats JSONB DEFAULT '{"fuerza": 0, "constancia": 0, "foco": 0}';

-- Nuevas tablas
CREATE TABLE narrative_missions (...);
CREATE TABLE achievements (...);
CREATE TABLE habits (...);
CREATE TABLE tasks (...);
CREATE TABLE missions (...);
```

## 🎨 Interfaz de Usuario

### ProgressPage (Nueva página principal)
- **4 pestañas**: Nivel, Misiones, Logros, Estadísticas
- **Visualización de progreso** con barras animadas
- **Indicadores en tiempo real** de XP, monedas, energía

### ProfilePage (Actualizada)
- **Estadísticas expandidas** con nuevos campos
- **Indicadores visuales** de progreso
- **Vista rápida** de racha y nivel

### Tutorial Interactivo
- **9 pasos guiados** explicando el sistema
- **Ejemplos prácticos** de cada mecánica
- **Introducción progresiva** a conceptos complejos

## 🔧 Instalación y Configuración

### 1. Ejecutar Migración de Base de Datos
```bash
# En Supabase SQL Editor, ejecutar:
# supabase_migration_progress.sql
```

### 2. Actualizar Dependencias
```yaml
# Agregar a pubspec.yaml si es necesario:
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
```

### 3. Configurar Notificaciones
```dart
// En main.dart
await NotificationService.initialize();
```

### 4. Agregar Rutas de Navegación
```dart
// En router configuration
'/progress': (context) => const ProgressPage(),
'/tutorial': (context) => const ProgressTutorialPage(),
```

## 🎮 Mecánicas de Juego

### Recompensas por Acción
| Acción | XP | Monedas | Energía |
|--------|----|---------|---------|
| Tarea fácil | +5 | +1 | -5 |
| Tarea media | +10 | +2 | -10 |
| Tarea difícil | +20 | +4 | -20 |
| Hábito diario | +3-8 | +1-3 | -5 |
| Misión narrativa | +15-50 | +3-10 | -10 |

### Sistema de Energía
- **Máximo**: 100 puntos
- **Restauración diaria**: +50 (sueño completo)
- **Actividades**: +10-30 (ejercicio, meditación)
- **Consumo**: -5 a -50 (tareas difíciles, estrés)

### Progreso JVC
- **Actividades impactan** múltiples áreas simultáneamente
- **Equilibrio requerido** para avanzar (70% mínimo en todas)
- **Sinergias calculadas** entre mundos

## 📊 Métricas y Analytics

### Seguimiento de Usuario
- **Tasa de retención** por niveles
- **Completitud de arcos** narrativos
- **Equilibrio JVC** promedio
- **Frecuencia de rachas** perdidas

### KPIs Principales
- **Usuario activo diario** con racha > 0
- **Completitud de misiones** por arco
- **Tiempo promedio** entre niveles
- **Equilibrio JVC** mantenido

## 🔮 Expansión Futura

### Características Planeadas
- **Gremios y comunidades** con desafíos grupales
- **Items coleccionables** y personalización
- **Eventos especiales** y temporadas
- **Sistema de mentoría** gamificado

### Integraciones
- **Wearables** para tracking automático
- **Redes sociales** para compartir progreso
- **API externa** para sincronización
- **Gamification marketplace**

## 🐛 Solución de Problemas

### Errores Comunes
1. **Notificaciones no funcionan**: Verificar permisos y configuración
2. **Progreso no se guarda**: Revisar conexión a Supabase
3. **Misiones no se desbloquean**: Verificar prerrequisitos
4. **JVC desequilibrado**: Revisar cálculo de sinergias

### Debug Tools
```dart
// Verificar estado del usuario
print('Usuario: ${user.xp} XP, Nivel ${user.level}');

// Verificar progreso JVC
print('JVC Progress: ${user.jvcProgress}');

// Verificar misiones disponibles
final available = await NarrativeService.getAvailableMissions(userId, user.level, user.currentArc, user.unlockedMissions);
print('Misiones disponibles: ${available.length}');
```

## 📝 Checklist de Implementación

- [x] Modelos de datos actualizados
- [x] Servicios de progreso implementados
- [x] Sistema de misiones narrativas
- [x] Logros y desbloqueos
- [x] Sistema JVC y equilibrio
- [x] Notificaciones gamificadas
- [x] Interfaz de usuario completa
- [x] Tutorial interactivo
- [x] Migración de base de datos
- [x] Testing y validación
- [ ] Despliegue en producción
- [ ] Monitoreo y ajustes

## 🤝 Contribución

Para contribuir al sistema de progreso:

1. **Revisar issues** existentes
2. **Crear rama feature** específica
3. **Implementar cambios** siguiendo la arquitectura
4. **Agregar tests** para nuevas funcionalidades
5. **Actualizar documentación**
6. **Crear PR** con descripción detallada

## 📞 Soporte

Para soporte técnico del sistema de progreso:
- **Issues en GitHub** para bugs y mejoras
- **Documentación interna** para guías detalladas
- **Equipo de producto** para decisiones de diseño

---

*Sistema diseñado para transformar el crecimiento personal en una experiencia engaging y sostenible.*