import 'dart:async';
import 'package:flutter/services.dart';

/// Service for managing rest timer between sets
/// Provides countdown timer with audio/vibration alerts
class RestTimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  
  // Callbacks
  Function(int)? onTick;
  Function()? onComplete;
  
  /// Start the rest timer
  void start(int durationSeconds) {
    stop(); // Stop any existing timer
    
    _remainingSeconds = durationSeconds;
    _isRunning = true;
    
    // Notify initial state
    onTick?.call(_remainingSeconds);
    
    // Start countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      
      if (_remainingSeconds <= 0) {
        _complete();
      } else {
        onTick?.call(_remainingSeconds);
        
        // Vibrate on last 3 seconds
        if (_remainingSeconds <= 3) {
          HapticFeedback.mediumImpact();
        }
      }
    });
  }
  
  /// Stop the timer
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _remainingSeconds = 0;
  }
  
  /// Pause the timer
  void pause() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }
  
  /// Resume the timer
  void resume() {
    if (_remainingSeconds > 0 && !_isRunning) {
      start(_remainingSeconds);
    }
  }
  
  /// Add time to the timer
  void addTime(int seconds) {
    _remainingSeconds += seconds;
    onTick?.call(_remainingSeconds);
  }
  
  /// Complete the timer
  void _complete() {
    stop();
    
    // Vibrate on completion
    HapticFeedback.heavyImpact();
    
    // Notify completion
    onComplete?.call();
  }
  
  /// Skip the timer
  void skip() {
    _complete();
  }
  
  /// Get remaining time
  int get remainingSeconds => _remainingSeconds;
  
  /// Check if timer is running
  bool get isRunning => _isRunning;
  
  /// Format time as MM:SS
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  /// Dispose the service
  void dispose() {
    stop();
  }
}
