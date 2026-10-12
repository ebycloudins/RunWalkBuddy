
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundTimerService {
  static void initializeCommunicationPort() {
    FlutterForegroundTask.initCommunicationPort();
  }

  static Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'run_walk_foreground',
        channelName: 'RunWalk Buddy Service',
        channelDescription: 'Keeps the run-walk timer active',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );
  }

  static Future<void> start() async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'RunWalk Buddy',
      notificationText: 'Background test starting...',
      callback: startCallback,
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }

  static void sendStart({
    required int runMinutes,
    required int walkMinutes,
    List<Map<String, int>>? progressiveStages,
  }) {
    FlutterForegroundTask.sendDataToTask({
      'command': 'start',
      'runMinutes': runMinutes,
      'walkMinutes': walkMinutes,
      'progressiveStages': progressiveStages,
    });
  }

  static void pause() {
    FlutterForegroundTask.sendDataToTask({
      'command': 'pause',
    });
  }

  static void resume() {
    FlutterForegroundTask.sendDataToTask({
      'command': 'resume',
    });
  }

  static void stopTimer() {
    FlutterForegroundTask.sendDataToTask({
      'command': 'stop',
    });
  }

  static void addTaskDataCallback(void Function(Object) callback) {
    FlutterForegroundTask.addTaskDataCallback(callback);
  }

  static void removeTaskDataCallback(void Function(Object) callback) {
    FlutterForegroundTask.removeTaskDataCallback(callback);
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(
    RunWalkTaskHandler(),
  );
}

class RunWalkTaskHandler extends TaskHandler {
  // Current Run/Walk durations.
  int _runSeconds = 0;
  int _walkSeconds = 0;
  int _remainingSeconds = 0;

  bool _isRunPhase = true;
  bool _isTimerRunning = false;
  bool _isConfigured = false;

  // Progressive mode.
  List<Map<String, int>> _progressiveStages = [];
  int _currentStageIndex = 0;

  // How long the current stage has been active.
  int _stageElapsedSeconds = 0;

  // Once the stage duration is reached, we don't switch immediately.
  // We wait until the current Run/Walk phase finishes.
  bool _stageChangePending = false;

  bool get _isProgressive =>
      _progressiveStages.isNotEmpty;

  @override
  Future<void> onStart(
    DateTime timestamp,
    TaskStarter starter,
  ) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'RunWalk Buddy',
      notificationText: 'Waiting for timer settings...',
    );
  }

  @override
  void onReceiveData(Object data) {
    if (data is! Map) return;

    final command = data['command'];

    if (command == 'start') {
      _startTimer(data);
    } else if (command == 'pause') {
      _isTimerRunning = false;
    } else if (command == 'resume') {
      _isTimerRunning = true;
    } else if (command == 'stop') {
      _stopTimer();
    }
  }

  void _startTimer(Map data) {
    _runSeconds = (data['runMinutes'] as int) * 60;
    _walkSeconds = (data['walkMinutes'] as int) * 60;

    _progressiveStages = [];

    final stages = data['progressiveStages'];

    if (stages is List) {
      for (final stage in stages) {
        if (stage is Map) {
          _progressiveStages.add({
            'runMinutes': stage['runMinutes'] as int,
            'walkMinutes': stage['walkMinutes'] as int,
            'durationMinutes': stage['durationMinutes'] as int,
          });
        }
      }
    }

    _currentStageIndex = 0;
    _stageElapsedSeconds = 0;
    _stageChangePending = false;

    // If Progressive mode was supplied, Stage 1 becomes
    // the initial Run/Walk pattern.
    if (_isProgressive) {
      _applyProgressiveStage(0);
    }

    _remainingSeconds = _runSeconds;
    _isRunPhase = true;
    _isConfigured = true;
    _isTimerRunning = true;

    FlutterForegroundTask.sendDataToMain({
      'phase': 'RUN',
      'remaining': _remainingSeconds,
      'running': true,
      'stage': _currentStageIndex + 1,
    });
  }

  void _applyProgressiveStage(int index) {
    final stage = _progressiveStages[index];

    _runSeconds = stage['runMinutes']! * 60;
    _walkSeconds = stage['walkMinutes']! * 60;

    _stageElapsedSeconds = 0;
    _stageChangePending = false;
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _isConfigured = false;

    _progressiveStages = [];
    _currentStageIndex = 0;
    _stageElapsedSeconds = 0;
    _stageChangePending = false;
  }

  void _updateProgressiveStageTimer() {
    if (!_isProgressive) return;

    _stageElapsedSeconds++;

    final currentStage =
        _progressiveStages[_currentStageIndex];

    final durationMinutes =
        currentStage['durationMinutes']!;

    final durationSeconds = durationMinutes * 60;

    if (_stageElapsedSeconds >= durationSeconds) {
      _stageChangePending = true;
    }
  }

  bool _moveToNextStageIfNeeded() {
    if (!_isProgressive || !_stageChangePending) {
      return false;
    }

    final nextStageIndex = _currentStageIndex + 1;

    // No more stages.
    if (nextStageIndex >= _progressiveStages.length) {
      return false;
    }

    _currentStageIndex = nextStageIndex;

    _applyProgressiveStage(
      _currentStageIndex,
    );

    return true;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (!_isConfigured || !_isTimerRunning) {
      return;
    }

    // Count time spent in the current Progressive stage.
    _updateProgressiveStageTimer();

    bool phaseChanged = false;
    bool stageChanged = false;

    if (_remainingSeconds > 0) {
      _remainingSeconds--;
    } else {
      // Current Run/Walk phase has completed.

      // First determine whether we should move to the
      // next Progressive stage.
      stageChanged = _moveToNextStageIfNeeded();

      // Then switch Run <-> Walk.
      _isRunPhase = !_isRunPhase;

      _remainingSeconds =
          _isRunPhase ? _runSeconds : _walkSeconds;

      phaseChanged = true;
    }

    final phase = _isRunPhase ? 'RUN' : 'WALK';

    FlutterForegroundTask.updateService(
      notificationTitle: 'RunWalk Buddy',
      notificationText:
          '$phase - ${_remainingSeconds ~/ 60}:'
          '${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
    );

    FlutterForegroundTask.sendDataToMain({
      'phase': phase,
      'remaining': _remainingSeconds,
      'running': _isTimerRunning,
      'phaseChanged': phaseChanged,
      'stage': _currentStageIndex + 1,
      'stageChanged': stageChanged,
    });
  }

  @override
  Future<void> onDestroy(
    DateTime timestamp,
    bool isTimeout,
  ) async {}
}