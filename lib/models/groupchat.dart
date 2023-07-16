import 'package:equatable/equatable.dart';

class GroupChat extends Equatable {
  String? key;
  final String groupName;
  final Duration timeRemaining;
  final int participantCount;
  final DateTime createdAt; // Updated type to DateTime

  GroupChat({
    this.key,
    required this.groupName,
    required this.timeRemaining,
    required this.participantCount,
    required this.createdAt,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      key: json['key'],
      groupName: json['groupName'],
      timeRemaining: Duration(milliseconds: json['timeRemaining']),
      participantCount: json['participantCount'],
      createdAt:
          DateTime.parse(json['createdAt']), // Parse the string as DateTime
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'groupName': groupName,
      'timeRemaining': timeRemaining.inMilliseconds,
      'participantCount': participantCount,
      'createdAt': createdAt.toUtc().toString(), // Convert DateTime to string
    };
  }

  @override
  List<Object?> get props =>
      [key, groupName, timeRemaining, participantCount, createdAt];
}
