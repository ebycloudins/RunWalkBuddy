import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:run_walk_buddy/theme/app_colors.dart';

import '../models/progressive_stage.dart';
import '../services/foreground_timer_service.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import '../widgets/control_buttons.dart';
import '../widgets/duration_input.dart';
import '../widgets/timer_card.dart';
import '../widgets/mode_selector.dart';
import '../widgets/edit_stage_sheet.dart';

class RunWalkHomePage extends StatefulWidget {
  const RunWalkHomePage({super.key});

  @override
  State<RunWalkHomePage> createState() => _RunWalkHomePageState();
}

class _RunWalkHomePageState extends State<RunWalkHomePage> {
  final TextEditingController _runController = TextEditingController(text: '3');

  final TextEditingController _walkController = TextEditingController(
    text: '1',
  );

  int _runSeconds = 180;
  int _walkSeconds = 60;
  int _remainingSeconds = 180;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isRunPhase = true;

  String _trainingMode = 'fixed';
  int _currentStage = 1;

  final TtsService _ttsService = TtsService();

  final List<ProgressiveStage> _progressiveStages = [
    ProgressiveStage(runMinutes: 4, walkMinutes: 1, durationMinutes: 35),
    ProgressiveStage(runMinutes: 3, walkMinutes: 1, durationMinutes: 30),
  ];

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');

    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();

    _ttsService.init();

    ForegroundTimerService.addTaskDataCallback(_onReceiveTaskData);
  }

  @override
  void dispose() {
    _runController.dispose();
    _walkController.dispose();

    ForegroundTimerService.removeTaskDataCallback(_onReceiveTaskData);

    super.dispose();
  }

  void _onReceiveTaskData(Object data) {
    if (data is! Map) return;

    final phase = data['phase']?.toString() ?? 'RUN';
    final remaining = data['remaining'] as int? ?? 0;
    final running = data['running'] as bool? ?? false;
    final phaseChanged = data['phaseChanged'] as bool? ?? false;
    final stage = data['stage'] as int? ?? 1;
    final stageChanged = data['stageChanged'] as bool? ?? false;

    if (!mounted) return;

    setState(() {
      _remainingSeconds = remaining;
      _isRunPhase = phase == 'RUN';
      _isRunning = running;
      _currentStage = stage;
    });

    if (phaseChanged) {
      unawaited(NotificationService.sendPhaseNotification(_isRunPhase));

      unawaited(
        _ttsService.speak(_isRunPhase ? 'Start running' : 'Start walking'),
      );
    }

    if (stageChanged && _trainingMode == 'progressive' && stage > 1) {
      unawaited(
        _ttsService.speak(
          'Stage $stage. '
          '${_isRunPhase ? 'Start running' : 'Start walking'}',
        ),
      );
    }

    debugPrint(
      'UI updated: $phase | $remaining seconds | '
      'running: $running | phaseChanged: $phaseChanged',
    );
  }

  Future<void> _startTimer() async {
    if (_isRunning) return;

    final runMinutes = _trainingMode == 'fixed'
        ? int.tryParse(_runController.text) ?? 0
        : _progressiveStages.first.runMinutes;

    final walkMinutes = _trainingMode == 'fixed'
        ? int.tryParse(_walkController.text) ?? 0
        : _progressiveStages.first.walkMinutes;

    if (runMinutes <= 0 || walkMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid run and walk durations.')),
      );

      return;
    }

    if (_trainingMode == 'progressive' && _progressiveStages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one progressive stage.')),
      );

      return;
    }

    await NotificationService.requestPermission();

    if (!await FlutterForegroundTask.isRunningService) {
      await ForegroundTimerService.start();
    }

    ForegroundTimerService.sendStart(
      runMinutes: runMinutes,
      walkMinutes: walkMinutes,
      progressiveStages: _trainingMode == 'progressive'
          ? _progressiveStages
                .map(
                  (stage) => {
                    'runMinutes': stage.runMinutes,
                    'walkMinutes': stage.walkMinutes,
                    'durationMinutes': stage.durationMinutes,
                  },
                )
                .toList()
          : null,
    );

    setState(() {
      _runSeconds = runMinutes * 60;
      _walkSeconds = walkMinutes * 60;
      _remainingSeconds = _runSeconds;
      _isRunPhase = true;
      _isRunning = true;
      _isPaused = false;
      _currentStage = 1;
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    if (_isPaused) {
      ForegroundTimerService.resume();
    } else {
      ForegroundTimerService.pause();
    }

    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopTimer() {
    ForegroundTimerService.stopTimer();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isRunPhase = true;
      _remainingSeconds = _runSeconds;
      _currentStage = 1;
    });
  }

  void _onRunEditingComplete() {
    final minutes = int.tryParse(_runController.text);

    if (minutes != null && minutes > 0 && !_isRunning) {
      setState(() {
        _remainingSeconds = minutes * 60;
        _isRunPhase = true;
      });
    }

    FocusScope.of(context).unfocus();
  }

  void _onWalkEditingComplete() {
    FocusScope.of(context).unfocus();
  }

  void _addProgressiveStage() {
    if (_isRunning) return;

    final previousStage = _progressiveStages.isNotEmpty
        ? _progressiveStages.last
        : null;

    setState(() {
      _progressiveStages.add(
        ProgressiveStage(
          runMinutes: previousStage?.runMinutes ?? 3,
          walkMinutes: previousStage?.walkMinutes ?? 1,
          durationMinutes: previousStage?.durationMinutes ?? 30,
        ),
      );
    });
  }

  void _removeProgressiveStage(int index) {
    if (_isRunning) return;

    if (_progressiveStages.length <= 1) {
      return;
    }

    setState(() {
      _progressiveStages.removeAt(index);
    });
  }

  Future<void> _showAddStageDialog() async {
  if (_isRunning) return;

  final previousStage = _progressiveStages.isNotEmpty
      ? _progressiveStages.last
      : null;

  final initial = ProgressiveStage(
    runMinutes: previousStage?.runMinutes ?? 4,
    walkMinutes: previousStage?.walkMinutes ?? 1,
    durationMinutes: previousStage?.durationMinutes ?? 30,
  );

  final newStage = await showAddStageSheet(
    context,
    initial: initial,
  );

  if (newStage != null && mounted) {
    setState(() {
      _progressiveStages.add(newStage);
    });
  }
}

  Future<void> _showEditStageDialog(int index) async {
    final updated = await showEditStageSheet(
      context,
      stageNumber: index + 1,
      initial: _progressiveStages[index],
    );

    if (updated != null && mounted) {
      setState(() {
        _progressiveStages[index] = updated;
      });
    }
  }

  Widget _buildStageDialogContent(
    TextEditingController runController,
    TextEditingController walkController,
    TextEditingController durationController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: runController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Run (min)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: walkController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Walk (min)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Switch after (min)'),
        ),
      ],
    );
  }

  Widget _buildProgressiveStage(int index, ProgressiveStage stage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF129A99),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(138, 220, 248, 249),
          width: 0.75,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stage ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stage.runMinutes} min Run  •  '
                  '${stage.walkMinutes} min Walk  •  '
                  '${stage.durationMinutes} min',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit stage',
            icon: const Icon(
              Icons.edit_outlined,
              size: 19,
              color: Colors.white70,
            ),
            onPressed: _isRunning ? null : () => _showEditStageDialog(index),
          ),
          if (_progressiveStages.length > 1)
            IconButton(
              tooltip: 'Remove stage',
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Colors.white70,
              ),
              onPressed: _isRunning
                  ? null
                  : () => _removeProgressiveStage(index),
            ),
        ],
      ),
    );
  }

  Widget _buildStageNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value.toString(),
      enabled: !_isRunning,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (text) {
        final parsed = int.tryParse(text);

        if (parsed != null && parsed > 0) {
          onChanged(parsed);
        }
      },
    );
  }

  Widget _buildProgressiveEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Progressive Stages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Change the run/walk pattern after a set amount of time.',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_progressiveStages.length, (index) {
          return _buildProgressiveStage(index, _progressiveStages[index]);
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: _isRunning ? null : _showAddStageDialog,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add Stage'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4EC8A),
            side: const BorderSide(color: Color(0xFF2C9697), width: 1),
            backgroundColor: const Color(0xFF0B7778),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'The current run/walk cycle will finish before moving to the next stage.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, height: 1.4, color: Colors.white70),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFixed = _trainingMode == 'fixed';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RUNWALK',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            Text(
              'BUDDY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: Color(0xFFB9F14E),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.background),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 28,
                  ),
                  child: Column(
                    children: [
                      // -------------------------------
                      // TOP SECTION
                      // -------------------------------
                      const Text(
                        'Your Run-Walk Training Partner',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(223, 255, 255, 255),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ModeSelector(
                        selectedMode: _trainingMode,
                        enabled: !_isRunning,
                        onChanged: (mode) {
                          setState(() {
                            _trainingMode = mode;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      if (isFixed)
                        Row(
                          children: [
                            Expanded(
                              child: DurationInput(
                                label: 'Run (minutes)',
                                controller: _runController,
                                enabled: !_isRunning,
                                onEditingComplete: _onRunEditingComplete,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DurationInput(
                                label: 'Walk (minutes)',
                                controller: _walkController,
                                enabled: !_isRunning,
                                onEditingComplete: _onWalkEditingComplete,
                              ),
                            ),
                          ],
                        )
                      else
                        _buildProgressiveEditor(),

                      const SizedBox(height: 24),

                      // -------------------------------
                      // CURRENT STAGE
                      // -------------------------------
                      if (_trainingMode == 'progressive' && _isRunning) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF129A99),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color.fromARGB(138, 220, 248, 249),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                size: 18,
                                color: Color(0xFFD4EC8A),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Stage $_currentStage of '
                                '${_progressiveStages.length}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_progressiveStages[_currentStage - 1].runMinutes}m '
                                'Run  •  '
                                '${_progressiveStages[_currentStage - 1].walkMinutes}m '
                                'Walk',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // -------------------------------
                      // TIMER
                      // -------------------------------
                      TimerCard(
                        isRunning: _isRunning,
                        isPaused: _isPaused,
                        isRunPhase: _isRunPhase,
                        formattedTime: _formattedTime,
                      ),

                      const SizedBox(height: 16),

                      // -------------------------------
                      // CONTROLS
                      // -------------------------------
                      ControlButtons(
                        isRunning: _isRunning,
                        isPaused: _isPaused,
                        onStartPause: _isRunning ? _pauseTimer : _startTimer,
                        onStop: _stopTimer,
                      ),

                      const SizedBox(height: 16),

                      // -------------------------------
                      // PATTERN
                      // -------------------------------
                      Text(
                        isFixed
                            ? 'RUN  →  WALK  →  RUN  →  WALK'
                            : 'STAGE 1  →  STAGE 2  →  STAGE 3...',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white70,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
