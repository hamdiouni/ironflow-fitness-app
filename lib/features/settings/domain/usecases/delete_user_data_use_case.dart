import '../services/local_data_wiper.dart';

class DeleteUserDataResult {
  final bool success;
  final String message;

  const DeleteUserDataResult({required this.success, required this.message});
}

/// Use case for purging all user data locally on this device while keeping the account active.
class DeleteUserDataUseCase {
  final LocalDataWiper _localDataWiper;

  DeleteUserDataUseCase({LocalDataWiper? localDataWiper})
      : _localDataWiper = localDataWiper ?? LocalDataWiper();

  Future<DeleteUserDataResult> call(String userId) async {
    try {
      await _localDataWiper.wipeAllUserData(userId, keepAuthSession: true);
      return const DeleteUserDataResult(
        success: true,
        message: 'All local workout, nutrition, biometric telemetry and snapshots were eradicated from this device.',
      );
    } catch (e) {
      return DeleteUserDataResult(
        success: false,
        message: 'Failed to purge local device data: $e',
      );
    }
  }
}
