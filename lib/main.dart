import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_notification_service.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/missions/presentation/pages/all_missions_page.dart';
import 'features/ranking/presentation/pages/ranking_page.dart';
import 'features/ranking/data/repositories/ranking_repository.dart';
import 'features/ranking/domain/usecases/get_top_users.dart';
import 'features/ranking/presentation/providers/ranking_provider.dart';
import 'features/map/presentation/pages/map_page.dart';
import 'features/missions/data/repositories/mission_repository.dart';
import 'features/missions/domain/usecases/get_daily_mission.dart';
import 'features/missions/presentation/providers/mission_provider.dart';
import 'features/map/data/repositories/map_repository.dart';
import 'features/map/domain/usecases/get_nearby_users.dart';
import 'features/map/presentation/providers/map_provider.dart';
import 'features/biblioteca/data/repositories/recurso_repository_impl.dart';
import 'features/biblioteca/domain/usecases/get_recursos.dart';
import 'features/biblioteca/presentation/providers/biblioteca_provider.dart';
import 'features/biblioteca/presentation/pages/biblioteca_nk_page.dart';
import 'features/postureo/data/repositories/post_repository_impl.dart';
import 'features/postureo/domain/usecases/get_posts.dart';
import 'features/postureo/domain/usecases/like_post.dart';
import 'features/postureo/domain/usecases/create_post.dart';
import 'features/postureo/presentation/providers/postureo_provider.dart';
import 'features/postureo/presentation/pages/postureo_nk_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/shop/data/repositories/item_repository_impl.dart';
import 'features/shop/domain/usecases/get_items.dart';
import 'features/shop/presentation/providers/shop_provider.dart';
import 'features/shop/presentation/pages/shop_nk_page.dart';
import 'features/ia_nk/data/repositories/chat_repository_impl.dart';
import 'features/ia_nk/domain/usecases/send_message.dart';
import 'features/ia_nk/domain/usecases/get_available_models.dart';
import 'features/ia_nk/presentation/providers/chat_provider.dart';
import 'features/ia_nk/presentation/pages/ia_nk_page.dart';
import 'features/ia_nk/presentation/pages/chat_history_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Inicializar Supabase
  await SupabaseService.initialize();

  // Inicializar servicios de notificaciones
  await LocalNotificationService().init();
  // PushNotificationService eliminado - Supabase no tiene push notifications nativas

  final prefs = await SharedPreferences.getInstance();
  final repository = MissionRepositoryImpl(prefs);

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MissionProvider(
            getUser: GetUser(repository),
            saveUser: SaveUser(repository),
            getDailyMission: GetDailyMission(repository),
            completeMission: CompleteMission(repository),
            getAllMissions: GetAllMissions(repository),
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MapProvider(getNearbyUsers, Provider.of<AuthProvider>(context, listen: false)),

        ),
        ChangeNotifierProvider(
          create: (_) => BibliotecaProvider(getRecursos),
        ),
        ChangeNotifierProvider(
          create: (context) => PostureoProvider(getPosts, likePost, createPost, Provider.of<AuthProvider>(context, listen: false)),
        ),
        ChangeNotifierProvider(
          create: (_) => RankingProvider(getTopUsers),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(getItems),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(sendMessage, getAvailableModels),
        ),
      ],
      child: const KaizenekaApp(),
    ),
  );

  // Programar notificaciones diarias después de que la app esté corriendo
  WidgetsBinding.instance.addPostFrameCallback((_) {
    LocalNotificationService().scheduleDailyMissionNotification();
    LocalNotificationService().scheduleReminderNotification();
  });
}

class KaizenekaApp extends StatelessWidget {
  const KaizenekaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NK',
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/all-missions': (context) => const AllMissionsPage(),
        '/ranking': (context) => const RankingPage(),
        '/map': (context) => const MapPage(),
        '/biblioteca': (context) => const BibliotecaNkPage(),
        '/postureo': (context) => const PostureoNkPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/shop': (context) => const ShopNkPage(),
        '/ia_nk': (context) => const IaNkPage(),
        '/ia_nk_history': (context) => const ChatHistoryPage(),
      },
    );
  }
}

