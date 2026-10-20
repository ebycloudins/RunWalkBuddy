import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/progressive_stage.dart';

Future<ProgressiveStage?> showEditStageSheet(
  BuildContext context, {
  required int stageNumber,
  required ProgressiveStage initial,
}) {
  return showModalBottomSheet<ProgressiveStage>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => EditStageSheet(stageNumber: stageNumber, initial: initial),
  );
}

Future<ProgressiveStage?> showAddStageSheet(
  BuildContext context, {
  required ProgressiveStage initial,
}) {
  return showModalBottomSheet<ProgressiveStage>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => EditStageSheet(
      stageNumber: 0,
      initial: initial,
      isNew: true,
    ),
  );
}

class EditStageSheet extends StatefulWidget {
  final int stageNumber;
  final ProgressiveStage initial;
  final bool isNew;

  const EditStageSheet({
    super.key,
    required this.stageNumber,
    required this.initial,
    this.isNew = false,
  });

  @override
  State<EditStageSheet> createState() => _EditStageSheetState();
}

class _EditStageSheetState extends State<EditStageSheet> {
  static final _runValues = List.generate(30, (i) => i + 1);

  static final _walkValues = List.generate(10, (i) => i + 1);

  static final _lengthValues = List.generate(24, (i) => (i + 1) * 5);

  late int _run = widget.initial.runMinutes;
  late int _walk = widget.initial.walkMinutes;
  late int _length = widget.initial.durationMinutes;

  @override
  Widget build(BuildContext context) {
    final valid = _length >= _run + _walk;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B7778),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(9),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            widget.isNew ? 'Add Stage' : 'Edit Stage ${widget.stageNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          // Column labels
          const Row(
            children: [
              _Label('RUN (MIN)'),
              _Label('WALK (MIN)'),
              _Label('STAGE (MIN)'),
            ],
          ),

          const SizedBox(height: 6),

          // Wheels
          SizedBox(
            height: 190,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FAF3D).withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4EC8A).withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Wheel(
                        values: _runValues,
                        value: _run,
                        onChanged: (value) {
                          setState(() {
                            _run = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _Wheel(
                        values: _walkValues,
                        value: _walk,
                        onChanged: (value) {
                          setState(() {
                            _walk = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _Wheel(
                        values: _lengthValues,
                        value: _length,
                        onChanged: (value) {
                          setState(() {
                            _length = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!valid)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Stage length must fit at least one run + walk cycle.',
                style: TextStyle(color: Color(0xFFD4EC8A), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 14),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2C9697)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF085C62),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: valid
                      ? () {
                          Navigator.pop(
                            context,
                            ProgressiveStage(
                              runMinutes: _run,
                              walkMinutes: _walk,
                              durationMinutes: _length,
                            ),
                          );
                        }
                      : null,
                  child: Text(
  widget.isNew ? 'Add Stage' : 'Save',
  style: const TextStyle(
    fontWeight: FontWeight.w700,
  ),
),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Wheel extends StatefulWidget {
  final List<int> values;
  final int value;
  final ValueChanged<int> onChanged;

  const _Wheel({
    required this.values,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late int _selected = widget.values.indexOf(widget.value);

  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: _selected);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: _controller,
      itemExtent: 40,
      diameterRatio: 1.4,
      squeeze: 1.1,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: (index) {
        HapticFeedback.selectionClick();

        setState(() {
          _selected = index;
        });

        widget.onChanged(widget.values[index]);
      },
      children: [
        for (var i = 0; i < widget.values.length; i++)
          Center(
            child: Text(
              '${widget.values[i]}',
              style: TextStyle(
                fontSize: i == _selected ? 26 : 18,
                fontWeight: i == _selected ? FontWeight.w700 : FontWeight.w400,
                color: Colors.white.withValues(
                  alpha: i == _selected ? 1 : 0.43,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
