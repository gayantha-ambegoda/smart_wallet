import 'package:flutter/material.dart';
import 'dart:math' as math;

class ExpandableFab extends StatefulWidget {
  final VoidCallback onTransactionPressed;
  final VoidCallback onTransferPressed;

  const ExpandableFab({
    super.key,
    required this.onTransactionPressed,
    required this.onTransferPressed,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExpandingActionButtons(),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: _toggle,
            child: AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _expandAnimation.value * math.pi / 4,
                  child: Icon(_isExpanded ? Icons.close : Icons.add),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandingActionButtons() {
    return ExpandedAnimationFab(
      animation: _expandAnimation,
      children: [
        _ActionButton(
          icon: Icons.swap_horiz,
          label: 'Transfer',
          onPressed: () {
            _toggle();
            widget.onTransferPressed();
          },
        ),
        _ActionButton(
          icon: Icons.add_circle_outline,
          label: 'Transaction',
          onPressed: () {
            _toggle();
            widget.onTransactionPressed();
          },
        ),
      ],
    );
  }
}

class ExpandedAnimationFab extends StatelessWidget {
  final Animation<double> animation;
  final List<Widget> children;

  const ExpandedAnimationFab({
    super.key,
    required this.animation,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map(
                (child) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: child,
                    ),
                  ),
                ),
              )
              .toList()
              .reversed
              .toList(),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
