import '../entities/active_program.dart';

/// Repository interface for managing the active workout program.
/// 
/// This repository handles persistence and retrieval of the currently active
/// workout program, which serves as the single source of truth for workout sessions.
/// 
/// Validates: Requirements 7.2, 10.1
abstract class ActiveProgramRepository {
  /// Saves the active program to persistent storage.
  /// 
  /// This will overwrite any existing active program.
  Future<void> saveActiveProgram(ActiveProgram program);
  
  /// Loads the currently active program from persistent storage.
  /// 
  /// Returns null if no active program exists.
  Future<ActiveProgram?> loadActiveProgram();
  
  /// Clears the active program from persistent storage.
  /// 
  /// This effectively deactivates the current program.
  Future<void> clearActiveProgram();
  
  /// Updates the existing active program.
  /// 
  /// This is typically used for progress tracking, exercise modifications,
  /// or advancing to the next day.
  Future<void> updateActiveProgram(ActiveProgram program);
}
