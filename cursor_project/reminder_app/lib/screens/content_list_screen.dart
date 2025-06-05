import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/screens/ledger_screen.dart';
import 'package:reminder_app/screens/reminder_list_screen.dart';
import 'package:reminder_app/screens/sensor_step_counter_screen.dart';
import 'package:reminder_app/screens/settings_screen.dart';
import 'package:reminder_app/screens/memo_list_screen.dart';
import 'package:reminder_app/screens/calculator_screen.dart';
import 'package:reminder_app/screens/login_screen.dart'; // 로그인 화면 import
import '../providers/auth_provider.dart';

class ContentListScreen extends StatelessWidget {
  const ContentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('컨텐츠 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              await authProvider.logout();

              // 로그인 화면으로 이동 (뒤로가기 방지)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('할 일'),
              subtitle: const Text('일정 관리 & 캘린더로 관리'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReminderListScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.note),
              title: const Text('메모장'),
              subtitle: const Text('간단한 메모 작성 및 관리'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoListScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('계산기'),
              subtitle: const Text('일반 계산 및 이력'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('가계부'),
              subtitle: const Text('지출/수입 내역 작성'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LedgerScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timelapse),
              title: const Text('만보기'),
              subtitle: const Text('걸음 수를 확인할 수 있어요!'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SensorStepCounterScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('추가 예정'),
              subtitle: const Text('새로운 컨텐츠가 곧 추가됩니다.'),
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("설정"),
              subtitle: const Text("앱의 설정을 변경합니다."),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
