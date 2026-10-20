import 'package:flutter/material.dart';

class ModeSelector extends StatelessWidget {
  final String selectedMode;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFixed = selectedMode == 'fixed';

    return Container(
      height: 56,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0B7778),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2C9697),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOption(
              label: 'Fixed',
              icon: Icons.timer_outlined,
              selected: isFixed,
              onTap: enabled ? () => onChanged('fixed') : null,
            ),
          ),
          Expanded(
            child: _buildOption(
              label: 'Progressive',
              icon: Icons.trending_up_rounded,
              selected: !isFixed,
              onTap: enabled ? () => onChanged('progressive') : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: double.infinity,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected
                  ? const Color(0xFF126D70)
                  : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF126D70)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}