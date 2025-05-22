import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/memo.dart';
import '../providers/auth_provider.dart';
import '../providers/memo_provider.dart';
import 'memo_edit_screen.dart';
import 'memo_detail_screen.dart';

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  State<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      Provider.of<MemoProvider>(context, listen: false).setUser(userId);
    });
  }

  // 날짜를 yyyy.MM.dd 형식 문자열로 변환
  String formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy.MM.dd').format(normalized);
  }

  // 메모 그룹화
  Map<String, List<Memo>> groupMemosByDate(List<Memo> memos) {
    Map<String, List<Memo>> grouped = {};
    for (var memo in memos) {
      final key = formatDate(memo.createdAt);
      grouped.putIfAbsent(key, () => []).add(memo);
    }
    return grouped;
  }

  // 검색 필터
  List<Memo> filterMemos(List<Memo> memos, String keyword) {
    if (keyword.trim().isEmpty) return memos;
    return memos.where((m) =>
    m.title.contains(keyword) || m.content.contains(keyword)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메모장 목록')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '제목 또는 내용 검색',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MemoProvider>(
              builder: (context, memoProvider, child) {
                final filtered = filterMemos(memoProvider.memos, _searchQuery);
                if (filtered.isEmpty) {
                  return const Center(child: Text('해당 조건의 메모가 없습니다.'));
                }

                final grouped = groupMemosByDate(filtered);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: grouped.entries.map((entry) {
                    final date = entry.key;
                    final dateMemos = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            date,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ...dateMemos.map((memo) => Dismissible(
                          key: ValueKey(memo.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await Provider.of<MemoProvider>(context, listen: false)
                                .deleteMemo(memo.id!);
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
                        )),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MemoEditScreen()),
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
