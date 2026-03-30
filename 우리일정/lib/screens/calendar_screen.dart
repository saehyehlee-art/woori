// =====================================================
// 페이지 2: 월별 달력 화면
// 월별로 달력 형태로 일정을 보여줘요
// =====================================================

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  final List<EventModel> events;
  final List<String> users;
  final Function(EventModel) onAddEvent;
  final Function(String) onDeleteEvent;

  const CalendarScreen({
    super.key,
    required this.events,
    required this.users,
    required this.onAddEvent,
    required this.onDeleteEvent,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime(2026, 1, 1);
  DateTime? _selectedDay;

  // 선택한 날짜의 일정 가져오기
  List<EventModel> _getEventsForDay(DateTime day) {
    final dateStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final list = widget.events.where((e) => e.date == dateStr).toList();
    list.sort((a, b) {
      final ta = a.time.isEmpty ? '99:99' : a.time;
      final tb = b.time.isEmpty ? '99:99' : b.time;
      return ta.compareTo(tb);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents =
        _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ─── 달력 위젯 ────────────────────────────
          TableCalendar<EventModel>(
            // 2026년 1월 ~ 2027년 12월만 표시
            firstDay: DateTime(2026, 1, 1),
            lastDay: DateTime(2027, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            // 달력 스타일
            calendarStyle: CalendarStyle(
              // 오늘 날짜 스타일
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
              // 선택된 날짜 스타일
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                shape: BoxShape.circle,
              ),
              // 주말 색상
              weekendTextStyle: const TextStyle(color: Color(0xFFD32F2F)),
              // 이벤트 점 스타일
              markerDecoration: const BoxDecoration(
                color: Color(0xFF43A047),
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              markersMaxCount: 3,
            ),
            // 헤더 스타일
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            // 요일 헤더 스타일
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
              weekendStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
            // 날짜 선택 시
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            // 페이지(월) 변경 시
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),

          const Divider(height: 1),

          // ─── 선택된 날짜의 일정 목록 ──────────────
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text(
                      '날짜를 선택하면\n일정이 표시돼요 📅',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : _EventListForDay(
                    selectedDay: _selectedDay!,
                    events: selectedEvents.cast<EventModel>(),
                    onDelete: widget.onDeleteEvent,
                  ),
          ),
        ],
      ),

      // ─── 일정 추가 버튼 ────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('일정 추가', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final result = await Navigator.push<EventModel>(
            context,
            MaterialPageRoute(
              builder: (_) => AddEventScreen(
                users: widget.users,
                initialDate: _selectedDay ?? DateTime(2026, 1, 1),
              ),
            ),
          );
          if (result != null) {
            widget.onAddEvent(result);
          }
        },
      ),
    );
  }
}

// ─── 선택 날짜 일정 목록 위젯 ─────────────────────────
class _EventListForDay extends StatelessWidget {
  final DateTime selectedDay;
  final List<EventModel> events;
  final Function(String) onDelete;

  const _EventListForDay({
    required this.selectedDay,
    required this.events,
    required this.onDelete,
  });

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdays[selectedDay.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 선택 날짜 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일 ($weekday)',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
        // 일정 없을 때
        if (events.isEmpty)
          const Expanded(
            child: Center(
              child: Text('이 날엔 일정이 없어요', style: TextStyle(color: Colors.grey)),
            ),
          ),
        // 일정 목록
        if (events.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _tagColor(event.userLabel),
                      child: Text(
                        event.userLabel.substring(0, 1),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${event.userLabel}  ${event.time.isNotEmpty ? event.time : '시간 미정'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.grey, size: 20),
                      onPressed: () => _confirmDelete(context, event),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('"${event.title}" 일정을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(event.id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
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
