// =====================================================
// 일정 추가 화면
// 날짜, 시간, 참여 유저, 내용을 입력해요
// =====================================================

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

class AddEventScreen extends StatefulWidget {
  final List<String> users;
  final DateTime initialDate;

  const AddEventScreen({
    super.key,
    required this.users,
    required this.initialDate,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late DateTime _selectedDate;
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  List<String> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    // 처음엔 첫 번째 유저를 기본 선택
    if (widget.users.isNotEmpty) {
      _selectedUsers = [widget.users.first];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // 날짜 선택 다이얼로그
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // 저장 버튼
  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요!')),
      );
      return;
    }
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저를 선택해주세요!')),
      );
      return;
    }

    final sortedUsers = List<String>.from(_selectedUsers)..sort();
    final userLabel = sortedUsers.join('&');
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final newEvent = EventModel(
      id: const Uuid().v4(),
      date: dateStr,
      users: sortedUsers,
      userLabel: userLabel,
      time: _timeController.text.trim(),
      title: _titleController.text.trim(),
    );

    Navigator.pop(context, newEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 추가'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('저장', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 날짜 선택 ─────────────────────────
            _SectionLabel('📆 날짜'),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF1565C0), size: 18),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── 시간 입력 ─────────────────────────
            _SectionLabel('⏰ 시간 (선택사항)'),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                hintText: '예: 17:00',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                prefixIcon: const Icon(Icons.access_time, color: Color(0xFF1565C0)),
              ),
              keyboardType: TextInputType.datetime,
            ),

            const SizedBox(height: 20),

            // ─── 참여 유저 선택 ────────────────────
            _SectionLabel('👤 참여 유저'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.users.map((user) {
                final isSelected = _selectedUsers.contains(user);
                return FilterChip(
                  label: Text(user),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1565C0),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedUsers.add(user);
                      } else {
                        _selectedUsers.remove(user);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedUsers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '선택됨: ${_selectedUsers.join(' & ')}',
                  style: const TextStyle(color: Color(0xFF1565C0), fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            // ─── 일정 내용 입력 ────────────────────
            _SectionLabel('📝 내용'),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '예: 저녁 식사, 스터디, 영화',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF1565C0)),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 40),

            // ─── 저장 버튼 ─────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '✅  일정 저장하기',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 섹션 레이블 위젯 ──────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF424242),
        ),
      ),
    );
  }
}
