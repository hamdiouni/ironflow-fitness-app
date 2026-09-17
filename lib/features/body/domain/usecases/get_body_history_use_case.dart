import '../entities/body_entry.dart';
import '../repositories/body_repository.dart';

/// Retrieves all persisted body entries, sorted by date descending.
class GetBodyHistoryUseCase {
  final BodyRepository repository;

  GetBodyHistoryUseCase(this.repository);

  Future<List<BodyEntry>> call() async {
    return await repository.getAllBodyEntries();
  }
}
