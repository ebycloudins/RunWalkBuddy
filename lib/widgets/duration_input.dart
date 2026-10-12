import 'package:flutter/material.dart';

class DurationInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onEditingComplete;

  const DurationInput({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onEditingComplete,
  });

  @override
  State<DurationInput> createState() => _DurationInputState();
}

class _DurationInputState extends State<DurationInput> {
  bool get isWalk =>
      widget.label.toLowerCase().contains('walk');

  Color get accentColor => const Color(0xFFB9F14E);

  void _changeDuration(int change) {
    final current =
        int.tryParse(widget.controller.text) ?? 1;

    final newValue = (current + change).clamp(1, 120);

    widget.controller.text = newValue.toString();

    widget.controller.selection =
        TextSelection.collapsed(
      offset: widget.controller.text.length,
    );

    setState(() {});

    widget.onEditingComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B7778),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2C9697),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // HEADER
          // ---------------------------------------------------------
          Row(
            children: [
              Text(
                isWalk ? 'Walk' : 'Run',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              //const Spacer(),

              Text(
                ' (minutes)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---------------------------------------------------------
          // DURATION
          // ---------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Editable number
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onEditingComplete:
                      widget.onEditingComplete,
                  cursorColor: accentColor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // -----------------------------------------------------
              // UP / DOWN BUTTONS
              // -----------------------------------------------------
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildArrowButton(
                    icon: Icons.keyboard_arrow_up_rounded,
                    onPressed: widget.enabled
                        ? () => _changeDuration(1)
                        : null,
                  ),

                  const SizedBox(height: 5),

                  _buildArrowButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    onPressed: widget.enabled
                        ? () => _changeDuration(-1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // ARROW BUTTON
  // ---------------------------------------------------------------
  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            decoration: BoxDecoration(
              // Same subtle background as the old Run/Walk icon
              color: Colors.white.withValues(alpha: 0.20),

              // border: Border.all(
              //   color: Colors.white.withValues(alpha: 0.20),
              //   width: 1,
              // ),

              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}