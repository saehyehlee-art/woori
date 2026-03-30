// =====================================================
// 일정 데이터 모델
// 마치 엑셀 한 행처럼, 일정 하나의 정보를 담는 그릇이에요
// =====================================================

class EventModel {
  final String id;         // 일정의 고유 번호 (중복 방지용)
  final String date;       // 날짜 (예: "2026-01-15")
  final List<String> users; // 참여 유저 목록 (예: ["나", "친구A"])
  final String userLabel;  // 화면에 표시될 유저 이름 (예: "나&친구A")
  final String time;       // 시간 (예: "17:00"), 없으면 빈 문자열
  final String title;      // 일정 내용 (예: "저녁 식사")

  EventModel({
    required this.id,
    required this.date,
    required this.users,
    required this.userLabel,
    required this.time,
    required this.title,
  });

  // EventModel → JSON (저장할 때 사용)
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'users': users,
        'userLabel': userLabel,
        'time': time,
        'title': title,
      };

  // JSON → EventModel (불러올 때 사용)
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        date: json['date'] as String,
        users: List<String>.from(json['users'] as List),
        userLabel: json['userLabel'] as String,
        time: (json['time'] as String?) ?? '',
        title: json['title'] as String,
      );
}
