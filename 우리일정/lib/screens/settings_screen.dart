// =====================================================
// 설정 화면
// 유저 관리 + 친구와 일정 공유 기능
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final List<String> users;
  final Function(List<String>) onUsersChanged;

  const SettingsScreen({
    super.key,
    required this.users,
    required this.onUsersChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _newUserController = TextEditingController();
  late List<String> _users;

  @override
  void initState() {
    super.initState();
    _users = List.from(widget.users);
  }

  @override
  void dispose() {
    _newUserController.dispose();
    super.dispose();
  }

  // 유저 추가
  void _addUser() {
    final name = _newUserController.text.trim();
    if (name.isEmpty) return;
    if (_users.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name 은 이미 있어요!')),
      );
      return;
    }
    setState(() => _users.add(name));
    _newUserController.clear();
    widget.onUsersChanged(_users);
    StorageService.saveUsers(_users);
  }

  // 유저 삭제
  void _deleteUser(String user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('유저 삭제'),
        content: Text('"$user" 를 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _users.remove(user));
              widget.onUsersChanged(_users);
              StorageService.saveUsers(_users);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 일정 내보내기 (카카오톡 등으로 공유)
  Future<void> _exportData() async {
    try {
      final jsonStr = await StorageService.exportData();
      await Share.share(
        jsonStr,
        subject: '우리일정 데이터 공유',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내보내기 실패했어요')),
      );
    }
  }

  // 일정 가져오기 (붙여넣기)
  Future<void> _importData() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 가져오기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('친구에게 받은 데이터를 붙여넣어 주세요'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '여기에 붙여넣기...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('가져오기'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      try {
        await StorageService.importData(controller.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 가져오기 성공! 앱을 다시 시작해주세요')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('데이터 형식이 올바르지 않아요')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 유저 관리 ───────────────────────────
          _SectionCard(
            title: '👥 유저 관리',
            child: Column(
              children: [
                // 현재 유저 목록
                ..._users.map((user) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _tagColor(user),
                        child: Text(
                          user.substring(0, 1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user),
                      trailing: _users.length > 1
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _deleteUser(user),
                            )
                          : null,
                    )),
                const Divider(),
                // 유저 추가
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newUserController,
                        decoration: InputDecoration(
                          hintText: '새 유저 이름 (예: 민수)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onSubmitted: (_) => _addUser(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('추가'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── 친구와 공유 ─────────────────────────
          _SectionCard(
            title: '🔗 친구와 일정 공유',
            child: Column(
              children: [
                const Text(
                  '내 일정을 친구에게 보내거나,\n친구 일정을 내 앱에 가져올 수 있어요.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.upload),
                        label: const Text('내보내기'),
                        onPressed: _exportData,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text('가져오기', style: TextStyle(color: Colors.white)),
                        onPressed: _importData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── 앱 정보 ─────────────────────────────
          _SectionCard(
            title: 'ℹ️ 앱 정보',
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.apps, color: Color(0xFF1565C0)),
                  title: Text('우리일정'),
                  subtitle: Text('버전 1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_month, color: Color(0xFF1565C0)),
                  title: Text('지원 기간'),
                  subtitle: Text('2026년 1월 ~ 2027년 12월'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String label) {
    const colors = [
      Color(0xFF1E88E5),
      Color(0xFF8E24AA),
      Color(0xFF43A047),
      Color(0xFFE53935),
      Color(0xFFFB8C00),
    ];
    return colors[label.hashCode.abs() % colors.length];
  }
}

// ─── 섹션 카드 위젯 ───────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
