// =====================================================
// 우리일정 앱 - 메인 파일
// 앱이 시작되는 곳이에요. 마치 책의 첫 페이지 같아요.
// =====================================================

import 'package:flutter/material.dart';
import 'models/event_model.dart';
import 'services/storage_service.dart';
import 'screens/timeline_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_event_screen.dart';

void main() {
  runApp(const UriIljeongApp());
}

class UriIljeongApp extends StatelessWidget {
  const UriIljeongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리일정',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// =====================================================
// 홈 페이지 - 하단 탭 3개
// 탭1: 전체 타임라인 (표 형태)
// 탭2: 월별 달력
// 탭3: 설정 (유저관리 + 공유)
// =====================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;
  List<EventModel> _events = [];
  List<String> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 저장된 데이터 불러오기
  Future<void> _loadData() async {
    final events = await StorageService.loadEvents();
    final users = await StorageService.loadUsers();
    setState(() {
      _events = events;
      _users = users;
      _isLoading = false;
    });
  }

  // 일정 추가
  void _addEvent(EventModel event) {
    setState(() => _events.add(event));
    StorageService.saveEvents(_events);
  }

  // 일정 삭제
  void _deleteEvent(String eventId) {
    setState(() => _events.removeWhere((e) => e.id == eventId));
    StorageService.saveEvents(_events);
  }

  // 유저 목록 변경
  void _onUsersChanged(List<String> newUsers) {
    setState(() => _users = newUsers);
  }

  // 일정 추가 화면으로 이동
  Future<void> _goToAddEvent() async {
    final result = await Navigator.push<EventModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEventScreen(
          users: _users,
          initialDate: DateTime(2026, 1, 1),
        ),
      ),
    );
    if (result != null) _addEvent(result);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1565C0)),
              SizedBox(height: 16),
              Text('불러오는 중...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // 각 탭 화면
    final List<Widget> screens = [
      TimelineScreen(events: _events, users: _users),
      CalendarScreen(
        events: _events,
        users: _users,
        onAddEvent: _addEvent,
        onDeleteEvent: _deleteEvent,
      ),
      SettingsScreen(
        users: _users,
        onUsersChanged: _onUsersChanged,
      ),
    ];

    return Scaffold(
      // 상단 앱바
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          '우리일정',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 타임라인 탭에서만 + 버튼 표시
        actions: _currentTabIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  tooltip: '일정 추가',
                  onPressed: _goToAddEvent,
                ),
              ]
            : null,
      ),

      // 현재 탭 화면
      body: screens[_currentTabIndex],

      // 하단 탭 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '타임라인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '달력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
