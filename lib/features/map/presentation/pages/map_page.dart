import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../../domain/entities/kaizeneka_user.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  bool _isSatellite = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MapProvider>(context, listen: false);
      provider.requestLocationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mapa Kaizeneka', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: provider.userLocation ?? const LatLng(21.5, -79.5), // Centro en Cuba por defecto
              initialZoom: provider.userLocation != null ? 18.0 : 7.0, // Zoom cercano si hay ubicación, Cuba si no
              minZoom: 2.0, // Zoom mínimo del mapa mundi
              maxZoom: 18.0,
              initialRotation: 0.0, // Orientación norte por defecto
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.flingAnimation | InteractiveFlag.pinchMove | InteractiveFlag.pinchZoom | InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kaizeneka',
              ),
              MarkerLayer(
                markers: _buildMarkers(provider),
              ),
            ],
          ),
          // Zoom arriba derecha
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: const Color.fromARGB(255, 85, 108, 96),
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom < 18.0) {
                      _mapController.move(_mapController.camera.center, currentZoom + 1);
                    }
                  },
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
                const SizedBox(height: 5),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: const Color.fromARGB(255, 85, 108, 96),
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom > 2.0) {
                      _mapController.move(_mapController.camera.center, currentZoom - 1);
                    }
                  },
                  child: const Icon(Icons.remove, color: Colors.black, size: 20),
                ),
                const SizedBox(height: 5),
                FloatingActionButton(
                  heroTag: 'menu',
                  mini: true,
                  backgroundColor: const Color.fromARGB(255, 85, 108, 96),
                  onPressed: _showMenu,
                  child: const Icon(Icons.menu, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
          // Rotación arriba izquierda
          Positioned(
            top: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'reset_rotation',
              mini: true,
              backgroundColor: const Color.fromARGB(255, 85, 108, 96),
              onPressed: () {
                _mapController.rotate(0.0);
              },
              child: const Icon(Icons.navigation, color: Colors.black, size: 20),
            ),
          ),
          // Ubicación abajo derecha
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'center_location',
              mini: true,
              backgroundColor: const Color.fromARGB(255, 85, 108, 96),
              onPressed: () {
                if (provider.userLocation != null) {
                  _mapController.move(provider.userLocation!, 18.0);
                }
              },
              child: const Icon(Icons.my_location, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(MapProvider provider) {
    List<Marker> markers = [];

    // Marcador del usuario
    if (provider.showUserLocation && provider.userLocation != null) {
      markers.add(
        Marker(
          point: provider.userLocation!,
          child: _AnimatedUserMarker(),
        ),
      );
    }

    // Marcadores de otros usuarios
    for (var user in provider.nearbyUsers) {
      markers.add(
        Marker(
          point: user.location,
          child: GestureDetector(
            onTap: () => _showUserPopup(user),
            child: Container(
              decoration: BoxDecoration(
                color: _getBeltColor(user.belt).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: _getBeltColor(user.belt),
                size: 30,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Color _getBeltColor(String belt) {
    switch (belt) {
      case 'Blanco':
        return Colors.white;
      case 'Amarillo':
        return Colors.yellow;
      case 'Naranja':
        return Colors.orange;
      case 'Verde':
        return const Color(0xFF00FF7F);
      case 'Marrón':
        return Colors.brown;
      case 'Negro':
        return Colors.grey;
      case 'Sobrado':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  void _showUserPopup(KaizenekaUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF00FF7F),
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(color: Color(0xFF00FF7F), fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null && user.email!.isNotEmpty)
              Text(
                'Email: ${user.email}',
                style: const TextStyle(color: Colors.white),
              ),
            Text(
              'Cinturón: ${user.belt}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Puntos: ${user.points}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getBeltColor(user.belt),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.belt,
                style: TextStyle(
                  color: _getBeltColor(user.belt) == Colors.white ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF00FF7F))),
          ),
        ],
      ),
    );
  }

  void _showPrivacyMessage(String? message) {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1C1C1C),
        ),
      );
    }
  }

  void _showMenu() {
    final provider = Provider.of<MapProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Opciones', style: TextStyle(color: Color(0xFF00FF7F))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(_isSatellite ? Icons.map : Icons.satellite, color: const Color(0xFF00FF7F)),
              title: Text(_isSatellite ? 'Cambiar a Mapa' : 'Cambiar a Satelital', style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _isSatellite = !_isSatellite;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(provider.showUserLocation ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF00FF7F)),
              title: Text(provider.showUserLocation ? 'Activar Modo Incognito' : 'Desactivar Modo Incognito', style: const TextStyle(color: Colors.white)),
              onTap: () {
                provider.toggleShowLocation();
                _showPrivacyMessage(provider.privacyMessage);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedUserMarker extends StatefulWidget {
  const _AnimatedUserMarker();

  @override
  State<_AnimatedUserMarker> createState() => _AnimatedUserMarkerState();
}

class _AnimatedUserMarkerState extends State<_AnimatedUserMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF00FF7F).withOpacity(0.3 * _animation.value),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF00FF7F),
            size: 30,
          ),
        );
      },
    );
  }
}