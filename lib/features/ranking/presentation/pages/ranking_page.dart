import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ranking_provider.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RankingProvider>(context, listen: false).loadTopUsers();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RankingProvider>(context);

    if (provider.errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Ranking de Usuarios', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Ranking de Usuarios', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: provider.topUsers.length,
        itemBuilder: (context, index) {
          final user = provider.topUsers[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Position
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: index < 3 ? Colors.grey : const Color.fromARGB(255, 59, 59, 59),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index < 3 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Avatar with star
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color.fromARGB(255, 59, 59, 59),
                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: getBeltColor(user.belt) == Colors.white ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey[300],
                          ),
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.grey[600],
                          ),
                          Icon(
                            Icons.star,
                            color: getBeltColor(user.belt),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Name and points
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${user.points} puntos',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Belt
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: getBeltColor(user.belt),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.belt,
                    style: TextStyle(
                      color: getBeltColor(user.belt) == Colors.white ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}