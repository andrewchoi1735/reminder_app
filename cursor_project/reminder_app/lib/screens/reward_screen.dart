import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';

class StepRewardScreen extends StatefulWidget {
  const StepRewardScreen({super.key});

  @override
  State<StepRewardScreen> createState() => _StepRewardScreenState();
}

class _StepRewardScreenState extends State<StepRewardScreen> {
  int todaySteps = 0;
  int totalSteps = 0;
  late SharedPreferences prefs;
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    initPrefs();
    initStepCounter();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      totalSteps = prefs.getInt('totalSteps') ?? 0;
    });
  }

  void initStepCounter() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  void onStepCount(StepCount event) {
    setState(() {
      todaySteps = event.steps;
      // 누적 걸음 수 갱신
      totalSteps += 1; // 매번 1씩 증가 가정 (실제 사용 시 차이값 계산 필요)
      prefs.setInt('totalSteps', totalSteps);
    });
  }

  void onStepCountError(error) {
    debugPrint('걸음 수 센서 오류: $error');
  }

  String getBadge(int steps) {
    if (steps >= 10000000) return "💎 다이아";
    if (steps >= 5000000) return "🏆 플래티넘";
    if (steps >= 1000000) return "🥇 골드";
    if (steps >= 500000) return "🥈 실버";
    if (steps >= 100000) return "🥉 브론즈";
    return "🧍 없음";
  }

  @override
  Widget build(BuildContext context) {
    final badge = getBadge(totalSteps);
    return Scaffold(
      appBar: AppBar(title: const Text("걸음 수 리워드")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("오늘 걸음 수: $todaySteps", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text("누적 걸음 수: $totalSteps", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text("현재 뱃지: $badge", style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 32),
            if (badge.contains("다이아"))
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("개발자에게 연락하기"),
                    content: const Text("이메일: dev@example.com\n인스타그램: @dev_account"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("닫기"),
                      ),
                    ],
                  ),
                ),
                child: const Text("👨‍💻 개발자에게 연락하기"),
              ),
          ],
        ),
      ),
    );
  }
}
