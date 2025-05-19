import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/memo_provider.dart';
import '../models/memo.dart';
import 'memo_edit_screen.dart';
import 'memo_detail_screen.dart';

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  State<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      Provider.of<MemoProvider>(context, listen: false).setUser(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메모장 목록')),
      body: Consumer<MemoProvider>(
        builder: (context, memoProvider, child) {
          final memos = memoProvider.memos;
          if (memos.isEmpty) {
            return const Center(child: Text('저장된 메모가 없습니다.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: memos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final memo = memos[index];
              return Dismissible(
                key: ValueKey(memo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await Provider.of<MemoProvider>(context, listen: false).deleteMemo(memo.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('메모가 삭제되었습니다.')),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(memo.title),
                    subtitle: Text(
                      memo.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MemoDetailScreen(memo: memo),
                        ),
                      );
                      if (mounted) {
                        Provider.of<MemoProvider>(context, listen: false).loadMemos();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MemoEditScreen(),
            ),
          );
          if (mounted) {
            Provider.of<MemoProvider>(context, listen: false).loadMemos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('메모 추가'),
      ),
    );
  }
} 