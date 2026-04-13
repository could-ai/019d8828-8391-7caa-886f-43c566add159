import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const BreathApp());
}

class BreathApp extends StatelessWidget {
  const BreathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breath 4444',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BreathScreen(),
    );
  }
}

class BreathScreen extends StatefulWidget {
  const BreathScreen({super.key});

  @override
  State<BreathScreen> createState() => _BreathScreenState();
}

class _BreathScreenState extends State<BreathScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    // Total cycle is 16 seconds (4s inhale, 4s hold, 4s exhale, 4s hold)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      if (_isActive) {
        _isActive = false;
        _controller.stop();
        _controller.reset();
      } else {
        _isActive = true;
        _controller.repeat();
      }
    });
  }

  String get _currentPhaseText {
    if (!_isActive) return 'Ready';
    
    final progress = _controller.value;
    if (progress < 0.25) return 'Inhale';
    if (progress < 0.50) return 'Hold';
    if (progress < 0.75) return 'Exhale';
    return 'Hold';
  }

  int get _secondsLeft {
    if (!_isActive) return 4;
    
    final progress = _controller.value;
    // Each phase is 25% of the total progress, which corresponds to 4 seconds.
    // We want to count down from 4 to 1.
    final phaseProgress = (progress % 0.25) * 4; // 0.0 to 1.0 within the phase
    final secondsPassed = (phaseProgress * 4).floor();
    return 4 - secondsPassed;
  }

  double get _circleScale {
    if (!_isActive) return 0.5;

    final progress = _controller.value;
    if (progress < 0.25) {
      // Inhale: scale from 0.5 to 1.0
      return 0.5 + (progress * 4) * 0.5;
    } else if (progress < 0.50) {
      // Hold: stay at 1.0
      return 1.0;
    } else if (progress < 0.75) {
      // Exhale: scale from 1.0 to 0.5
      return 1.0 - ((progress - 0.5) * 4) * 0.5;
    } else {
      // Hold: stay at 0.5
      return 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Breathing'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentPhaseText,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isActive ? '$_secondsLeft' : '4-4-4-4',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer guide circle
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  // Inner animated circle
                  Transform.scale(
                    scale: _circleScale,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            FilledButton.icon(
              onPressed: _toggleBreathing,
              icon: Icon(_isActive ? Icons.stop : Icons.play_arrow),
              label: Text(_isActive ? 'Stop' : 'Start'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
