// =====================================================
// 저장 서비스
// 핸드폰 내부에 일정 데이터를 저장하고 불러오는 역할을 해요
// 마치 핸드폰의 메모장 같은 역할이에요
// =====================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class StorageService {
  static const String _eventsKey = 'events_v1';
  static const String _usersKey = 'users_v1';

  // ─── 일정 불러오기 ───────────────────────────────
  static Future<List<EventModel>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString(_eventsKey);
    if (eventsJson == null) return _sampleEvents(); // 처음엔 예시 데이터
    final List<dynamic> list = json.decode(eventsJson) as List<dynamic>;
    return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── 일정 저장하기 ───────────────────────────────
  static Future<void> saveEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsJson = json.encode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_eventsKey, eventsJson);
  }

  // ─── 유저 목록 불러오기 ──────────────────────────
  static Future<List<String>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? users = prefs.getStringList(_usersKey);
    return users ?? ['나', '친구A']; // 처음엔 기본값
  }

  // ─── 유저 목록 저장하기 ──────────────────────────
  static Future<void> saveUsers(List<String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_usersKey, users);
  }

  // ─── 전체 데이터 내보내기 (친구와 공유용) ──────────
  // 이 텍스트를 카카오톡으로 보내면 친구가 앱에 붙여넣기 할 수 있어요
  static Future<String> exportData() async {
    final events = await loadEvents();
    final users = await loadUsers();
    final data = {
      'version': 1,
      'events': events.map((e) => e.toJson()).toList(),
      'users': users,
    };
    return json.encode(data);
  }

  // ─── 전체 데이터 가져오기 ────────────────────────
  static Future<void> importData(String jsonString) async {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final events = (data['events'] as List<dynamic>)
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final users = List<String>.from(data['users'] as List<dynamic>);
    await saveEvents(events);
    await saveUsers(users);
  }

  // ─── 예시 데이터 (처음 앱 실행할 때 보여줘요) ────────
  static List<EventModel> _sampleEvents() {
    return [
      EventModel(
        id: 'sample-1',
        date: '2026-01-15',
        users: ['나', '친구A'],
        userLabel: '나&친구A',
        time: '20:00',
        title: '같이 스터디',
      ),
      EventModel(
        id: 'sample-2',
        date: '2026-01-15',
        users: ['나'],
        userLabel: '나',
        time: '17:00',
        title: '저녁 식사',
      ),
      EventModel(
        id: 'sample-3',
        date: '2026-02-14',
        users: ['친구A'],
        userLabel: '친구A',
        time: '19:00',
        title: '영화 보기',
      ),
    ];
  }
}
