import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../../ranking/data/repositories/ranking_repository.dart';
import '../../../ranking/domain/usecases/get_top_users.dart';
import '../../../ranking/presentation/providers/ranking_provider.dart';
import '../../../map/data/repositories/map_repository.dart';
import '../../../map/domain/usecases/get_nearby_users.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../biblioteca/data/repositories/recurso_repository_impl.dart';
import '../../../biblioteca/domain/usecases/get_recursos.dart';
import '../../../biblioteca/presentation/providers/biblioteca_provider.dart';
import '../../../postureo/data/repositories/post_repository_impl.dart';
import '../../../postureo/domain/usecases/get_posts.dart';
import '../../../postureo/domain/usecases/like_post.dart';
import '../../../postureo/domain/usecases/create_post.dart';
import '../../../postureo/presentation/providers/postureo_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shop/data/repositories/item_repository_impl.dart';
import '../../../shop/domain/usecases/get_items.dart';
import '../../../shop/presentation/providers/shop_provider.dart';
import '../../../ia_nk/data/repositories/chat_repository_impl.dart';
import '../../../ia_nk/domain/usecases/send_message.dart';
import '../../../ia_nk/domain/usecases/get_available_models.dart';
import '../../../ia_nk/presentation/providers/chat_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../habits/presentation/providers/habit_provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  double _progress = 0.0;
  String _currentTask = 'Iniciando aplicación...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Paso 1: Cargar variables de entorno
      setState(() {
        _currentTask = 'Cargando configuración...';
        _progress = 0.1;
      });
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        debugPrint('No .env file found, using default values');
      }

      // Paso 2: Inicializar Supabase
      setState(() {
        _currentTask = 'Conectando con servicios...';
        _progress = 0.2;
      });
      await SupabaseService.initialize();

      // Paso 3: Inicializar notificaciones
      setState(() {
        _currentTask = 'Configurando notificaciones...';
        _progress = 0.3;
      });
      try {
        await LocalNotificationService().init();
      } catch (e) {
        debugPrint('Error initializing notifications: $e');
      }

      // Paso 4: Inicializar Home Widget
      setState(() {
        _currentTask = 'Preparando widgets...';
        _progress = 0.4;
      });
      try {
        await HomeWidgetService.initialize();
        debugPrint('Servicio de home widget inicializado correctamente');
      } catch (e) {
        debugPrint('Error initializing home widget: $e');
      }

      // Paso 5: Obtener SharedPreferences
      setState(() {
        _currentTask = 'Cargando preferencias...';
        _progress = 0.5;
      });
      final prefs = await SharedPreferences.getInstance();

      // Paso 6: Inicializar repositorios y casos de uso
      setState(() {
        _currentTask = 'Preparando datos...';
        _progress = 0.6;
      });

      final mapRepository = SupabaseMapRepository();
      final getNearbyUsers = GetNearbyUsers(mapRepository);

      final recursoRepository = RecursoRepositoryImpl();
      final getRecursos = GetRecursos(recursoRepository);

      final postRepository = PostRepositoryImpl();
      final getPosts = GetPosts(postRepository);
      final likePost = LikePost(postRepository);
      final createPost = CreatePost(postRepository);

      final rankingRepository = SupabaseRankingRepository();
      final getTopUsers = GetTopUsers(rankingRepository);

      final itemRepository = ItemRepositoryImpl();
      final getItems = GetItems(itemRepository);

      final chatRepository = ChatRepositoryImpl();
      final sendMessage = SendMessage(chatRepository);
      final getAvailableModels = GetAvailableModels(chatRepository);

      // Paso 7: Inicializar ChatRepository
      setState(() {
        _currentTask = 'Configurando IA...';
        _progress = 0.7;
      });
      await ChatRepositoryImpl.initialize();

      // Paso 8: Configurar providers
      setState(() {
        _currentTask = 'Finalizando configuración...';
        _progress = 0.8;
      });

      // Paso 9: Esperar un poco más para simular carga completa
      setState(() {
        _currentTask = 'Casi listo...';
        _progress = 0.9;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Paso 10: Navegar a splash
      setState(() {
        _currentTask = '¡Listo!';
        _progress = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }

    } catch (e) {
      debugPrint('Error during initialization: $e');
      // En caso de error, navegar de todos modos
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF001100)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'NK+',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FF7F),
                  shadows: [
                    Shadow(
                      blurRadius: 15.0,
                      color: Color(0xFF00FF7F),
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 250,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _currentTask,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}