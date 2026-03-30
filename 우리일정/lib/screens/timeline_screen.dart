// =====================================================
// 페이지 1: 전체 타임라인 (표 형태)
// 연도 | 월 | 일 | 요일 | 특이사항 | 일정
// 토요일 = 파란색, 일요일/공휴일 = 빨간색
// =====================================================

import 'package:flutter/material.dart';
import '../models/event_model.dart';

class TimelineScreen extends StatelessWidget {
  final List<EventModel> events;
  final List<String> users;

  const TimelineScreen({
    super.key,
    required this.events,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    // 2026.1.1 ~ 2027.12.31 날짜 목록 생성
    final List<DateTime> allDates = [];
    DateTime cur = DateTime(2026, 1, 1);
    final end = DateTime(2027, 12, 31);
    while (!cur.isAfter(end)) {
      allDates.add(cur);
      cur = cur.add(const Duration(days: 1));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ─── 표 헤더 ────────────────────────────────
          _TableHeader(),
          // ─── 날짜 목록 ──────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: allDates.length,
              itemBuilder: (context, index) {
                final date = allDates[index];
                final dateStr =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                final dayEvents = _eventsForDate(dateStr);
                final holiday = _holidays[dateStr];
                final isHoliday = holiday != null;
                final isSunday = date.weekday == 7;
                final isSaturday = date.weekday == 6;
                final isRed = isSunday || isHoliday;
                final isBlue = isSaturday && !isHoliday;

                // 글자 색상 결정
                Color textColor;
                if (isRed) {
                  textColor = const Color(0xFFD32F2F);
                } else if (isBlue) {
                  textColor = const Color(0xFF1565C0);
                } else {
                  textColor = const Color(0xFF212121);
                }

                // 홀짝 줄 배경색 (엑셀처럼 줄무늬)
                final bgColor = index.isEven
                    ? Colors.white
                    : const Color(0xFFF5F5F5);

                return _DateRow(
                  date: date,
                  dateStr: dateStr,
                  events: dayEvents,
                  holiday: holiday,
                  textColor: textColor,
                  bgColor: bgColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<EventModel> _eventsForDate(String dateStr) {
    final list = events.where((e) => e.date == dateStr).toList();
    list.sort((a, b) {
      final ta = a.time.isEmpty ? '99:99' : a.time;
      final tb = b.time.isEmpty ? '99:99' : b.time;
      return ta.compareTo(tb);
    });
    return list;
  }

  // ─── 한국 공휴일 2026~2027 ────────────────────────
  static const Map<String, String> _holidays = {
    // 2026년
    '2026-01-01': '신정',
    '2026-01-28': '설날 연휴',
    '2026-01-29': '설날',
    '2026-01-30': '설날 연휴',
    '2026-03-01': '삼일절',
    '2026-05-05': '어린이날',
    '2026-05-24': '부처님오신날',
    '2026-06-06': '현충일',
    '2026-07-17': '제헌절',
    '2026-08-15': '광복절',
    '2026-09-25': '추석 연휴',
    '2026-09-26': '추석',
    '2026-09-27': '추석 연휴',
    '2026-10-03': '개천절',
    '2026-10-09': '한글날',
    '2026-12-25': '성탄절',
    // 2027년
    '2027-01-01': '신정',
    '2027-02-16': '설날 연휴',
    '2027-02-17': '설날',
    '2027-02-18': '설날 연휴',
    '2027-03-01': '삼일절',
    '2027-05-05': '어린이날',
    '2027-05-13': '부처님오신날',
    '2027-06-06': '현충일',
    '2027-07-17': '제헌절',
    '2027-08-15': '광복절',
    '2027-10-03': '개천절',
    '2027-10-05': '추석 연휴',
    '2027-10-06': '추석',
    '2027-10-07': '추석 연휴',
    '2027-10-09': '한글날',
    '2027-12-25': '성탄절',
  };
}

// ─── 표 헤더 ──────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF8FBC6A), // 스크린샷과 동일한 초록색 헤더
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: const [
          _HeaderCell('연도', flex: 2),
          _HeaderCell('월', flex: 1),
          _HeaderCell('일', flex: 1),
          _HeaderCell('요일', flex: 1),
          _HeaderCell('특이사항', flex: 2),
          _HeaderCell('일정', flex: 4),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── 날짜 한 행 ───────────────────────────────────────
class _DateRow extends StatelessWidget {
  final DateTime date;
  final String dateStr;
  final List<EventModel> events;
  final String? holiday;
  final Color textColor;
  final Color bgColor;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  const _DateRow({
    required this.date,
    required this.dateStr,
    required this.events,
    required this.holiday,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdays[date.weekday - 1];

    // 일정 텍스트 생성: "나: 17:00 식사  나&친구A: 20:00 스터디"
    final scheduleText = events.map((e) {
      final time = e.time.isNotEmpty ? '${e.time} ' : '';
      return '${e.userLabel}: $time${e.title}';
    }).join('   ');

    return Container(
      color: bgColor,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // 연도
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '${date.year}',
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            ),
          ),
          // 월
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${date.month}',
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            ),
          ),
          // 일
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: events.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          // 요일
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                weekday,
                style: TextStyle(fontSize: 12, color: textColor),
              ),
            ),
          ),
          // 특이사항 (공휴일)
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                holiday ?? '',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD32F2F),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // 일정
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 6, right: 4),
              child: Text(
                scheduleText,
                style: const TextStyle(fontSize: 11, color: Color(0xFF333333)),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
