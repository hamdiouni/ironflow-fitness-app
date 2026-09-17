import '../entities/body_entry.dart';
import '../repositories/body_repository.dart';

/// Persists a body entry to local storage.
class SaveBodyEntryUseCase {
  final BodyRepository repository;

  SaveBodyEntryUseCase(this.repository);

  Future<void> call(BodyEntry entry) async {
    await repository.saveBodyEntry(entry);
  }
}
