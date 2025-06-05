import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SensorStepCounterScreen extends StatefulWidget {
  const SensorStepCounterScreen({super.key});

  @override
  State<SensorStepCounterScreen> createState() => _SensorStepCounterScreenState();
}

class _SensorStepCounterScreenState extends State<SensorStepCounterScreen> {
  late Stream<StepCount> _stepCountStream;
  int _stepCount = 0;
  int _baseSteps = 0;
  int _todaySteps = 0;
  int _goalSteps = 10000;
  bool _isEditingGoal = false;
  String _message = '';

  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepError);
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";
    final savedDate = prefs.getString('step_date');
    _goalSteps = prefs.getInt('goal_steps') ?? 10000;
    _goalController.text = _goalSteps.toString();

    if (savedDate != today) {
      await prefs.setString('step_date', today);
      await prefs.setInt('step_base', _stepCount);
      _baseSteps = _stepCount;
    } else {
      _baseSteps = prefs.getInt('step_base') ?? 0;
    }

    setState(() {});
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _stepCount = event.steps;
      _todaySteps = _stepCount - _baseSteps;
      _updateMessage();
    });
  }

  void _onStepError(error) {
    debugPrint('걸음 수 오류: $error');
  }

  void _updateMessage() {
    final percent = _todaySteps / _goalSteps;
    if (percent >= 1.0) {
      _message = "🎉 목표 달성! 오늘도 수고했어요!";
    } else if (percent >= 0.75) {
      _message = "💪 거의 다 왔어요!";
    } else if (percent >= 0.5) {
      _message = "🔥 절반 넘었어요! 계속 걸어요!";
    } else if (percent >= 0.25) {
      _message = "👍 좋은 출발이에요!";
    } else {
      _message = "🚶 시작이 반! 힘내요!";
    }
  }

  Future<void> _confirmEditGoal() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('목표 걸음 수 변경'),
        content: TextField(
          controller: _goalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '새 목표 입력'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('저장')),
        ],
      ),
    );

    if (result == true) {
      final val = int.tryParse(_goalController.text);
      if (val != null && val > 0 && val != _goalSteps) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('goal_steps', val);
        setState(() {
          _goalSteps = val;
          _updateMessage();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = (_todaySteps / _goalSteps).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('센서 기반 걸음 수')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Lottie.asset(
                isDark
                    ? 'assets/animations/dark_walk.json'
                    : 'assets/animations/light_walk.json',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(height: 16),
            Text("오늘 걸음 수: $_todaySteps", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text("목표 걸음 수: $_goalSteps", style: Theme.of(context).textTheme.bodyLarge),
            TextButton.icon(
              onPressed: _confirmEditGoal,
              icon: const Icon(Icons.edit),
              label: const Text("목표 변경"),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
            ),
            const SizedBox(height: 16),
            Text(_message, style: Theme.of(context).textTheme.titleMedium),

            // ElevatedButton.icon(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.amber,
            //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            //   ),
            //   onPressed: () => Navigator.pushNamed(context, '/reward'),
            //   icon: const Icon(Icons.emoji_events),
            //   label: const Text('리워드 보러가기', style: TextStyle(fontSize: 16)),
            // )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }
}