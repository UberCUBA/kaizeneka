import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../../core/services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.userProfile?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        // Aquí iría la lógica para subir la imagen a Supabase Storage
        // Por ahora solo actualizamos el nombre
        await SupabaseService.createOrUpdateUserProfile(
          id: user.id,
          name: _nameController.text.trim(),
          email: user.email ?? '',
          avatarUrl: _selectedImage != null ? 'placeholder_url' : null, // TODO: Implementar subida real
        );

        // Recargar perfil
        await authProvider.reloadUserProfile();

        setState(() => _isEditing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar perfil: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text('Seleccionar imagen', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF00FF7F)),
              title: const Text('Galería', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF00FF7F)),
              title: const Text('Cámara', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final missionProvider = Provider.of<MissionProvider>(context);
    final userProfile = authProvider.userProfile;

    Color getBeltColor(String belt) {
      switch (belt) {
        case 'Blanco':
          return Colors.white;
        case 'Amarillo':
          return Colors.yellow;
        case 'Naranja':
          return Colors.orange;
        case 'Verde':
          return Colors.green;
        case 'Azul':
          return Colors.blue;
        case 'Marrón':
          return Colors.brown;
        case 'Negro':
          return Colors.black;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _isLoading ? null : _saveProfile,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _nameController.text = userProfile?.name ?? '';
                      _selectedImage = null;
                    });
                  },
                ),
              ],
            ),
        ],
      ),
      body: userProfile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text(
                    'Cargando perfil...',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Forzar recarga
                  //     Provider.of<AuthProvider>(context, listen: false).reloadUserProfile();
                  //   },
                  //   child: const Text('Reintentar'),
                  // ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF00FF7F),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (userProfile.avatarUrl != null && userProfile.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(userProfile.avatarUrl!)
                                  : null,
                          child: _selectedImage == null &&
                                 (userProfile.avatarUrl == null || userProfile.avatarUrl!.isEmpty)
                               ? Text(
                                   userProfile.name.isNotEmpty ? userProfile.name[0].toUpperCase() : 'U',
                                   style: const TextStyle(
                                     fontSize: 40,
                                     fontWeight: FontWeight.bold,
                                     color: Colors.black,
                                   ),
                                 )
                               : null,
                        ),
                        Positioned(
                          bottom: 4,
                          right: 2,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color.fromARGB(255, 186, 185, 185),
                              ),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[600],
                              ),
                              Icon(
                                Icons.star,
                                color: getBeltColor(missionProvider.user.cinturonActual),
                                size: 25,
                              ),
                            ],
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFF00FF7F),
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.black),
                                onPressed: _showImageSourceDialog,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: Color(0xFF00FF7F)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00FF7F)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00FF7F)),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      userProfile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 30),

                  // Información del perfil
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildProfileInfo('Email', userProfile.email),
                        const Divider(color: Colors.grey),
                        _buildProfileInfo('Cinturón', userProfile.belt),
                        const Divider(color: Colors.grey),
                        _buildProfileInfo('Puntos', userProfile.points.toString()),
                        const Divider(color: Colors.grey),
                        _buildProfileInfo('Miembro desde',
                            '${userProfile.createdAt.day}/${userProfile.createdAt.month}/${userProfile.createdAt.year}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Estadísticas adicionales
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            color: Color(0xFF00FF7F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('Misiones', '12'), // TODO: Conectar con datos reales
                            _buildStat('Posts', '8'),
                            _buildStat('Likes', '45'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Racha actual
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Racha Actual',
                          style: TextStyle(
                            color: Color(0xFF00FF7F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '7 días', // TODO: Conectar con lógica real
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '¡Sigue así!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Próxima misión
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Próxima Misión',
                          style: TextStyle(
                            color: Color(0xFF00FF7F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          missionProvider.getCurrentDailyMission().descripcion, // TODO: Mostrar la próxima
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Disponible mañana',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gestionar cursos
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Gestionar Cursos',
                          style: TextStyle(
                            color: Color(0xFF00FF7F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Administra tus cursos y progreso',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Navegar a gestión de cursos
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gestión de cursos próximamente')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF7F),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Ver Cursos'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00FF7F),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}