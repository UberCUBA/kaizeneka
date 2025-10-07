import '../../data/repositories/ranking_repository.dart';
import '../../../map/domain/entities/kaizeneka_user.dart';

class GetTopUsers {
  final RankingRepository repository;

  GetTopUsers(this.repository);

  Future<List<KaizenekaUser>> call() {
    return repository.getTopUsers();
  }
}